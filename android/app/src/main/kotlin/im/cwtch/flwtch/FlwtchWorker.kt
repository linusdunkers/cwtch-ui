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
                while(true) {
                    val evt = MainActivity.AppbusEvent(Cwtch.getAppBusEvent())
                    if (evt.EventType == "NewMessageFromPeer" || evt.EventType == "NewMessageFromGroup") {
                        val data = JSONObject(evt.Data)
                        if (data["RemotePeer"] != data["ProfileOnion"]) {
                            val channelId =
                                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                                        createMessageNotificationChannel(data.getString("RemotePeer"), data.getString("RemotePeer"))
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
                                intent.putExtra("RemotePeer", if (evt.EventType == "NewMessageFromPeer") data.getString("RemotePeer") else data.getString("GroupID"))
                            }

                            val newNotification = NotificationCompat.Builder(applicationContext, channelId)
                                    .setContentTitle(data.getString("Nick"))
                                    .setContentText("New message")//todo: translate
                                    .setLargeIcon(BitmapFactory.decodeStream(fh))
                                    .setSmallIcon(R.mipmap.knott)
                                    .setContentIntent(PendingIntent.getActivity(applicationContext, 1, clickIntent, PendingIntent.FLAG_UPDATE_CURRENT))
                                    .setAutoCancel(true)
                                    .build()
                            notificationManager.notify(getNotificationID(data.getString("ProfileOnion"), data.getString("RemotePeer")), newNotification)
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
            "GetMessage" -> {
                val profile = (a.get("profile") as? String) ?: ""
                val handle = (a.get("contact") as? String) ?: ""
                val indexI = a.getInt("index")
                return Result.success(Data.Builder().putString("result", Cwtch.getMessage(profile, handle, indexI.toLong())).build())
            }
            "UpdateMessageFlags" -> {
                val profile = (a.get("profile") as? String) ?: ""
                val handle = (a.get("contact") as? String) ?: ""
                val midx = (a.get("midx") as? Long) ?: 0
                val flags = (a.get("flags") as? Long) ?: 0
                Cwtch.updateMessageFlags(profile, handle, midx, flags)
            }
            "AcceptContact" -> {
                val profile = (a.get("ProfileOnion") as? String) ?: ""
                val handle = (a.get("handle") as? String) ?: ""
                Cwtch.acceptContact(profile, handle)
            }
            "BlockContact" -> {
                val profile = (a.get("ProfileOnion") as? String) ?: ""
                val handle = (a.get("handle") as? String) ?: ""
                Cwtch.blockContact(profile, handle)
            }
            "SendMessage" -> {
                val profile = (a.get("ProfileOnion") as? String) ?: ""
                val handle = (a.get("handle") as? String) ?: ""
                val message = (a.get("message") as? String) ?: ""
                Cwtch.sendMessage(profile, handle, message)
            }
            "SendInvitation" -> {
                val profile = (a.get("ProfileOnion") as? String) ?: ""
                val handle = (a.get("handle") as? String) ?: ""
                val target = (a.get("target") as? String) ?: ""
                Cwtch.sendInvitation(profile, handle, target)
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
            "SetGroupAttribute" -> {
                val profile = (a.get("ProfileOnion") as? String) ?: ""
                val groupHandle = (a.get("groupHandle") as? String) ?: ""
                val key = (a.get("key") as? String) ?: ""
                val value = (a.get("value") as? String) ?: ""
                Cwtch.setGroupAttribute(profile, groupHandle, key, value)
            }
            "CreateGroup" -> {
                val profile = (a.get("ProfileOnion") as? String) ?: ""
                val server = (a.get("server") as? String) ?: ""
                val groupName = (a.get("groupname") as? String) ?: ""
                Cwtch.createGroup(profile, server, groupName)
            }
            "DeleteProfile" -> {
                val profile = (a.get("ProfileOnion") as? String) ?: ""
                val pass = (a.get("pass") as? String) ?: ""
                Cwtch.deleteProfile(profile, pass)
            }
            "LeaveConversation" -> {
                val profile = (a.get("ProfileOnion") as? String) ?: ""
                val contactHandle = (a.get("contactHandle") as? String) ?: ""
                Cwtch.leaveConversation(profile, contactHandle)
            }
            "LeaveGroup" -> {
                val profile = (a.get("ProfileOnion") as? String) ?: ""
                val groupHandle = (a.get("groupHandle") as? String) ?: ""
                Cwtch.leaveGroup(profile, groupHandle)
            }
            "RejectInvite" -> {
                val profile = (a.get("ProfileOnion") as? String) ?: ""
                val groupHandle = (a.get("groupHandle") as? String) ?: ""
                Cwtch.rejectInvite(profile, groupHandle)
            }
            "Shutdown" -> {
                Cwtch.shutdownCwtch();
                return Result.success()
            }
            else -> return Result.failure()
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
                .setSmallIcon(R.mipmap.knott)
                .setOngoing(true)
                // Add the cancel action to the notification which can
                // be used to cancel the worker
                .addAction(android.R.drawable.ic_delete, cancel, PendingIntent.getActivity(applicationContext, 1, cancelIntent, PendingIntent.FLAG_UPDATE_CURRENT))
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

    companion object {
        const val KEY_METHOD = "KEY_METHOD"
        const val KEY_ARGS = "KEY_ARGS"
    }
}
