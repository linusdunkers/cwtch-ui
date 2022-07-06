package im.cwtch.flwtch

import SplashView
import android.annotation.TargetApi
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.net.Uri
import android.os.PowerManager
import android.provider.Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS
import android.util.Log
import android.view.Window
import android.view.WindowManager
import androidx.annotation.NonNull
import androidx.lifecycle.Observer
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import androidx.work.*
import cwtch.Cwtch
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.SplashScreen
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.ErrorLogResult
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result
import org.json.JSONObject
import java.nio.file.Files
import java.nio.file.Paths
import java.util.concurrent.TimeUnit


class MainActivity: FlutterActivity() {
    override fun provideSplashScreen(): SplashScreen? = SplashView()


    // Channel to get app info
    private val CHANNEL_APP_INFO = "test.flutter.dev/applicationInfo"
    private val CALL_APP_INFO = "getNativeLibDir"
    private val ANDROID_SETTINGS_CHANNEL_NAME = "androidSettings"
    private val ANDROID_SETTINGS_CHANGE_NAME= "androidSettingsChanged"
    private var andoidSettingsChangeChannel: MethodChannel? = null
    private val CALL_ASK_BATTERY_EXEMPTION = "requestBatteryExemption"
    private val CALL_IS_BATTERY_EXEMPT = "isBatteryExempt"

    // Channel to get cwtch api calls on
    private val CHANNEL_CWTCH = "cwtch"

    // Channel to send eventbus events on
    private val CWTCH_EVENTBUS = "test.flutter.dev/eventBus"

    // Channels to trigger actions when an external notification is clicked
    private val CHANNEL_NOTIF_CLICK = "im.cwtch.flwtch/notificationClickHandler"
    private val CHANNEL_SHUTDOWN_CLICK = "im.cwtch.flwtch/shutdownClickHandler"

    private val TAG: String = "MainActivity.kt"
    // WorkManager tag applied to all Start() infinite coroutines
    val WORKER_TAG = "cwtchEventBusWorker"

    private var myReceiver: MyBroadcastReceiver? = null
    private var notificationClickChannel: MethodChannel? = null
    private var shutdownClickChannel: MethodChannel? = null

