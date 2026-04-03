// lib/features/users/data/datasources/user_local_datasource.dart

import 'package:uuid/uuid.dart';
import '../../../../core/db/database_helper.dart';
import '../models/user_model.dart';

abstract class UserLocalDataSource {
  Future<UserModel> saveOfflineUser(String name, String job);
  Future<List<UserModel>> getPendingUsers();
  Future<void> markUserSynced(String localId, String serverId);
  Future<List<UserModel>> getAllOfflineUsers();
}

class UserLocalDataSourceImpl implements UserLocalDataSource {
  final DatabaseHelper _db;
  UserLocalDataSourceImpl(this._db);

  @override
  Future<UserModel> saveOfflineUser(String name, String job) async {
    final id = const Uuid().v4();
    final now = DateTime.now().toIso8601String();
    await _db.insertOfflineUser({
      'id': id,
      'name': name,
      'job': job,
      'server_id': null,
      'is_synced': 0,
      'created_at': now,
    });
    return UserModel(
      id: id,
      firstName: name.split(' ').first,
      lastName: name.split(' ').skip(1).join(' '),
      email: '',
      avatar: '',
      isOffline: true,
    );
  }

  @override
  Future<List<UserModel>> getPendingUsers() async {
    final rows = await _db.getPendingUsers();
    return rows.map((r) => UserModel.fromLocalDb(r)).toList();
  }

  @override
  Future<void> markUserSynced(String localId, String serverId) async {
    await _db.markUserSynced(localId, serverId);
  }

  @override
  Future<List<UserModel>> getAllOfflineUsers() async {
    final rows = await _db.getAllOfflineUsers();
    return rows.map((r) => UserModel.fromLocalDb(r)).toList();
  }
}
