package im.cwtch.flwtch

import android.app.*
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import android.graphics.Color
import android.os.Build
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.core.app.NotificationCompat
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import androidx.work.*
import cwtch.Cwtch
import io.flutter.FlutterInjector
import org.json.JSONObject

import java.nio.file.Files
import java.nio.file.Paths
import java.nio.file.StandardCopyOption
import android.net.Uri

class FlwtchWorker(context: Context, parameters: WorkerParameters) :
        CoroutineWorker(context, parameters) {
    private val notificationManager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as
                    NotificationManager

    private var notificationID: MutableMap<String, Int> = mutableMapOf()
    private var notificationIDnext: Int = 1

    override suspend fun doWork(): Result {
        val method = inputData.getString(KEY_METHOD)
                ?: return Result.failure()
        val args = inputData.getString(KEY_ARGS)
                ?: return Result.failure()
        // Mark the Worker as important
        val progress = "Cwtch is keeping Tor running in the background"//todo:translate
        setForeground(createForegroundInfo(progress))
        return handleCwtch(method, args)
    }

    private fun getNotificationID(profile: String, contact: String): Int {
        val k = "$profile $contact"
        if (!notificationID.containsKey(k)) {
            notificationID[k] = notificationIDnext++
        }
        return notificationID[k] ?: -1
    }

    private fun handleCwtch(method: String, args: String): Result {
        val a = JSONObject(args)
        when (method) {
            "Start" -> {
                Log.i("FlwtchWorker.kt", "handleAppInfo Start")
                val appDir = (a.get("appDir") as? String) ?: ""
                val torPath = (a.get("torPath") as? String) ?: "tor"
                Log.i("FlwtchWorker.kt", "appDir: '$appDir' torPath: '$torPath'")

                if (Cwtch.startCwtch(appDir, torPath) != 0.toLong()) return Result.failure()

                Log.i("FlwtchWorker.kt", "startCwtch success, starting coroutine AppbusEvent loop...")
                val downloadIDs = mutableMapOf<String, Int>()
                while(true) {
                    val evt = MainActivity.AppbusEvent(Cwtch.getAppBusEvent())
                    if (evt.EventType == "NewMessageFromPeer" || evt.EventType == "NewMessageFromGroup") {
                        val data = JSONObject(evt.Data)
                        val handle = if (evt.EventType == "NewMessageFromPeer") data.getString("RemotePeer") else data.getString("GroupID");
                        if (data["RemotePeer"] != data["ProfileOnion"]) {
                            val channelId =
                                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                                        createMessageNotificationChannel(handle, handle)
                                    } else {
                                        // If earlier version channel ID is not used
                                        // https://developer.android.com/reference/android/support/v4/app/NotificationCompat.Builder.html#NotificationCompat.Builder(android.content.Context)
                                        ""
                                    }

                            val loader = FlutterInjector.instance().flutterLoader()
                            val key = loader.getLookupKeyForAsset("assets/" + data.getString("Picture"))//"assets/profiles/001-centaur.png")
                            val fh = applicationContext.assets.open(key)


                            val clickIntent = Intent(applicationContext, MainActivity::class.java).also { intent ->
                                intent.action = Intent.ACTION_RUN
                                intent.putExtra("EventType", "NotificationClicked")
                                intent.putExtra("ProfileOnion", data.getString("ProfileOnion"))
                                intent.putExtra("Handle", handle)
                            }

                            val newNotification = NotificationCompat.Builder(applicationContext, channelId)
                                    .setContentTitle(data.getString("Nick"))
                                    .setContentText("New message")//todo: translate
                                    .setLargeIcon(BitmapFactory.decodeStream(fh))
                                    .setSmallIcon(R.mipmap.knott_transparent)
                                    .setContentIntent(PendingIntent.getActivity(applicationContext, 1, clickIntent, PendingIntent.FLAG_UPDATE_CURRENT))
                                    .setAutoCancel(true)
                                    .build()
                            notificationManager.notify(getNotificationID(data.getString("ProfileOnion"), handle), newNotification)
                        }
                    } else if (evt.EventType == "FileDownloadProgressUpdate") {
                        try {
                            val data = JSONObject(evt.Data);
                            val fileKey = data.getString("FileKey");
                            val title = data.getString("NameSuggestion");
                            val progress = data.getString("Progress").toInt();
                            val progressMax = data.getString("FileSizeInChunks").toInt();
                            if (!downloadIDs.containsKey(fileKey)) {
                                downloadIDs.put(fileKey, downloadIDs.count());
                            }
                            var dlID = downloadIDs.get(fileKey);
                            if (dlID == null) {
                                dlID = 0;
                            }
                            if (progress >= 0) {
                                val channelId =
                                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                                            createDownloadNotificationChannel(fileKey, fileKey)
                                        } else {
                                            // If earlier version channel ID is not used
                                            // https://developer.android.com/reference/android/support/v4/app/NotificationCompat.Builder.html#NotificationCompat.Builder(android.content.Context)
                                            ""
                                        };
                                val newNotification = NotificationCompat.Builder(applicationContext, channelId)
                                        .setOngoing(true)
                                        .setContentTitle("Downloading")//todo: translate
                                        .setContentText(title)
                                        .setSmallIcon(android.R.drawable.stat_sys_download)
                                        .setProgress(progressMax, progress, false)
                                        .setSound(null)
                                        //.setSilent(true)
                                        .build();
                                notificationManager.notify(dlID, newNotification);
                            }
                        } catch (e: Exception) {
                            Log.d("FlwtchWorker->FileDownloadProgressUpdate", e.toString() + " :: " + e.getStackTrace());
                        }
                    } else if (evt.EventType == "FileDownloaded") {
                        Log.d("FlwtchWorker", "file downloaded!");
                        val data = JSONObject(evt.Data);
                        val tempFile = data.getString("TempFile");
                        val fileKey = data.getString("FileKey");
                        if (tempFile != "" && tempFile != data.getString("FilePath")) {
                            val filePath = data.getString("FilePath");
                            Log.i("FlwtchWorker", "moving "+tempFile+" to "+filePath);
                            val sourcePath = Paths.get(tempFile);
                            val targetUri = Uri.parse(filePath);
                            val os = this.applicationContext.getContentResolver().openOutputStream(targetUri);
                            val bytesWritten = Files.copy(sourcePath, os);
                            Log.d("FlwtchWorker", "copied " + bytesWritten.toString() + " bytes");
                            if (bytesWritten != 0L) {
                                os?.flush();
                                os?.close();
                                Files.delete(sourcePath);
                            }
                        }
                        if (downloadIDs.containsKey(fileKey)) {
                            notificationManager.cancel(downloadIDs.get(fileKey)?:0);
                        }
                    }

                    Intent().also { intent ->
                        intent.action = "im.cwtch.flwtch.broadcast.SERVICE_EVENT_BUS"
                        intent.putExtra("EventType", evt.EventType)
                        intent.putExtra("Data", evt.Data)
                        intent.putExtra("EventID", evt.EventID)
                        LocalBroadcastManager.getInstance(applicationContext).sendBroadcast(intent)
                    }
                }
            }
            "ReconnectCwtchForeground" -> {
                Cwtch.reconnectCwtchForeground()
            }
            "CreateProfile" -> {
                val nick = (a.get("nick") as? String) ?: ""
                val pass = (a.get("pass") as? String) ?: ""
                Cwtch.createProfile(nick, pass)
            }
            "LoadProfiles" -> {
                val pass = (a.get("pass") as? String) ?: ""
                Cwtch.loadProfiles(pass)
            }
            "ChangePassword" -> {
                val profile = (a.get("ProfileOnion") as? String) ?: ""
                val pass = (a.get("OldPass") as? String) ?: ""
                val passNew = (a.get("NewPass") as? String) ?: ""
                val passNew2 = (a.get("NewPassAgain") as? String) ?: ""
                Cwtch.changePassword(profile, pass, passNew, passNew2)
            }
            "GetMessage" -> {
                val profile = (a.get("ProfileOnion") as? String) ?: ""
                val conversation = a.getInt("conversation").toLong()
                val indexI = a.getInt("index").toLong()
                Log.d("FlwtchWorker", "Cwtch GetMessage " + profile + " " + conversation.toString() + " " + indexI.toString())
                return Result.success(Data.Builder().putString("result", Cwtch.getMessage(profile, conversation, indexI)).build())
            }
            "GetMessageByID" -> {
                val profile = (a.get("ProfileOnion") as? String) ?: ""
                val conversation = a.getInt("conversation").toLong()
                val id = a.getInt("id").toLong()
                return Result.success(Data.Builder().putString("result", Cwtch.getMessageByID(profile, conversation, id)).build())
            }
            "GetMessageByContentHash" -> {
                val profile = (a.get("ProfileOnion") as? String) ?: ""
                val conversation = a.getInt("conversation").toLong()
                val contentHash = (a.get("contentHash") as? String) ?: ""
                return Result.success(Data.Builder().putString("result", Cwtch.getMessagesByContentHash(profile, conversation, contentHash)).build())
            }
            "UpdateMessageAttribute" -> {
                val profile = (a.get("ProfileOnion") as? String) ?: ""
                val conversation = a.getInt("conversation").toLong()
                val channel = a.getInt("chanenl").toLong()
                val midx = a.getInt("midx").toLong()
                val key = (a.get("key") as? String) ?: ""
                val value = (a.get("value") as? String) ?: ""
                Cwtch.setMessageAttribute(profile, conversation, channel, midx, key, value)
            }
            "AcceptConversation" -> {
                val profile = (a.get("ProfileOnion") as? String) ?: ""
                val conversation = a.getInt("conversation").toLong()
                Cwtch.acceptConversation(profile, conversation)
            }
            "BlockContact" -> {
                val profile = (a.get("ProfileOnion") as? String) ?: ""
                val conversation = a.getInt("conversation").toLong()
                Cwtch.blockContact(profile, conversation)
            }
            "UnblockContact" -> {
                val profile = (a.get("ProfileOnion") as? String) ?: ""
                val conversation = a.getInt("conversation").toLong()
                Cwtch.unblockContact(profile, conversation)
            }
            "SendMessage" -> {
                val profile = (a.get("ProfileOnion") as? String) ?: ""
                val conversation = a.getInt("conversation").toLong()
                val message = (a.get("message") as? String) ?: ""
                Cwtch.sendMessage(profile, conversation, message)
            }
            "SendInvitation" -> {
                val profile = (a.get("ProfileOnion") as? String) ?: ""
                val conversation = a.getInt("conversation").toLong()
                val target = (a.get("target") as? Long) ?: -1
                Cwtch.sendInvitation(profile, conversation, target)
            }
            "ShareFile" -> {
                val profile = (a.get("ProfileOnion") as? String) ?: ""
                val conversation = a.getInt("conversation").toLong()
                val filepath = (a.get("filepath") as? String) ?: ""
                Cwtch.shareFile(profile, conversation, filepath)
            }
            "DownloadFile" -> {
                val profile = (a.get("ProfileOnion") as? String) ?: ""
                val conversation = a.getInt("conversation").toLong()
                val filepath = (a.get("filepath") as? String) ?: ""
                val manifestpath = (a.get("manifestpath") as? String) ?: ""
                val filekey = (a.get("filekey") as? String) ?: ""
                // FIXME: Prevent spurious calls by Intent
                if (profile != "") {
                    Cwtch.downloadFile(profile, conversation, filepath, manifestpath, filekey)
                }
            }
            "CheckDownloadStatus" -> {
                val profile = (a.get("ProfileOnion") as? String) ?: ""
                val fileKey = (a.get("fileKey") as? String) ?: ""
                Cwtch.checkDownloadStatus(profile, fileKey)
            }
            "VerifyOrResumeDownload" -> {
                val profile = (a.get("ProfileOnion") as? String) ?: ""
                val conversation = a.getInt("conversation").toLong()
                val fileKey = (a.get("fileKey") as? String) ?: ""
                Cwtch.verifyOrResumeDownload(profile, conversation, fileKey)
            }
            "SendProfileEvent" -> {
                val onion = (a.get("onion") as? String) ?: ""
                val jsonEvent = (a.get("jsonEvent") as? String) ?: ""
                Cwtch.sendProfileEvent(onion, jsonEvent)
            }
            "SendAppEvent" -> {
                val jsonEvent = (a.get("jsonEvent") as? String) ?: ""
                Cwtch.sendAppEvent(jsonEvent)
            }
            "ResetTor" -> {
                Cwtch.resetTor()
            }
            "ImportBundle" -> {
                val profile = (a.get("ProfileOnion") as? String) ?: ""
                val bundle = (a.get("bundle") as? String) ?: ""
                Cwtch.importBundle(profile, bundle)
            }
            "CreateGroup" -> {
                val profile = (a.get("ProfileOnion") as? String) ?: ""
                val server = (a.get("server") as? String) ?: ""
                val groupName = (a.get("groupName") as? String) ?: ""
                Cwtch.createGroup(profile, server, groupName)
            }
            "DeleteProfile" -> {
                val profile = (a.get("ProfileOnion") as? String) ?: ""
                val pass = (a.get("pass") as? String) ?: ""
                Cwtch.deleteProfile(profile, pass)
            }
            "ArchiveConversation" -> {
                val profile = (a.get("ProfileOnion") as? String) ?: ""
                val conversation = (a.get("conversation") as? Long) ?: -1
                Cwtch.archiveConversation(profile, conversation)
            }
            "DeleteConversation" -> {
                val profile = (a.get("ProfileOnion") as? String) ?: ""
                val conversation = (a.get("conversation") as? Long) ?: -1
                Cwtch.deleteContact(profile, conversation)
            }
            "SetProfileAttribute" -> {
                val profile = (a.get("ProfileOnion") as? String) ?: ""
                val key = (a.get("Key") as? String) ?: ""
                val v = (a.get("Val") as? String) ?: ""
                Cwtch.setProfileAttribute(profile, key, v)
            }
            "SetConversationAttribute" -> {
                val profile = (a.get("ProfileOnion") as? String) ?: ""
                val conversation = (a.get("conversation") as? Long) ?: -1
                val key = (a.get("Key") as? String) ?: ""
                val v = (a.get("Val") as? String) ?: ""
                Cwtch.setConversationAttribute(profile, conversation, key, v)
            }
            "Shutdown" -> {
                Cwtch.shutdownCwtch();
                return Result.success()
            }
            "LoadServers" -> {
                val password = (a.get("Password") as? String) ?: ""
                Cwtch.loadServers(password)
            }
            "CreateServer" -> {
                val password = (a.get("Password") as? String) ?: ""
                val desc = (a.get("Description") as? String) ?: ""
                val autostart = (a.get("Autostart") as? Boolean) ?: false
                Cwtch.createServer(password, desc, autostart)
            }
            "DeleteServer" -> {
                val serverOnion = (a.get("ServerOnion") as? String) ?: ""
                val password = (a.get("Password") as? String) ?: ""
                Cwtch.deleteServer(serverOnion, password)
            }
            "LaunchServers" -> {
                Cwtch.launchServers()
            }
            "LaunchServer" -> {
                val serverOnion = (a.get("ServerOnion") as? String) ?: ""
                Cwtch.launchServer(serverOnion)
            }
            "StopServer" -> {
                val serverOnion = (a.get("ServerOnion") as? String) ?: ""
                Cwtch.stopServer(serverOnion)
            }
            "StopServers" -> {
                Cwtch.stopServers()
            }
            "DestroyServers" -> {
                Cwtch.destroyServers()
            }
            "SetServerAttribute" -> {
                val serverOnion = (a.get("ServerOnion") as? String) ?: ""
                val key = (a.get("Key") as? String) ?: ""
                val v = (a.get("Val") as? String) ?: ""
                Cwtch.setServerAttribute(serverOnion, key, v)
            }
            else -> {
                Log.i("FlwtchWorker", "unknown command: " + method);
                return Result.failure()
            }
        }
        return Result.success()
    }

    // Creates an instance of ForegroundInfo which can be used to update the
    // ongoing notification.
    private fun createForegroundInfo(progress: String): ForegroundInfo {
        val id = "flwtch"
        val title = "Flwtch"
        val cancel = "Shut down"//todo: translate
        val channelId =
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    createForegroundNotificationChannel(id, id)
                } else {
                    // If earlier version channel ID is not used
                    // https://developer.android.com/reference/android/support/v4/app/NotificationCompat.Builder.html#NotificationCompat.Builder(android.content.Context)
                    ""
                }

        val cancelIntent = Intent(applicationContext, MainActivity::class.java).also { intent ->
            intent.action = Intent.ACTION_RUN
            intent.putExtra("EventType", "ShutdownClicked")
        }

        val notification = NotificationCompat.Builder(applicationContext, channelId)
                .setContentTitle(title)
                .setTicker(title)
                .setContentText(progress)
                .setSmallIcon(R.mipmap.knott_transparent)
                .setOngoing(true)
                // Add the cancel action to the notification which can
                // be used to cancel the worker
                .addAction(android.R.drawable.ic_delete, cancel, PendingIntent.getActivity(applicationContext, 2, cancelIntent, PendingIntent.FLAG_UPDATE_CURRENT))
                .build()

        return ForegroundInfo(101, notification)
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun createForegroundNotificationChannel(channelId: String, channelName: String): String{
        val chan = NotificationChannel(channelId, channelName, NotificationManager.IMPORTANCE_NONE)
        chan.lightColor = Color.MAGENTA
        chan.lockscreenVisibility = Notification.VISIBILITY_PRIVATE
        notificationManager.createNotificationChannel(chan)
        return channelId
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun createMessageNotificationChannel(channelId: String, channelName: String): String{
        val chan = NotificationChannel(channelId, channelName, NotificationManager.IMPORTANCE_HIGH)
        chan.lightColor = Color.MAGENTA
        chan.lockscreenVisibility = Notification.VISIBILITY_PRIVATE
        notificationManager.createNotificationChannel(chan)
        return channelId
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun createDownloadNotificationChannel(channelId: String, channelName: String): String{
        val chan = NotificationChannel(channelId, channelName, NotificationManager.IMPORTANCE_LOW)
        chan.lightColor = Color.MAGENTA
        chan.lockscreenVisibility = Notification.VISIBILITY_PRIVATE
        notificationManager.createNotificationChannel(chan)
        return channelId
    }

    companion object {
        const val KEY_METHOD = "KEY_METHOD"
        const val KEY_ARGS = "KEY_ARGS"
    }
}
