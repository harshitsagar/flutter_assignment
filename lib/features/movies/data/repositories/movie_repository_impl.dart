// lib/features/movies/data/repositories/movie_repository_impl.dart

import '../../domain/entities/movie_entity.dart';
import '../../domain/repositories/movie_repository.dart';
import '../datasources/movie_remote_datasource.dart';

class MovieRepositoryImpl implements MovieRepository {
  final MovieRemoteDataSource remote;
  MovieRepositoryImpl({required this.remote});

  @override
  Future<List<MovieEntity>> getTrendingMovies(int page) async {
    return await remote.getTrendingMovies(page);
  }

  @override
  Future<MovieEntity> getMovieDetail(int movieId) async {
    return await remote.getMovieDetail(movieId);
  }
}
