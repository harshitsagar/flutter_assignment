// lib/features/movies/data/models/movie_model.dart

import '../../domain/entities/movie_entity.dart';

class MovieModel extends MovieEntity {
  const MovieModel({
    required super.id,
    required super.title,
    required super.overview,
    required super.posterPath,
    required super.releaseDate,
    required super.voteAverage,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? json['original_title'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'] ?? '',
      releaseDate: json['release_date'] ?? '',
      voteAverage: (json['vote_average'] ?? 0.0).toDouble(),
    );
  }

  factory MovieModel.fromBookmark(Map<String, dynamic> map) {
    return MovieModel(
      id: map['movie_id'] ?? 0,
      title: map['movie_title'] ?? '',
      overview: map['movie_overview'] ?? '',
      posterPath: map['movie_poster'] ?? '',
      releaseDate: map['movie_release_date'] ?? '',
      voteAverage: 0.0,
    );
  }
}
