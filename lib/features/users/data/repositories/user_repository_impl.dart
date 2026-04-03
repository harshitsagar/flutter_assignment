// lib/features/users/data/repositories/user_repository_impl.dart

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_datasource.dart';
import '../datasources/user_local_datasource.dart';
import '../../../../core/network/connectivity_service.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remote;
  final UserLocalDataSource local;
  final ConnectivityService connectivity;

  UserRepositoryImpl({
    required this.remote,
    required this.local,
    required this.connectivity,
  });

  @override
  Future<List<UserEntity>> getUsers(int page) async {
    return await remote.getUsers(page);
  }

  @override
  Future<UserEntity> addUser(String name, String job) async {
    final isOnline = await connectivity.isConnected;
    if (isOnline) {
      try {
        final result = await remote.createUser(name, job);
        // Save to local as synced too so user appears immediately
        return await local.saveOfflineUser(name, job).then((_) async {
          // mark synced right away since server returned ID
          final serverId = result['id']?.toString() ?? '';
          // We get the newly saved local record and mark it synced
          final pending = await local.getPendingUsers();
          if (pending.isNotEmpty) {
            await local.markUserSynced(pending.last.id, serverId);
          }
          // Return a clean entity with server id
          return UserEntity(
            id: serverId,
            firstName: name.split(' ').first,
            lastName: name.split(' ').skip(1).join(' '),
            email: '',
            avatar: '',
            isOffline: false,
          );
        });
      } catch (_) {
        // If API call fails, fall back to offline
        return await local.saveOfflineUser(name, job);
      }
    } else {
      return await local.saveOfflineUser(name, job);
    }
  }

  @override
  Future<void> syncPendingUsers() async {
    final pending = await local.getPendingUsers();
    for (final user in pending) {
      try {
        final result = await remote.createUser(user.fullName, '');
        final serverId = result['id']?.toString() ?? user.id;
        await local.markUserSynced(user.id, serverId);
      } catch (_) {
        // Leave for next sync attempt
      }
    }
  }

  @override
  Future<List<UserEntity>> getOfflineUsers() async {
    return await local.getAllOfflineUsers();
  }
}
