// lib/features/users/data/models/user_model.dart

import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.avatar,
    super.isOffline,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'] ?? '',
    );
  }

  factory UserModel.fromLocalDb(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      firstName: map['name']?.toString().split(' ').first ?? '',
      lastName: map['name']?.toString().split(' ').skip(1).join(' ') ?? '',
      email: '',
      avatar: '',
      isOffline: map['is_synced'] == 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'avatar': avatar,
      };
}
