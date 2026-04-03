// lib/features/movies/domain/repositories/movie_repository.dart

import '../entities/movie_entity.dart';

abstract class MovieRepository {
  Future<List<MovieEntity>> getTrendingMovies(int page);
  Future<MovieEntity> getMovieDetail(int movieId);
}
