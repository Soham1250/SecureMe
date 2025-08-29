package com.example.secureme

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.provider.Settings.ACTION_ACCESSIBILITY_SETTINGS
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterFragmentActivity() {
    private val CHANNEL = "com.example.secureme/link_anIalysis"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Register SecureScreenPlugin
        flutterEngine.plugins.add(SecureScreenPlugin())
        
        // Set secure flag by default
        runOnUiThread {
            window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
        }
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startService" -> {
                    // Check if accessibility service is enabled
                    if (!isAccessibilityServiceEnabled()) {
                        // Prompt user to enable accessibility service
                        startActivity(Intent(ACTION_ACCESSIBILITY_SETTINGS))
                        result.success(false)
                        return@setMethodCallHandler
                    }

                    // Check if overlay permission is granted (for Android 6.0 and above)
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(this)) {
                        val intent = Intent(
                            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                            Uri.parse("package:$packageName")
                        )
                        startActivity(intent)
                        result.success(false)
                        return@setMethodCallHandler
                    }

                    // Start the foreground service
                    val serviceIntent = Intent(this, LinkAnalysisForegroundService::class.java)
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        startForegroundService(serviceIntent)
                    } else {
                        startService(serviceIntent)
                    }
                    result.success(true)
                }
                "stopService" -> {
                    stopService(Intent(this, LinkAnalysisForegroundService::class.java))
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        // Set the method channel in the accessibility service
        LinkAnalysisAccessibilityService.methodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        )
    }

    private fun isAccessibilityServiceEnabled(): Boolean {
        val accessibilityEnabled = try {
            Settings.Secure.getInt(
                contentResolver,
                Settings.Secure.ACCESSIBILITY_ENABLED
            )
        } catch (e: Settings.SettingNotFoundException) {
            0
        }

        if (accessibilityEnabled == 1) {
            val service = "${packageName}/${LinkAnalysisAccessibilityService::class.java.canonicalName}"
            val serviceString = Settings.Secure.getString(
                contentResolver,
                Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
            )
            return serviceString?.contains(service) == true
        }
        return false
    }
}
