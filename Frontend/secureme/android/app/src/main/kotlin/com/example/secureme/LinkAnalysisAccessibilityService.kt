package com.example.secureme

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent
import io.flutter.plugin.common.MethodChannel

class LinkAnalysisAccessibilityService : AccessibilityService() {
    
    companion object {
        var methodChannel: MethodChannel? = null
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        // Handle accessibility events here
        // This can be used to monitor for URL-related activities
        event?.let {
            when (it.eventType) {
                AccessibilityEvent.TYPE_VIEW_CLICKED,
                AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED,
                AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED -> {
                    // Process the event for potential URL detection
                    processAccessibilityEvent(it)
                }
            }
        }
    }

    override fun onInterrupt() {
        // Handle service interruption
    }

    private fun processAccessibilityEvent(event: AccessibilityEvent) {
        // Extract text content that might contain URLs
        val text = event.text?.toString() ?: return
        
        // Simple URL pattern matching
        val urlPattern = Regex("https?://[^\\s]+")
        val urls = urlPattern.findAll(text).map { it.value }.toList()
        
        if (urls.isNotEmpty()) {
            // Send detected URLs back to Flutter
            methodChannel?.invokeMethod("urlDetected", mapOf("urls" to urls))
        }
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        // Service is connected and ready
    }
}
