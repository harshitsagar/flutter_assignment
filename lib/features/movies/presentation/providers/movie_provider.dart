// lib/features/movies/presentation/providers/movie_provider.dart

import 'package:flutter/foundation.dart';
import '../../domain/entities/movie_entity.dart';
import '../../domain/repositories/movie_repository.dart';

enum MovieLoadState { idle, loading, loaded, error }

class MovieProvider extends ChangeNotifier {
  final MovieRepository repository;

  final List<MovieEntity> _movies = [];
  MovieLoadState _state = MovieLoadState.idle;
  String _errorMessage = '';
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  bool _isReconnecting = false;
  MovieEntity? _selectedMovie;
  bool _isLoadingDetail = false;

  MovieProvider({required this.repository});

  List<MovieEntity> get movies => List.unmodifiable(_movies);
  MovieLoadState get state => _state;
  String get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
  bool get isReconnecting => _isReconnecting;
  MovieEntity? get selectedMovie => _selectedMovie;
  bool get isLoadingDetail => _isLoadingDetail;

  Future<void> loadMovies({bool refresh = false}) async {
    if (refresh) {
      _movies.clear();
      _currentPage = 1;
      _hasMore = true;
    }
    if (_state == MovieLoadState.loading && !refresh) return;

    _state = MovieLoadState.loading;
    notifyListeners();

    try {
      final newMovies = await repository.getTrendingMovies(_currentPage);
      _movies.addAll(newMovies);
      if (newMovies.isEmpty || newMovies.length < 20) _hasMore = false;
      _currentPage++;
      _state = MovieLoadState.loaded;
    } catch (e) {
      _state = MovieLoadState.error;
      _errorMessage = _friendlyError(e);
    }
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;
    notifyListeners();

    try {
      final newMovies = await repository.getTrendingMovies(_currentPage);
      _movies.addAll(newMovies);
      if (newMovies.isEmpty || newMovies.length < 20) _hasMore = false;
      _currentPage++;
    } catch (e) {
      // Interceptor handles retry. Show reconnecting indicator silently.
      _isReconnecting = true;
      notifyListeners();
      await Future.delayed(const Duration(seconds: 3));
      try {
        final newMovies = await repository.getTrendingMovies(_currentPage);
        _movies.addAll(newMovies);
        if (newMovies.isEmpty || newMovies.length < 20) _hasMore = false;
        _currentPage++;
      } catch (_) {}
      _isReconnecting = false;
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  Future<void> loadMovieDetail(int movieId) async {
    _isLoadingDetail = true;
    _selectedMovie = null;
    notifyListeners();
    try {
      _selectedMovie = await repository.getMovieDetail(movieId);
    } catch (_) {
      // Use the list item as fallback
      _selectedMovie = _movies.where((m) => m.id == movieId).firstOrNull;
    }
    _isLoadingDetail = false;
    notifyListeners();
  }

  String _friendlyError(Object e) {
    final s = e.toString().toLowerCase();
    if (s.contains('socket') || s.contains('connection')) {
      return 'No internet. Check your connection and retry.';
    }
    if (s.contains('401') || s.contains('api key')) {
      return 'Invalid TMDB API key. Please check app_constants.dart';
    }
    return 'Something went wrong. Pull to refresh.';
  }
}
