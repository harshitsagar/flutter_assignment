// lib/features/users/domain/repositories/user_repository.dart

import '../entities/user_entity.dart';

abstract class UserRepository {
  Future<List<UserEntity>> getUsers(int page);
  Future<UserEntity> addUser(String name, String job);
  Future<void> syncPendingUsers();
  Future<List<UserEntity>> getOfflineUsers();
}
