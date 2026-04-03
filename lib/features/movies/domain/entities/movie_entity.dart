// lib/features/movies/domain/entities/movie_entity.dart

class MovieEntity {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String releaseDate;
  final double voteAverage;

  const MovieEntity({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.releaseDate,
    required this.voteAverage,
  });

  String get fullPosterUrl =>
      posterPath.isNotEmpty
          ? 'https://image.tmdb.org/t/p/w185$posterPath'
          : '';

  String get fullPosterUrlLarge =>
      posterPath.isNotEmpty
          ? 'https://image.tmdb.org/t/p/w500$posterPath'
          : '';

  String get formattedDate {
    if (releaseDate.isEmpty) return 'Unknown';
    try {
      final parts = releaseDate.split('-');
      if (parts.length == 3) {
        const months = [
          '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        final m = int.tryParse(parts[1]) ?? 0;
        return '${months[m]} ${parts[2]}, ${parts[0]}';
      }
    } catch (_) {}
    return releaseDate;
  }
}
