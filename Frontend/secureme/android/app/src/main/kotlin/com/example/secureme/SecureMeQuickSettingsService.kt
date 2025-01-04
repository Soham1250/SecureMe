package com.example.secureme

import android.graphics.drawable.Icon
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService
import android.content.Intent

class SecureMeQuickSettingsService : TileService() {
    override fun onStartListening() {
        super.onStartListening()
        updateTile()
    }

    override fun onClick() {
        super.onClick()
        
        // Launch main activity when clicked
        val intent = Intent(this, MainActivity::class.java)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        startActivityAndCollapse(intent)
    }

    private fun updateTile() {
        val tile = qsTile
        tile.icon = Icon.createWithResource(this, R.drawable.ic_secureme)
        tile.label = "SecureMe"
        tile.state = Tile.STATE_INACTIVE
        tile.updateTile()
    }
}
