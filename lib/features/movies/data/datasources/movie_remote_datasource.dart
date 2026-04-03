// lib/features/movies/data/datasources/movie_remote_datasource.dart

import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/movie_model.dart';

abstract class MovieRemoteDataSource {
  Future<List<MovieModel>> getTrendingMovies(int page);
  Future<MovieModel> getMovieDetail(int movieId);
}

class MovieRemoteDataSourceImpl implements MovieRemoteDataSource {
  final Dio _dio;
  MovieRemoteDataSourceImpl(this._dio);

  @override
  Future<List<MovieModel>> getTrendingMovies(int page) async {
    final response = await _dio.get(
      '/trending/movie/day',
      queryParameters: {
        'language': 'en-US',
        'page': page,
        'api_key': AppConstants.tmdbApiKey,
      },
      options: Options(extra: {'retryCount': 0}),
    );
    final results = response.data['results'] as List;
    return results.map((e) => MovieModel.fromJson(e)).toList();
  }

  @override
  Future<MovieModel> getMovieDetail(int movieId) async {
    final response = await _dio.get(
      '/movie/$movieId',
      queryParameters: {'api_key': AppConstants.tmdbApiKey},
      options: Options(extra: {'retryCount': 0}),
    );
    return MovieModel.fromJson(response.data);
  }
}
