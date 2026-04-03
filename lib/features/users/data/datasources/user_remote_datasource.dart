// lib/features/users/data/datasources/user_remote_datasource.dart

import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<List<UserModel>> getUsers(int page);
  Future<Map<String, dynamic>> createUser(String name, String job);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final Dio _dio;
  UserRemoteDataSourceImpl(this._dio);

  @override
  Future<List<UserModel>> getUsers(int page) async {
    final response = await _dio.get(
      '/users',
      queryParameters: {
        'page': page,
        'apikey': AppConstants.reqresApiKey,
      },
      options: Options(extra: {'retryCount': 0}),
    );
    final data = response.data['data'] as List;
    return data.map((e) => UserModel.fromJson(e)).toList();
  }

  @override
  Future<Map<String, dynamic>> createUser(String name, String job) async {
    final response = await _dio.post(
      '/users',
      data: {'name': name, 'job': job},
      queryParameters: {'apikey': AppConstants.reqresApiKey},
    );
    return response.data as Map<String, dynamic>;
  }
}
