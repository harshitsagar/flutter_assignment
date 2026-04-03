// lib/features/users/presentation/providers/user_provider.dart

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/utils/sync_service.dart';

enum UserLoadState { idle, loading, loaded, error }

class UserProvider extends ChangeNotifier {
  final UserRepository repository;
  final ConnectivityService connectivity;

  final List<UserEntity> _users = [];
  final List<UserEntity> _offlineUsers = [];
  UserLoadState _state = UserLoadState.idle;
  String _errorMessage = '';
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  bool _isOnline = true;
  bool _isReconnecting = false;

  StreamSubscription<bool>? _connectivitySub;

  UserProvider({
    required this.repository,
    required this.connectivity,
  }) {
    _listenConnectivity();
    _checkInitialConnectivity();
  }

  // ─── Getters ───────────────────────────────────────────────────────────────

  List<UserEntity> get users => [..._users, ..._offlineUsers];
  UserLoadState get state => _state;
  String get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
  bool get isOnline => _isOnline;
  bool get isReconnecting => _isReconnecting;

  // ─── Connectivity ──────────────────────────────────────────────────────────

  void _listenConnectivity() {
    _connectivitySub = connectivity.onConnectivityChanged.listen((online) async {
      final wasOffline = !_isOnline;
      _isOnline = online;
      if (online && wasOffline) {
        _isReconnecting = true;
        notifyListeners();
        await _syncAndReload();
        _isReconnecting = false;
        notifyListeners();
      } else if (!online) {
        notifyListeners();
      }
    });
  }

  Future<void> _checkInitialConnectivity() async {
    _isOnline = await connectivity.isConnected;
    notifyListeners();
  }

  Future<void> _syncAndReload() async {
    try {
      await repository.syncPendingUsers();
      await scheduleSync(); // trigger WorkManager for bookmarks too
      await loadOfflineUsers();
    } catch (_) {}
  }

  // ─── Load Users ───────────────────────────────────────────────────────────

  Future<void> loadUsers({bool refresh = false}) async {
    if (refresh) {
      _users.clear();
      _currentPage = 1;
      _hasMore = true;
    }
    if (_state == UserLoadState.loading && !refresh) return;

    _state = UserLoadState.loading;
    notifyListeners();

    try {
      final newUsers = await repository.getUsers(_currentPage);
      _users.addAll(newUsers);
      // reqres returns 6 per page; if less than 6 returned, no more pages
      if (newUsers.length < 6) _hasMore = false;
      _currentPage++;
      _state = UserLoadState.loaded;
    } catch (e) {
      _state = UserLoadState.error;
      _errorMessage = _friendlyError(e);
    }
    await loadOfflineUsers();
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;
    notifyListeners();

    try {
      final newUsers = await repository.getUsers(_currentPage);
      _users.addAll(newUsers);
      if (newUsers.length < 6) _hasMore = false;
      _currentPage++;
    } catch (e) {
      // Silent retry is handled in interceptor; show reconnecting indicator
      _isReconnecting = true;
      // Try again after a moment
      await Future.delayed(const Duration(seconds: 3));
      try {
        final newUsers = await repository.getUsers(_currentPage);
        _users.addAll(newUsers);
        if (newUsers.length < 6) _hasMore = false;
        _currentPage++;
      } catch (_) {}
      _isReconnecting = false;
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  Future<void> loadOfflineUsers() async {
    final offline = await repository.getOfflineUsers();
    _offlineUsers
      ..clear()
      ..addAll(offline);
    notifyListeners();
  }

  // ─── Add User ─────────────────────────────────────────────────────────────

  Future<UserEntity> addUser(String name, String job) async {
    final user = await repository.addUser(name, job);
    if (user.isOffline) {
      _offlineUsers.add(user);
    }
    notifyListeners();
    return user;
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  String _friendlyError(Object e) {
    final s = e.toString().toLowerCase();
    // 401 = API key missing or wrong
    if (s.contains('401') || s.contains('unauthorized') || s.contains('missing_api_key')) {
      return 'Invalid API key. Open app_constants.dart and set your reqres API key.';
    }
    // Real network errors - must check BEFORE generic "connection" string
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        return 'No internet connection. Showing cached data.';
      }
      if (e.response?.statusCode != null && e.response!.statusCode! >= 500) {
        return 'Server error. Retrying...';
      }
    }
    if (s.contains('socketexception') || s.contains('failed host lookup')) {
      return 'No internet connection. Showing cached data.';
    }
    return 'Something went wrong: ${e.toString().split('\n').first}';
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }
}
