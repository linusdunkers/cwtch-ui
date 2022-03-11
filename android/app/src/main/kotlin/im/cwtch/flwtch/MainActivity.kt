package im.cwtch.flwtch

import SplashView
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import androidx.annotation.NonNull
import android.content.pm.PackageManager
import android.util.Log
import android.view.Window
import androidx.lifecycle.Observer
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import androidx.work.*
import io.flutter.embedding.android.SplashScreen
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.ErrorLogResult

import org.json.JSONObject
import java.util.concurrent.TimeUnit
import java.io.File
import java.nio.file.Files
import java.nio.file.Paths
import java.nio.file.StandardCopyOption

import android.net.Uri
import android.provider.DocumentsContract
import android.content.ContentUris
import android.os.Build
import android.os.Environment
import android.database.Cursor
import android.provider.MediaStore

class MainActivity: FlutterActivity() {
    override fun provideSplashScreen(): SplashScreen? = SplashView()

    // Channel to get app info
    private val CHANNEL_APP_INFO = "test.flutter.dev/applicationInfo"
    private val CALL_APP_INFO = "getNativeLibDir"

    // Channel to get cwtch api calls on
    private val CHANNEL_CWTCH = "cwtch"

    // Channel to send eventbus events on
    private val CWTCH_EVENTBUS = "test.flutter.dev/eventBus"

    // Channels to trigger actions when an external notification is clicked
    private val CHANNEL_NOTIF_CLICK = "im.cwtch.flwtch/notificationClickHandler"
    private val CHANNEL_SHUTDOWN_CLICK = "im.cwtch.flwtch/shutdownClickHandler"

    // WorkManager tag applied to all Start() infinite coroutines
    val WORKER_TAG = "cwtchEventBusWorker"

    private var myReceiver: MyBroadcastReceiver? = null
    private var notificationClickChannel: MethodChannel? = null
    private var shutdownClickChannel: MethodChannel? = null

    // "Download to..." prompt extra arguments
    private val FILEPICKER_REQUEST_CODE = 234
    private val PREVIEW_EXPORT_REQUEST_CODE = 235
    private val PROFILE_EXPORT_REQUEST_CODE = 236
    private var dlToProfile = ""
    private var dlToHandle = ""
    private var dlToFileKey = ""
    private var exportFromPath = ""

    // handles clicks received from outside the app (ie, notifications)
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        if (notificationClickChannel == null || intent.extras == null) return

