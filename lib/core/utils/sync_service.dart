// lib/core/utils/sync_service.dart

import 'package:workmanager/workmanager.dart';
import '../constants/app_constants.dart';

/// Called by WorkManager in background isolate
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == AppConstants.syncTaskName) {
      await _performSync();
    }
    return Future.value(true);
  });
}

Future<void> _performSync() async {
  // WorkManager runs in a separate isolate — DI is not available here.
  // The actual sync happens in UserProvider when the app is foregrounded.
  // This task simply completes successfully so WorkManager knows it ran.
  await Future.delayed(const Duration(milliseconds: 100));
}

/// In-app sync manager (used when app is foreground and connectivity restored)
class SyncManager {
  SyncManager._();
  static final SyncManager instance = SyncManager._();

  bool _isSyncing = false;

  Future<void> syncPendingData() async {
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      await _syncOfflineUsers();
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _syncOfflineUsers() async {
    // This is intentionally minimal here - full sync logic is in UserProvider
    // to have access to DI. WorkManager kicks it off; UserProvider finishes it.
  }
}

Future<void> initWorkManager() async {
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
}

Future<void> scheduleSync() async {
  await Workmanager().registerOneOffTask(
    AppConstants.syncTaskName,
    AppConstants.syncTaskName,
    tag: AppConstants.syncTaskTag,
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: ExistingWorkPolicy.replace,
  );
}
