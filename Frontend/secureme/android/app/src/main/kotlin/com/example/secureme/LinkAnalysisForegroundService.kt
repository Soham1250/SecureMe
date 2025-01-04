package com.example.secureme

import android.app.*
import android.content.Intent
import android.os.IBinder
import androidx.core.app.NotificationCompat
import android.content.Context

class LinkAnalysisForegroundService : Service() {
    companion object {
        private const val NOTIFICATION_ID = 1
        private const val CHANNEL_ID = "SecureMeChannel"
        private const val CHANNEL_NAME = "SecureMe Link Analysis"
        const val ACTION_ANALYZE_LINKS = "com.example.secureme.ANALYZE_LINKS"
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_ANALYZE_LINKS -> {
                // Handle analyze links action
                LinkAnalysisAccessibilityService.methodChannel?.invokeMethod("startLinkAnalysis", null)
            }
        }

        startForeground(NOTIFICATION_ID, createNotification())
        return START_STICKY
    }

    private fun createNotificationChannel() {
        val channel = NotificationChannel(
            CHANNEL_ID,
            CHANNEL_NAME,
            NotificationManager.IMPORTANCE_DEFAULT
        )
        
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.createNotificationChannel(channel)
    }

    private fun createNotification(): Notification {
        val analyzeIntent = Intent(this, LinkAnalysisForegroundService::class.java).apply {
            action = ACTION_ANALYZE_LINKS
        }
        
        val analyzePendingIntent = PendingIntent.getService(
            this,
            0,
            analyzeIntent,
            PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("SecureMe Link Analysis")
            .setContentText("Click to analyze links on screen")
            .setSmallIcon(android.R.drawable.ic_menu_search)
            .addAction(
                android.R.drawable.ic_menu_search,
                "Analyze all links",
                analyzePendingIntent
            )
            .setOngoing(true)
            .build()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