        if (intent.extras!!.getString("EventType") == "NotificationClicked") {
            if (!intent.extras!!.containsKey("ProfileOnion") || !intent.extras!!.containsKey("Handle")) {
                Log.i("onNewIntent", "got notification clicked intent with no onions")
                return
            }
            val profile = intent.extras!!.getString("ProfileOnion")
            val handle = intent.extras!!.getString("Handle")
            val mappo = mapOf("ProfileOnion" to profile, "Handle" to handle)
            val j = JSONObject(mappo)
            notificationClickChannel!!.invokeMethod("NotificationClicked", j.toString())
        } else if (intent.extras!!.getString("EventType") == "ShutdownClicked") {
            shutdownClickChannel!!.invokeMethod("ShutdownClicked", "")
        } else {
            print("warning: received intent with unknown method; ignoring")
        }
    }

    // handles return values from the system file picker
    override fun onActivityResult(requestCode: Int, result: Int, intent: Intent?) {
        super.onActivityResult(requestCode, result, intent);

        if (intent == null || intent!!.getData() == null) {
            Log.i("MainActivity:onActivityResult", "user canceled activity");
            return;
        }

        if (requestCode == FILEPICKER_REQUEST_CODE) {
            val filePath = intent!!.getData().toString();
            val manifestPath = StringBuilder().append(this.applicationContext.cacheDir).append("/").append(this.dlToFileKey).toString();
            handleCwtch(MethodCall("DownloadFile", mapOf(
                    "ProfileOnion" to this.dlToProfile,
                    "handle" to this.dlToHandle,
                    "filepath" to filePath,
                    "manifestpath" to manifestPath,
                    "filekey" to this.dlToFileKey
            )), ErrorLogResult(""));//placeholder; this Result is never actually invoked
        } else if (requestCode == PREVIEW_EXPORT_REQUEST_CODE) {
            val targetPath = intent!!.getData().toString()
            val sourcePath = Paths.get(this.exportFromPath);
            val targetUri = Uri.parse(targetPath);
            val os = this.applicationContext.getContentResolver().openOutputStream(targetUri);
            val bytesWritten = Files.copy(sourcePath, os);
            Log.d("MainActivity:PREVIEW_EXPORT", "copied " + bytesWritten.toString() + " bytes");
            if (bytesWritten != 0L) {
                os?.flush();
                os?.close();
                //Files.delete(sourcePath);
            }
        } else if (requestCode == PROFILE_EXPORT_REQUEST_CODE ) {
            val targetPath = intent!!.getData().toString()
            val srcFile = StringBuilder().append(this.applicationContext.cacheDir).append("/").append(this.exportFromPath).toString();
            Log.i("MainActivity:PREVIEW_EXPORT", "exporting previewed file " + srcFile);
            val sourcePath = Paths.get(srcFile);
            val targetUri = Uri.parse(targetPath);
            val os = this.applicationContext.getContentResolver().openOutputStream(targetUri);
            val bytesWritten = Files.copy(sourcePath, os);
            Log.d("MainActivity:PREVIEW_EXPORT", "copied " + bytesWritten.toString() + " bytes");
            if (bytesWritten != 0L) {
                os?.flush();
                os?.close();
                //Files.delete(sourcePath);
            }
        }
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Note: this methods are invoked on the main thread.
        //note to self: ask someone if this does anything ^ea
        requestWindowFeature(Window.FEATURE_NO_TITLE)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_APP_INFO).setMethodCallHandler { call, result -> handleAppInfo(call, result) }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_CWTCH).setMethodCallHandler { call, result -> handleCwtch(call, result) }
        notificationClickChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NOTIF_CLICK)
        shutdownClickChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_SHUTDOWN_CLICK)
    }

    // MethodChannel CHANNEL_APP_INFO handler (Flutter Channel for requests for Android environment info)
    private fun handleAppInfo(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            CALL_APP_INFO -> result.success(getNativeLibDir())
                    ?: result.error("Unavailable", "nativeLibDir not available", null);
            else -> result.notImplemented()
        }
    }

    private fun getNativeLibDir(): String {
        val ainfo = this.applicationContext.packageManager.getApplicationInfo(
                "im.cwtch.flwtch", // Must be app name
                PackageManager.GET_SHARED_LIBRARY_FILES)
        return ainfo.nativeLibraryDir
    }

    // receives messages from the ForegroundService (which provides, ironically enough, the backend)
    private fun handleCwtch(@NonNull call: MethodCall, @NonNull result: Result) {
        var method = call.method
        val argmap: Map<String, String> = call.arguments as Map<String, String>

        // the frontend calls Start every time it fires up, but we don't want to *actually* call Cwtch.Start()
        // in case the ForegroundService is still running. in both cases, however, we *do* want to re-register
        // the eventbus listener.
        if (call.method == "Start") {
            val uniqueTag = argmap["torPath"] ?: "nullEventBus"

            // note: because the ForegroundService is specified as UniquePeriodicWork, it can't actually get
            // accidentally duplicated. however, we still need to manually check if it's running or not, so
            // that we can divert this method call to ReconnectCwtchForeground instead if so.
            val works = WorkManager.getInstance(this).getWorkInfosByTag(WORKER_TAG).get()
            for (workInfo in works) {
                WorkManager.getInstance(this).cancelWorkById(workInfo.id)
            }
            WorkManager.getInstance(this).pruneWork()

            Log.i("MainActivity.kt", "Start() launching foregroundservice")
            // this is where the eventbus ForegroundService gets launched. WorkManager should keep it alive after this
            val data: Data = Data.Builder().putString(FlwtchWorker.KEY_METHOD, call.method).putString(FlwtchWorker.KEY_ARGS, JSONObject(argmap).toString()).build()
            // 15 minutes is the shortest interval you can request
            val workRequest = PeriodicWorkRequestBuilder<FlwtchWorker>(15, TimeUnit.MINUTES).setInputData(data).addTag(WORKER_TAG).addTag(uniqueTag).build()
            WorkManager.getInstance(this).enqueueUniquePeriodicWork("req_$uniqueTag", ExistingPeriodicWorkPolicy.REPLACE, workRequest)
            return
        } else if (call.method == "CreateDownloadableFile") {
            this.dlToProfile = argmap["ProfileOnion"] ?: ""
            this.dlToHandle = argmap["handle"] ?: ""
            val suggestedName = argmap["filename"] ?: "filename.ext"
            this.dlToFileKey = argmap["filekey"] ?: ""
            val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
                addCategory(Intent.CATEGORY_OPENABLE)
                type = "application/octet-stream"
                putExtra(Intent.EXTRA_TITLE, suggestedName)
            }
            startActivityForResult(intent, FILEPICKER_REQUEST_CODE)
            return
        } else if (call.method == "ExportPreviewedFile") {
            this.exportFromPath = argmap["Path"] ?: ""
            val suggestion = argmap["FileName"] ?: "filename.ext"
            var imgType = "jpeg"
            if (suggestion.endsWith("png")) {
                imgType = "png"
            } else if (suggestion.endsWith("webp")) {
                imgType = "webp"
            } else if (suggestion.endsWith("bmp")) {
                imgType = "bmp"
            } else if (suggestion.endsWith("gif")) {
                imgType = "gif"
            }
            val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
                addCategory(Intent.CATEGORY_OPENABLE)
                type = "image/" + imgType
                putExtra(Intent.EXTRA_TITLE, suggestion)
            }
            startActivityForResult(intent, PREVIEW_EXPORT_REQUEST_CODE)
            return
        } else if (call.method == "ExportProfile") {
            this.exportFromPath = argmap["file"] ?: ""
            val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
                addCategory(Intent.CATEGORY_OPENABLE)
                type = "application/gzip"
                putExtra(Intent.EXTRA_TITLE, argmap["file"])
            }
            startActivityForResult(intent, PROFILE_EXPORT_REQUEST_CODE)
        }

        // ...otherwise fallthru to a normal ffi method call (and return the result using the result callback)
        val data: Data = Data.Builder().putString(FlwtchWorker.KEY_METHOD, method).putString(FlwtchWorker.KEY_ARGS, JSONObject(argmap).toString()).build()
        val workRequest = OneTimeWorkRequestBuilder<FlwtchWorker>().setInputData(data).build()
        WorkManager.getInstance(this).enqueue(workRequest)
        WorkManager.getInstance(applicationContext).getWorkInfoByIdLiveData(workRequest.id).observe(
            this, Observer { workInfo ->
                if (workInfo != null && workInfo.state == WorkInfo.State.SUCCEEDED) {
                    val res = workInfo.outputData.keyValueMap.toString()
                    result.success(workInfo.outputData.getString("result"))
                }
            }
        )
    }

    // using onresume/onstop for broadcastreceiver because of extended discussion on https://stackoverflow.com/questions/7439041/how-to-unregister-broadcastreceiver
    override fun onResume() {
        super.onResume()
        Log.i("MainActivity.kt", "onResume")
        if (myReceiver == null) {
            Log.i("MainActivity.kt", "onResume registering local broadcast receiver / event bus forwarder")
            val mc = MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger, CWTCH_EVENTBUS)
            val filter = IntentFilter("im.cwtch.flwtch.broadcast.SERVICE_EVENT_BUS")
            myReceiver = MyBroadcastReceiver(mc)
            LocalBroadcastManager.getInstance(applicationContext).registerReceiver(myReceiver!!, filter)
        }

        // ReconnectCwtchForeground which will resync counters and settings...
        // We need to do this here because after a "pause" flutter is still running
        // but we might have lost sync with the background process...
        Log.i("MainActivity.kt", "Call ReconnectCwtchForeground")
        val data: Data = Data.Builder().putString(FlwtchWorker.KEY_METHOD, "ReconnectCwtchForeground").putString(FlwtchWorker.KEY_ARGS, "{}").build()
        val workRequest = OneTimeWorkRequestBuilder<FlwtchWorker>().setInputData(data).build()
        WorkManager.getInstance(applicationContext).enqueue(workRequest)
    }

    override fun onStop() {
        super.onStop()
        Log.i("MainActivity.kt", "onStop")
        if (myReceiver != null) {
            LocalBroadcastManager.getInstance(applicationContext).unregisterReceiver(myReceiver!!);
            myReceiver = null;
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.i("MainActivity.kt", "onDestroy - cancelling all WORKER_TAG and pruning old work")
        WorkManager.getInstance(this).cancelAllWorkByTag(WORKER_TAG)
        WorkManager.getInstance(this).pruneWork()
    }

    class AppbusEvent(json: String) : JSONObject(json) {
        val EventType = this.optString("EventType")
        val EventID = this.optString("EventID")
        val Data = this.optString("Data")
    }

    // MainActivity.MyBroadcastReceiver receives events from the Cwtch service via im.cwtch.flwtch.broadcast.SERVICE_EVENT_BUS Android local broadcast intents
    // then it forwards them to the flutter ui engine using the CWTCH_EVENTBUS methodchannel
    class MyBroadcastReceiver(mc: MethodChannel) : BroadcastReceiver() {
        val eventBus: MethodChannel = mc

        override fun onReceive(context: Context, intent: Intent) {
            val evtType = intent.getStringExtra("EventType") ?: ""
            val evtData = intent.getStringExtra("Data") ?: ""
            //val evtID = intent.getStringExtra("EventID") ?: ""//todo?
            eventBus.invokeMethod(evtType, evtData)
        }
    }
}
