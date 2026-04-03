// lib/features/movies/presentation/providers/bookmark_provider.dart

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/db/database_helper.dart';
import '../../domain/entities/movie_entity.dart';
import '../../data/models/movie_model.dart';

class BookmarkProvider extends ChangeNotifier {
  final DatabaseHelper dbHelper;

  // userId -> set of bookmarked movieIds
  final Map<String, Set<int>> _bookmarks = {};
  final Map<String, List<MovieEntity>> _bookmarkDetails = {};

  BookmarkProvider({required this.dbHelper});

  bool isBookmarked(String userId, int movieId) {
    return _bookmarks[userId]?.contains(movieId) ?? false;
  }

  List<MovieEntity> getBookmarksForUser(String userId) {
    return _bookmarkDetails[userId] ?? [];
  }

  Future<void> loadBookmarks(String userId) async {
    final rows = await dbHelper.getBookmarksByUser(userId);
    _bookmarks[userId] = rows.map((r) => r['movie_id'] as int).toSet();
    _bookmarkDetails[userId] =
        rows.map((r) => MovieModel.fromBookmark(r)).toList();
    notifyListeners();
  }

  Future<void> toggleBookmark(
      String userId, MovieEntity movie) async {
    final alreadyBookmarked = isBookmarked(userId, movie.id);
    if (alreadyBookmarked) {
      await dbHelper.deleteBookmark(userId, movie.id);
      _bookmarks[userId]?.remove(movie.id);
      _bookmarkDetails[userId]?.removeWhere((m) => m.id == movie.id);
    } else {
      final id = const Uuid().v4();
      await dbHelper.insertBookmark({
        'id': id,
        'user_id': userId,
        'movie_id': movie.id,
        'movie_title': movie.title,
        'movie_poster': movie.posterPath,
        'movie_release_date': movie.releaseDate,
        'movie_overview': movie.overview,
        'is_synced': 0,
        'created_at': DateTime.now().toIso8601String(),
      });
      _bookmarks[userId] ??= {};
      _bookmarks[userId]!.add(movie.id);
      _bookmarkDetails[userId] ??= [];
      _bookmarkDetails[userId]!.add(movie);
    }
    notifyListeners();
  }
}
