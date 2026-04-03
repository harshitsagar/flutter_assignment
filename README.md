# Flutter Assignment — User & Movie App

A full-featured Flutter application built for the Developer Assignment.

---

## 🚀 Setup Instructions

### Step 1 — Clone repository
```bash
git clone https://github.com/harshitsagar/flutter_assignment.git
```

### Step 2 — Get Your API Keys (REQUIRED)

Open `lib/core/constants/app_constants.dart` and replace the placeholder values:

#### 1. Reqres API Key (for Users)
- Go to **https://reqres.in**
- Click **"Get API Key"** (top-right corner) — it's free
- You'll receive a key like: `reqres-free-v1-xxxxxxxxxxxxxxxx`
- Replace `YOUR_REQRES_API_KEY` in `app_constants.dart`

#### 2. TMDB API Key (for Movies)
- Go to **https://www.themoviedb.org/settings/api**
- Sign up for a free account
- Request a **Developer API Key** (approved instantly)
- Replace `YOUR_TMDB_API_KEY` in `app_constants.dart`

#### 3. OMDB API Key (fallback, optional)
- Go to **https://www.omdbapi.com/apikey.aspx**
- Request a free key
- Replace `YOUR_OMDB_API_KEY` in `app_constants.dart`

---

### Step 3 — Install Dependencies

```bash
flutter pub get
```

### Step 4 — Run the App

```bash
flutter run
```

---

## 📱 Features Implemented

### ✅ User List Screen
- Paginated list of users from `GET https://reqres.in/api/users?page={page}`
- Displays avatar, first name, last name
- Infinite scroll pagination (loads more on scroll)
- Pull-to-refresh support
- Offline users shown with "Offline" badge
- Tap user → navigate to Movie List screen

### ✅ Add User Screen
- Accessible via FAB (floating action button)
- Input: Name + Job Title
- **Online:** POSTs to `https://reqres.in/api/users` immediately
- **Offline:** Saves to SQLite with `is_synced = 0`
- Auto-syncs via WorkManager when internet returns

### ✅ Offline Bookmarking
- Bookmark/unbookmark movies from both Movie List and Movie Detail screens
- Every bookmark is linked to a specific user ID
- Works 100% offline (stored in SQLite)
- Create user offline → immediately bookmark movies for that user ✓
- Pending bookmarks sync automatically when connectivity restores

### ✅ Movie List Screen
- 2-column grid of trending movies from TMDB
- Infinite scroll pagination
- Two tabs: **Trending** and **Bookmarks** (per user)
- Bookmark toggle directly from the card

### ✅ Movie Detail Screen
- Large poster header with gradient overlay
- Title, overview, release date, rating
- Bookmark toggle button at top + in body

### ✅ Network Resilience (Assignment Requirement)
- Custom `RandomFailureInterceptor`: **randomly fails 30% of GET requests** with a simulated `SocketException` or `500 Internal Server Error`
- `RetryInterceptor`: **exponential backoff** retry (1s → 2s → 4s, up to 3 retries)
- Silent `ReconnectingBanner` shown when a retry is in progress — no crash, no intrusive error screen
- Paginated lists never duplicate data during retries

---

## 🏗️ Architecture

```
lib/
├── core/
│   ├── constants/        # API keys, URLs, config
│   ├── db/               # SQLite (sqflite) helper
│   ├── di/               # get_it service locator
│   ├── network/          # Dio client + interceptors + connectivity
│   └── utils/            # WorkManager sync service
│
└── features/
    ├── users/
    │   ├── data/          # Models, Remote/Local datasources, Repository impl
    │   ├── domain/        # Entities, Repository interface
    │   └── presentation/  # Provider, Screens (List, Add), Widgets
    │
    └── movies/
        ├── data/          # Models, Remote datasource, Repository impl
        ├── domain/        # Entity, Repository interface
        └── presentation/  # Providers (Movie, Bookmark), Screens (List, Detail), Widgets
```

### Tech Stack

| Concern | Package |
|---|---|
| State Management | `provider` ^6.1.2 |
| Dependency Injection | `get_it` ^7.7.0 |
| Networking | `dio` ^5.4.3 |
| SQLite | `sqflite` ^2.3.3 |
| Background Sync | `workmanager` ^0.5.2 |
| Responsiveness | `flutter_screenutil` ^5.9.3 |
| Image Loading | `cached_network_image` ^3.3.1 |
| Connectivity | `connectivity_plus` ^6.0.3 |
| Unique IDs | `uuid` ^4.4.0 |

---

## 🗄️ Database Schema

### `offline_users`
| Column | Type | Description |
|---|---|---|
| id | TEXT (PK) | Local UUID |
| name | TEXT | Full name |
| job | TEXT | Job title |
| server_id | TEXT | ID returned by server after sync |
| is_synced | INTEGER | 0 = pending, 1 = synced |
| created_at | TEXT | ISO timestamp |

### `bookmarks`
| Column | Type | Description |
|---|---|---|
| id | TEXT (PK) | Local UUID |
| user_id | TEXT | Links to offline_users.id or server user ID |
| movie_id | INTEGER | TMDB movie ID |
| movie_title | TEXT | Cached title |
| movie_poster | TEXT | Cached poster path |
| movie_release_date | TEXT | Cached date |
| movie_overview | TEXT | Cached overview |
| is_synced | INTEGER | 0 = pending, 1 = synced |
| created_at | TEXT | ISO timestamp |

---

## 🔄 Offline → Online Sync Flow

1. User creates a new user while offline → saved to `offline_users` with `is_synced=0`
2. User bookmarks movies → saved to `bookmarks` with `user_id` = local UUID
3. When internet returns:
    - `ConnectivityService` stream fires → `UserProvider._syncAndReload()` called
    - `repository.syncPendingUsers()` POSTs each pending user to reqres API
    - `markUserSynced(localId, serverId)` updates the local record
    - `WorkManager` task also fires in the background for reliability

---

## 📋 Assumptions & Notes

- **reqres.in** returns 6 users per page and has a total of 12 users (pages 1–2). `hasMore` is set to `false` when fewer than 6 users are returned.
- The **30% failure interceptor** applies only to GET requests as required. POST requests (add user) are not randomly failed.
- **WorkManager** background sync is registered as a one-off task triggered when connectivity is restored with `NetworkType.connected` constraint.
- **Bookmarks are user-scoped**: each `BookmarkProvider` load is per-userId, supporting the requirement that an offline user can immediately have bookmarks associated.
- `flutter_screenutil` uses a 390×844 design reference (iPhone 14 Pro). All sizes use `.w`, `.h`, `.sp`, `.r` suffixes.
