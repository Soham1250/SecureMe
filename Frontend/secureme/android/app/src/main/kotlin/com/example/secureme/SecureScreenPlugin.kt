package com.example.secureme

import android.app.Activity
import android.app.Application
import android.content.Context
import android.os.Bundle
import android.view.WindowManager
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class SecureScreenPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var application: Application? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.example.secureme/secure_screen")
        channel.setMethodCallHandler(this)
        
        application = flutterPluginBinding.applicationContext as? Application
        application?.registerActivityLifecycleCallbacks(object : Application.ActivityLifecycleCallbacks {
            override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {}
            override fun onActivityStarted(activity: Activity) {}
            override fun onActivityResumed(activity: Activity) {
                // Re-apply secure flag when activity is resumed
                if (this@SecureScreenPlugin.activity == null) {
                    this@SecureScreenPlugin.activity = activity
                }
            }
            override fun onActivityPaused(activity: Activity) {}
            override fun onActivityStopped(activity: Activity) {}
            override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {}
            override fun onActivityDestroyed(activity: Activity) {
                if (this@SecureScreenPlugin.activity == activity) {
                    this@SecureScreenPlugin.activity = null
                }
            }
        })
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        when (call.method) {
            "setSecureScreen" -> {
                val secure = call.arguments as? Boolean ?: false
                setSecureScreen(secure)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun setSecureScreen(secure: Boolean) {
        activity?.runOnUiThread {
            try {
                if (secure) {
                    activity?.window?.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                } else {
                    activity?.window?.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                }
            } catch (e: Exception) {
                // Ignore any errors
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        // Set secure flag when activity is attached
        binding.activity.window?.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        // Don't clear activity here as we want to maintain the reference
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        // Set secure flag when activity is reattached after config changes
        binding.activity.window?.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
    }

    override fun onDetachedFromActivity() {
        // Don't clear activity here as we want to maintain the reference
    }
    
    companion object {
        @JvmStatic
        fun registerWith(flutterEngine: FlutterEngine) {
            val plugin = SecureScreenPlugin()
            flutterEngine.plugins.add(plugin)
        }
    }
}
