// lib/core/db/database_helper.dart

import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../constants/app_constants.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);
    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Offline users pending sync
    await db.execute('''
      CREATE TABLE offline_users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        job TEXT NOT NULL,
        server_id TEXT,
        is_synced INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // Bookmarks: movie bookmarked by a user
    await db.execute('''
      CREATE TABLE bookmarks (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        movie_id INTEGER NOT NULL,
        movie_title TEXT NOT NULL,
        movie_poster TEXT,
        movie_release_date TEXT,
        movie_overview TEXT,
        is_synced INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');
  }

  // ─── Offline Users ────────────────────────────────────────────────────────

  Future<int> insertOfflineUser(Map<String, dynamic> user) async {
    final db = await database;
    return db.insert('offline_users', user,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getPendingUsers() async {
    final db = await database;
    return db.query('offline_users', where: 'is_synced = ?', whereArgs: [0]);
  }

  Future<List<Map<String, dynamic>>> getAllOfflineUsers() async {
    final db = await database;
    return db.query('offline_users');
  }

  Future<int> markUserSynced(String localId, String serverId) async {
    final db = await database;
    return db.update(
      'offline_users',
      {'is_synced': 1, 'server_id': serverId},
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

  // ─── Bookmarks ────────────────────────────────────────────────────────────

  Future<int> insertBookmark(Map<String, dynamic> bookmark) async {
    final db = await database;
    return db.insert('bookmarks', bookmark,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> deleteBookmark(String userId, int movieId) async {
    final db = await database;
    return db.delete('bookmarks',
        where: 'user_id = ? AND movie_id = ?', whereArgs: [userId, movieId]);
  }

  Future<List<Map<String, dynamic>>> getBookmarksByUser(String userId) async {
    final db = await database;
    return db
        .query('bookmarks', where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<bool> isBookmarked(String userId, int movieId) async {
    final db = await database;
    final result = await db.query('bookmarks',
        where: 'user_id = ? AND movie_id = ?', whereArgs: [userId, movieId]);
    return result.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> getPendingBookmarks() async {
    final db = await database;
    return db.query('bookmarks', where: 'is_synced = ?', whereArgs: [0]);
  }

  Future<int> markBookmarkSynced(String id) async {
    final db = await database;
    return db.update('bookmarks', {'is_synced': 1},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
