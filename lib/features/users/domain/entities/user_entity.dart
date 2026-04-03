// lib/features/users/domain/entities/user_entity.dart

class UserEntity {
  final String id; // local UUID or server int as string
  final String firstName;
  final String lastName;
  final String email;
  final String avatar;
  final bool isOffline; // true = created offline, not from API

  const UserEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.avatar,
    this.isOffline = false,
  });

  String get fullName => '$firstName $lastName';
}
