// lib/core/di/service_locator.dart

import 'package:get_it/get_it.dart';
import '../db/database_helper.dart';
import '../network/connectivity_service.dart';
import '../network/dio_client.dart';
import '../../features/users/data/datasources/user_remote_datasource.dart';
import '../../features/users/data/datasources/user_local_datasource.dart';
import '../../features/users/data/repositories/user_repository_impl.dart';
import '../../features/users/domain/repositories/user_repository.dart';
import '../../features/users/presentation/providers/user_provider.dart';
import '../../features/movies/data/datasources/movie_remote_datasource.dart';
import '../../features/movies/data/repositories/movie_repository_impl.dart';
import '../../features/movies/domain/repositories/movie_repository.dart';
import '../../features/movies/presentation/providers/movie_provider.dart';
import '../../features/movies/presentation/providers/bookmark_provider.dart';

final GetIt sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Core
  sl.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());
  sl.registerLazySingleton<ConnectivityService>(() => ConnectivityService());
  sl.registerLazySingleton<DioClient>(() => DioClient());

  // User feature
  sl.registerLazySingleton<UserRemoteDataSource>(
      () => UserRemoteDataSourceImpl(sl<DioClient>().reqresDio));
  sl.registerLazySingleton<UserLocalDataSource>(
      () => UserLocalDataSourceImpl(sl<DatabaseHelper>()));
  sl.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(
        remote: sl<UserRemoteDataSource>(),
        local: sl<UserLocalDataSource>(),
        connectivity: sl<ConnectivityService>(),
      ));
  sl.registerFactory<UserProvider>(() => UserProvider(
        repository: sl<UserRepository>(),
        connectivity: sl<ConnectivityService>(),
      ));

  // Movie feature
  sl.registerLazySingleton<MovieRemoteDataSource>(
      () => MovieRemoteDataSourceImpl(sl<DioClient>().tmdbDio));
  sl.registerLazySingleton<MovieRepository>(
      () => MovieRepositoryImpl(remote: sl<MovieRemoteDataSource>()));
  sl.registerFactory<MovieProvider>(
      () => MovieProvider(repository: sl<MovieRepository>()));

  // Bookmark
  sl.registerFactory<BookmarkProvider>(
      () => BookmarkProvider(dbHelper: sl<DatabaseHelper>()));
}
