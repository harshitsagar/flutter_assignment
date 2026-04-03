// lib/core/constants/app_constants.dart

class AppConstants {
  // ─── Reqres API ─────────────────────────────────────────────────────────────
  // Get your FREE key at https://reqres.in  (sign up → API key)
  // Replace the value below with your own key.
  static const String reqresApiKey = 'YOUR_REQRES_API_KEY';
  static const String reqresBaseUrl = 'https://reqres.in/api';

  // ─── TMDB API ────────────────────────────────────────────────────────────────
  // Get your FREE key at https://www.themoviedb.org/settings/api
  // Replace the value below with your own key.
  static const String tmdbApiKey = 'YOUR_TMDB_API_KEY';
  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const String tmdbImageBaseUrl = 'https://image.tmdb.org/t/p/w185';
  static const String tmdbImageOriginal = 'https://image.tmdb.org/t/p/w500';

  // ─── OMDB (fallback) ─────────────────────────────────────────────────────────
  // Get your FREE key at https://www.omdbapi.com/apikey.aspx
  static const String omdbApiKey = 'YOUR_OMDB_API_KEY';
  static const String omdbBaseUrl = 'https://www.omdbapi.com';

  // ─── WorkManager task names ──────────────────────────────────────────────────
  static const String syncTaskName = 'sync_offline_data_task';
  static const String syncTaskTag = 'offline_sync';

  // ─── DB ─────────────────────────────────────────────────────────────────────
  static const String dbName = 'flutter_assignment.db';
  static const int dbVersion = 1;

  // ─── Pagination ──────────────────────────────────────────────────────────────
  static const int pageSize = 6; // reqres returns 6 per page
  static const int moviePageSize = 20;

  // ─── Network interceptor ─────────────────────────────────────────────────────
  // Purposely fail 30% of GET requests as required by assignment
  static const double failureProbability = 0.30;
  static const int maxRetries = 3;
}