    // "Download to..." prompt extra arguments
    private val FILEPICKER_REQUEST_CODE = 234
    private val PREVIEW_EXPORT_REQUEST_CODE = 235
    private val PROFILE_EXPORT_REQUEST_CODE = 236
    private val REQUEST_DOZE_WHITELISTING_CODE:Int = 9
    private var dlToProfile = ""
    private var dlToHandle = ""
    private var dlToFileKey = ""
    private var exportFromPath = ""

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        window.setFlags(WindowManager.LayoutParams.FLAG_SECURE, WindowManager.LayoutParams.FLAG_SECURE)
        // Todo: when we support SDK 31
        // hideOverlay()
    }

    /*
    @TargetApi(31)
    fun hideOverlay() {
        window.setHideOverlayWindows(true);
    }
    */

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

        // has null intent and data
        if (requestCode == REQUEST_DOZE_WHITELISTING_CODE) {
            // 0 == "battery optimized" (still)
            // -1 == "no battery optimization" (exempt!)
            andoidSettingsChangeChannel!!.invokeMethod("powerExemptionChange", result == -1)
            return;
        }

        if (intent == null || intent!!.getData() == null) {
            Log.i(TAG, "user canceled activity");
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
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ANDROID_SETTINGS_CHANNEL_NAME).setMethodCallHandler { call, result -> handleAndroidSettings(call, result) }
        notificationClickChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NOTIF_CLICK)
        shutdownClickChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_SHUTDOWN_CLICK)
        andoidSettingsChangeChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ANDROID_SETTINGS_CHANGE_NAME)
    }

    // MethodChannel CHANNEL_APP_INFO handler (Flutter Channel for requests for Android environment info)
    private fun handleAppInfo(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            CALL_APP_INFO -> result.success(getNativeLibDir())
                    ?: result.error("Unavailable", "nativeLibDir not available", null);
            else -> result.notImplemented()
        }
    }

    // MethodChannel ANDROID_SETTINGS_CHANNEL_NAME handler (Flutter Channel for requests for Android settings)
    // Called from lib/view/globalsettingsview.dart
    private fun handleAndroidSettings(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            CALL_IS_BATTERY_EXEMPT -> result.success(checkIgnoreBatteryOpt() ?: false);
            CALL_ASK_BATTERY_EXEMPTION -> { requestBatteryExemption(); result.success(null); }
            else -> result.notImplemented()
        }
    }

    @TargetApi(23)
    private fun checkIgnoreBatteryOpt(): Boolean {
        val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
        return powerManager.isIgnoringBatteryOptimizations(this.packageName) ?: false;
    }

    @TargetApi(23)
    private fun requestBatteryExemption() {
        val i = Intent()
        i.action = ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS
        i.data = Uri.parse("package:" + this.packageName)
        startActivityForResult(i, REQUEST_DOZE_WHITELISTING_CODE);
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
        // todo change usage patern to match that in FlwtchWorker
        // Unsafe for anything using int args, causes access time attempt to cast to string which will fail
        val argmap: Map<String, String> = call.arguments as Map<String, String>

        // the frontend calls Start every time it fires up, but we don't want to *actually* call Cwtch.Start()
        // in case the ForegroundService is still running. in both cases, however, we *do* want to re-register
        // the eventbus listener.
        when (call.method) {
            "Start" -> {
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
            }
            "CreateDownloadableFile" -> {
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
            }
            "ExportPreviewedFile" -> {
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
            }
            "ExportProfile" -> {
                this.exportFromPath = argmap["file"] ?: ""
                val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
                    addCategory(Intent.CATEGORY_OPENABLE)
                    type = "application/gzip"
                    putExtra(Intent.EXTRA_TITLE, argmap["file"])
                }
                startActivityForResult(intent, PROFILE_EXPORT_REQUEST_CODE)
            }
            "GetMessages" -> {
                Log.d("MainActivity.kt", "Cwtch GetMessages")

                val profile = argmap["ProfileOnion"] ?: ""
                val conversation: Int = call.argument("conversation") ?: 0
                val indexI: Int = call.argument("index") ?: 0
                val count: Int = call.argument("count") ?: 1

                result.success(Cwtch.getMessages(profile, conversation.toLong(), indexI.toLong(), count.toLong()))
                return
            }
            "SendMessage" -> {
                val profile: String = call.argument("ProfileOnion") ?: ""
                val conversation: Int = call.argument("conversation") ?: 0
                val message: String = call.argument("message") ?: ""
                result.success(Cwtch.sendMessage(profile, conversation.toLong(), message))
                return
            }
            "SendInvitation" -> {
                val profile: String = call.argument("ProfileOnion") ?: ""
                val conversation: Int = call.argument("conversation") ?: 0
                val target: Int = call.argument("target") ?: 0
                result.success(Cwtch.sendInvitation(profile, conversation.toLong(), target.toLong()))
                return
            }

            "ShareFile" -> {
                val profile: String = call.argument("ProfileOnion") ?: ""
                val conversation: Int = call.argument("conversation") ?: 0
                val filepath: String = call.argument("filepath") ?: ""
                result.success(Cwtch.shareFile(profile, conversation.toLong(), filepath))
                return
            }

            "GetSharedFiles" -> {
                val profile: String = call.argument("ProfileOnion") ?: ""
                val conversation: Int = call.argument("conversation") ?: 0
                result.success(Cwtch.getSharedFiles(profile, conversation.toLong()))
                return
            }

            "RestartSharing" -> {
                val profile: String = call.argument("ProfileOnion") ?: ""
                val filepath: String = call.argument("filekey") ?: ""
                result.success(Cwtch.restartSharing(profile, filepath))
                return
            }

            "StopSharing" -> {
                val profile: String = call.argument("ProfileOnion") ?: ""
                val filepath: String = call.argument("filekey") ?: ""
                result.success(Cwtch.stopSharing(profile, filepath))
                return
            }

            "CreateProfile" -> {
                val nick: String = call.argument("nick") ?: ""
                val pass: String = call.argument("pass") ?: ""
                Cwtch.createProfile(nick, pass)
            }
            "LoadProfiles" -> {
                val pass: String = call.argument("pass") ?: ""
                Cwtch.loadProfiles(pass)
            }
            "ChangePassword" -> {
                val profile: String = call.argument("ProfileOnion") ?: ""
                val pass: String = call.argument("OldPass") ?: ""
                val passNew: String = call.argument("NewPass") ?: ""
                val passNew2: String = call.argument("NewPassAgain") ?: ""
                Cwtch.changePassword(profile, pass, passNew, passNew2)
            }
            "GetMessage" -> {
                val profile: String = call.argument("ProfileOnion") ?: ""
                val conversation: Int = call.argument("conversation") ?: 0
                val indexI: Int = call.argument("index") ?: 0
                result.success(Cwtch.getMessage(profile, conversation.toLong(), indexI.toLong()))
                return
            }
            "GetMessageByID" -> {
                val profile: String = call.argument("ProfileOnion") ?: ""
                val conversation: Int = call.argument("conversation") ?: 0
                val id: Int = call.argument("id") ?: 0
                result.success(Cwtch.getMessageByID(profile, conversation.toLong(), id.toLong()))
                return
            }
            "GetMessageByContentHash" -> {
                val profile: String = call.argument("ProfileOnion") ?: ""
                val conversation: Int = call.argument("conversation") ?: 0
                val contentHash: String = call.argument("contentHash") ?: ""
                result.success(Cwtch.getMessagesByContentHash(profile, conversation.toLong(), contentHash))
                return
            }
            "SetMessageAttribute" -> {
                val profile: String = call.argument("ProfileOnion") ?: ""
                val conversation: Int = call.argument("conversation") ?: 0
                val channel: Int = call.argument("Chanenl") ?: 0
                val midx: Int = call.argument("Message") ?: 0
                val key: String = call.argument("key") ?: ""
                val value: String = call.argument("value") ?: ""
                Cwtch.setMessageAttribute(profile, conversation.toLong(), channel.toLong(), midx.toLong(), key, value)
            }
            "AcceptConversation" -> {
                val profile: String = call.argument("ProfileOnion") ?: ""
                val conversation: Int = call.argument("conversation") ?: 0
                Cwtch.acceptConversation(profile, conversation.toLong())
            }
            "BlockContact" -> {
                val profile: String = call.argument("ProfileOnion") ?: ""
                val conversation: Int = call.argument("conversation") ?: 0
                Cwtch.blockContact(profile, conversation.toLong())
            }
            "UnblockContact" -> {
                val profile: String = call.argument("ProfileOnion") ?: ""
                val conversation: Int = call.argument("conversation") ?: 0
                Cwtch.unblockContact(profile, conversation.toLong())
            }

            "DownloadFile" -> {
                val profile: String = call.argument("ProfileOnion") ?: ""
                val conversation: Int = call.argument("conversation") ?: 0
                val filepath: String = call.argument("filepath") ?: ""
                val manifestpath: String = call.argument("manifestpath") ?: ""
                val filekey: String = call.argument("filekey") ?: ""
                // FIXME: Prevent spurious calls by Intent
                if (profile != "") {
                    Cwtch.downloadFile(profile, conversation.toLong(), filepath, manifestpath, filekey)
                }
            }
            "CheckDownloadStatus" -> {
                val profile: String = call.argument("ProfileOnion") ?: ""
                val fileKey: String = call.argument("fileKey") ?: ""
                Cwtch.checkDownloadStatus(profile, fileKey)
            }
            "VerifyOrResumeDownload" -> {
                val profile: String = call.argument("ProfileOnion") ?: ""
                val conversation: Int = call.argument("conversation") ?: 0
                val fileKey: String = call.argument("fileKey") ?: ""
                Cwtch.verifyOrResumeDownload(profile, conversation.toLong(), fileKey)
            }
            "SendProfileEvent" -> {
                val onion: String= call.argument("onion") ?: ""
                val jsonEvent: String = call.argument("jsonEvent") ?: ""
                Cwtch.sendProfileEvent(onion, jsonEvent)
            }
            "SendAppEvent" -> {
                val jsonEvent: String = call.argument("jsonEvent") ?: ""
                Cwtch.sendAppEvent(jsonEvent)
            }
            "ResetTor" -> {
                Cwtch.resetTor()
            }
            "ImportBundle" -> {
                val profile: String = call.argument("ProfileOnion") ?: ""
                val bundle: String = call.argument("bundle") ?: ""
                Cwtch.importBundle(profile, bundle)
            }
            "CreateGroup" -> {
                val profile: String = call.argument("ProfileOnion") ?: ""
                val server: String = call.argument("server") ?: ""
                val groupName: String = call.argument("groupName") ?: ""
                Cwtch.createGroup(profile, server, groupName)
            }
            "DeleteProfile" -> {
                val profile: String = call.argument("ProfileOnion") ?: ""
                val pass: String = call.argument("pass") ?: ""
                Cwtch.deleteProfile(profile, pass)
            }
            "ArchiveConversation" -> {
                val profile: String = call.argument("ProfileOnion") ?: ""
                val conversation: Int = call.argument("conversation") ?: 0
                Cwtch.archiveConversation(profile, conversation.toLong())
            }
            "DeleteConversation" -> {
                val profile: String = call.argument("ProfileOnion") ?: ""
                val conversation: Int = call.argument("conversation") ?: 0
                Cwtch.deleteContact(profile, conversation.toLong())
            }
            "SetProfileAttribute" -> {
                val profile: String = call.argument("ProfileOnion") ?: ""
                val key: String = call.argument("Key") ?: ""
                val v: String = call.argument("Val") ?: ""
                Cwtch.setProfileAttribute(profile, key, v)
            }
            "SetConversationAttribute" -> {
                val profile: String = call.argument("ProfileOnion") ?: ""
                val conversation: Int = call.argument("conversation") ?: 0
                val key: String = call.argument("Key") ?: ""
                val v: String = call.argument("Val") ?: ""
                Cwtch.setConversationAttribute(profile, conversation.toLong(), key, v)
            }
            "LoadServers" -> {
                val password: String = call.argument("Password") ?: ""
                Cwtch.loadServers(password)
            }
            "CreateServer" -> {
                val password: String = call.argument("Password") ?: ""
                val desc: String = call.argument("Description") ?: ""
                val autostart: Boolean = call.argument("Autostart") ?: false
                Cwtch.createServer(password, desc, autostart)
            }
            "DeleteServer" -> {
                val serverOnion: String = call.argument("ServerOnion") ?: ""
                val password: String = call.argument("Password") ?: ""
                Cwtch.deleteServer(serverOnion, password)
            }
            "LaunchServers" -> {
                Cwtch.launchServers()
            }
            "LaunchServer" -> {
                val serverOnion: String = call.argument("ServerOnion") ?: ""
                Cwtch.launchServer(serverOnion)
            }
            "StopServer" -> {
                val serverOnion: String = call.argument("ServerOnion") ?: ""
                Cwtch.stopServer(serverOnion)
            }
            "StopServers" -> {
                Cwtch.stopServers()
            }
            "DestroyServers" -> {
                Cwtch.destroyServers()
            }
            "SetServerAttribute" -> {
                val serverOnion: String = call.argument("ServerOnion") ?: ""
                val key: String = call.argument("Key") ?: ""
                val v: String = call.argument("Val") ?: ""
                Cwtch.setServerAttribute(serverOnion, key, v)
            }
            "ExportProfile" -> {
                val profileOnion: String = call.argument("ProfileOnion") ?: ""
                val file: String = StringBuilder().append(this.applicationContext.cacheDir).append("/").append(call.argument("file") ?: "").toString()
                Log.i("FlwtchWorker", "constructing exported file " + file);
                Cwtch.exportProfile(profileOnion,file)
            }
            "ImportProfile" -> {
                val file: String = call.argument("file") ?: ""
                val pass: String = call.argument("pass") ?: ""
                Data.Builder().putString("result", Cwtch.importProfile(file, pass)).build()
            }
            "ReconnectCwtchForeground" -> {
                Cwtch.reconnectCwtchForeground()
            }
            "Shutdown" -> {
                Cwtch.shutdownCwtch();
            }
            else -> {
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
                return
            }
        }
        result.success(null)
    }

    // using onresume/onstop for broadcastreceiver because of extended discussion on https://stackoverflow.com/questions/7439041/how-to-unregister-broadcastreceiver
    override fun onResume() {
        super.onResume()
        Log.i("MainActivity.kt", "onResume")
        if (myReceiver == null) {
            Log.i("MainActivity.kt", "onResume registering local broadcast receiver / event bus forwarder")
            val bm = flutterEngine?.dartExecutor?.binaryMessenger;
            if (bm != null) {
                val mc = MethodChannel(bm, CWTCH_EVENTBUS)

                val filter = IntentFilter("im.cwtch.flwtch.broadcast.SERVICE_EVENT_BUS")
                myReceiver = MyBroadcastReceiver(mc)
                LocalBroadcastManager.getInstance(applicationContext)
                    .registerReceiver(myReceiver!!, filter)
            }
        }

        // ReconnectCwtchForeground which will resync counters and settings...
        // We need to do this here because after a "pause" flutter is still running
        // but we might have lost sync with the background process...
        Log.i("MainActivity.kt", "Call ReconnectCwtchForeground")
        Cwtch.reconnectCwtchForeground()
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
