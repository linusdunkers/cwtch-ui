import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import androidx.annotation.NonNull
import android.content.Context

//import libCwtch.LibCwtch

/* References:
more detailed kotlin / flutter method channel example:
https://stablekernel.com/article/flutter-platform-channels-quick-start/

kotlin / flutter plugin:
https://github.com/flutter/samples -- experimental/federated_plugin/federated_plugin
 */
/*
class FederatedPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private var context: Context? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "cwtch")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "Start" -> {
                val appDir = (call.arguments as? String) ?: "";
                val tor = (call.arguments as? String) ?: "tor";
                result.success(LibCwtch.Start(appDir, tor))
                        ?: result.error("Failed to start cwtch", "", null);
            }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        context = null
    }

}*/