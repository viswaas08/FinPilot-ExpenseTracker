package com.finpilot.sync

import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow

sealed interface SyncState {
    data object Synced : SyncState {
        val label = "✓ Synced"
    }
    data object Syncing : SyncState {
        val label = "↻ Syncing..."
    }
    data object Offline : SyncState {
        val label = "○ Offline"
    }
    data class Failed(val message: String) : SyncState {
        val label = "⚠ Sync failed"
    }
}

interface NetworkMonitor {
    val isOnlineFlow: Flow<Boolean>
    fun isOnline(): Boolean
}

class MemoryNetworkMonitor(initialOnline: Boolean = true) : NetworkMonitor {
    private val _isOnline = MutableStateFlow(initialOnline)
    override val isOnlineFlow: Flow<Boolean> = _isOnline.asStateFlow()
    override fun isOnline(): Boolean = _isOnline.value

    fun setOnline(online: Boolean) {
        _isOnline.value = online
    }
}

/**
 * Last-Write-Wins (LWW) conflict resolver comparing updatedAt timestamps and versions
 */
object ConflictResolver {
    fun <T> resolve(
        localVersion: Long,
        localUpdatedAt: Long,
        remoteVersion: Long,
        remoteUpdatedAt: Long,
        localItem: T,
        remoteItem: T
    ): T {
        return when {
            remoteVersion > localVersion -> remoteItem
            localVersion > remoteVersion -> localItem
            remoteUpdatedAt >= localUpdatedAt -> remoteItem
            else -> localItem
        }
    }
}
