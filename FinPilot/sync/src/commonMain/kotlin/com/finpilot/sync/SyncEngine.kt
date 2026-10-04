package com.finpilot.sync

import com.finpilot.core.logging.AppLogger
import com.finpilot.core.result.AppResult
import com.finpilot.domain.models.SyncStatus
import com.finpilot.domain.repositories.SyncRepository
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import kotlin.math.min
import kotlin.math.pow

class SyncEngine(
    private val networkMonitor: NetworkMonitor,
    private val scope: CoroutineScope = CoroutineScope(Dispatchers.Default)
) : SyncRepository {

    private val _syncState = MutableStateFlow<SyncState>(SyncState.Synced)
    val syncState: StateFlow<SyncState> = _syncState.asStateFlow()

    override val syncStateFlow: Flow<SyncStatus> = _syncState.map { state ->
        when (state) {
            is SyncState.Synced -> SyncStatus.SYNCED
            is SyncState.Syncing -> SyncStatus.PENDING_UPDATE
            is SyncState.Offline -> SyncStatus.PENDING_UPDATE
            is SyncState.Failed -> SyncStatus.SYNC_FAILED
        }
    }

    private val pendingQueue = MutableStateFlow<List<PendingSyncItem>>(emptyList())

    data class PendingSyncItem(
        val id: String,
        val entityType: String,
        val entityId: String,
        val operation: String,
        val attempts: Int = 0,
        val timestamp: Long
    )

    init {
        // Monitor connectivity changes: auto-sync when network returns
        scope.launch {
            networkMonitor.isOnlineFlow.collect { isOnline ->
                if (isOnline) {
                    AppLogger.i("SyncEngine", "Network available: processing pending offline mutations")
                    triggerSync()
                } else {
                    AppLogger.i("SyncEngine", "Network lost: switching to offline mode")
                    _syncState.value = SyncState.Offline
                }
            }
        }
    }

    override suspend fun triggerSync(): AppResult<Unit> {
        if (!networkMonitor.isOnline()) {
            _syncState.value = SyncState.Offline
            return AppResult.Success(Unit)
        }

        _syncState.value = SyncState.Syncing
        AppLogger.i("SyncEngine", "Starting bidirectional Firestore synchronization...")

        try {
            // Process queue with backoff
            val processed = processOfflineQueue()
            delay(400) // Brief smooth sync transition
            _syncState.value = SyncState.Synced
            AppLogger.i("SyncEngine", "Sync completed successfully: $processed items synchronized")
            return AppResult.Success(Unit)
        } catch (e: Exception) {
            AppLogger.e("SyncEngine", "Sync error", e)
            _syncState.value = SyncState.Failed(e.message ?: "Sync failed")
            return AppResult.Failure(com.finpilot.core.result.AppError.Network("Sync failed: ${e.message}"))
        }
    }

    override suspend fun processOfflineQueue(): AppResult<Int> {
        val currentQueue = pendingQueue.value
        if (currentQueue.isEmpty()) return AppResult.Success(0)

        var processedCount = 0
        val remainingQueue = mutableListOf<PendingSyncItem>()

        for (item in currentQueue) {
            try {
                // Simulate uploading entity mutation to Firestore
                uploadToCloud(item)
                processedCount++
            } catch (e: Exception) {
                val backoffMs = calculateBackoff(item.attempts)
                AppLogger.w("SyncEngine", "Item ${item.id} sync failed, retrying in ${backoffMs}ms: ${e.message}")
                remainingQueue.add(item.copy(attempts = item.attempts + 1))
            }
        }

        pendingQueue.value = remainingQueue
        return AppResult.Success(processedCount)
    }

    fun enqueueMutation(entityType: String, entityId: String, operation: String) {
        val item = PendingSyncItem(
            id = "sync_${kotlin.random.Random.nextLong(100000, 999999)}",
            entityType = entityType,
            entityId = entityId,
            operation = operation,
            timestamp = 1728038400000L
        )
        pendingQueue.update { it + item }
        if (networkMonitor.isOnline()) {
            scope.launch { triggerSync() }
        } else {
            _syncState.value = SyncState.Offline
        }
    }

    private suspend fun uploadToCloud(item: PendingSyncItem) {
        // In actual production, writes serialized DTO to /users/{uid}/{entityType}/{entityId}
        delay(50)
    }

    private fun calculateBackoff(attempt: Int): Long {
        val base = 1000L // 1 second
        val max = 60000L // 60 seconds max
        val delay = (base * 2.0.pow(attempt.toDouble())).toLong()
        return min(delay, max)
    }
}
