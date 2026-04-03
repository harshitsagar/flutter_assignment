// lib/features/movies/presentation/screens/movie_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../providers/bookmark_provider.dart';
import '../widgets/movie_card.dart';
import '../../domain/entities/movie_entity.dart';
import '../../../users/domain/entities/user_entity.dart';
import 'movie_detail_screen.dart';
import '../../../../core/di/service_locator.dart';
import '../../../users/presentation/widgets/reconnecting_banner.dart';

class MovieListScreen extends StatefulWidget {
  final UserEntity user;
  const MovieListScreen({super.key, required this.user});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen>
    with SingleTickerProviderStateMixin {
  late MovieProvider _movieProvider;
  late BookmarkProvider _bookmarkProvider;
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _movieProvider = sl<MovieProvider>();
    _bookmarkProvider = context.read<BookmarkProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _movieProvider.loadMovies();
      await _bookmarkProvider.loadBookmarks(widget.user.id);
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _movieProvider.loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _movieProvider),
        ChangeNotifierProvider.value(value: _bookmarkProvider),
      ],
      child: Consumer2<MovieProvider, BookmarkProvider>(
        builder: (context, movieProvider, bookmarkProvider, _) {
          return Scaffold(
            backgroundColor: const Color(0xFFF5F7FA),
            appBar: AppBar(
              backgroundColor: const Color(0xFF1A1F36),
              foregroundColor: Colors.white,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Movies',
                    style: TextStyle(
                        fontSize: 18.sp, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Browsing as ${widget.user.fullName}',
                    style:
                        TextStyle(fontSize: 11.sp, color: Colors.grey.shade300),
                  ),
                ],
              ),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey.shade400,
                labelStyle: TextStyle(
                    fontSize: 13.sp, fontWeight: FontWeight.w600),
                tabs: [
                  const Tab(text: 'Trending'),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Bookmarks'),
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade700,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            '${bookmarkProvider.getBookmarksForUser(widget.user.id).length}',
                            style: TextStyle(
                                fontSize: 10.sp, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            body: Column(
              children: [
                if (movieProvider.isReconnecting)
                  const ReconnectingBanner(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildMovieList(movieProvider, bookmarkProvider),
                      _buildBookmarkList(bookmarkProvider),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMovieList(
      MovieProvider movieProvider, BookmarkProvider bookmarkProvider) {
    if (movieProvider.state == MovieLoadState.loading &&
        movieProvider.movies.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFF1A1F36)));
    }

    if (movieProvider.state == MovieLoadState.error &&
        movieProvider.movies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.movie_filter_outlined,
                size: 48.sp, color: Colors.grey.shade400),
            SizedBox(height: 12.h),
            Text(movieProvider.errorMessage,
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontSize: 14.sp, color: Colors.grey.shade600)),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () => movieProvider.loadMovies(refresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF1A1F36),
      onRefresh: () => movieProvider.loadMovies(refresh: true),
      child: GridView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(16.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 0.58,
        ),
        itemCount: movieProvider.movies.length +
            (movieProvider.isLoadingMore ? 2 : 0),
        itemBuilder: (context, index) {
          if (index >= movieProvider.movies.length) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF1A1F36)));
          }
          final movie = movieProvider.movies[index];
          return MovieCard(
            movie: movie,
            isBookmarked:
                bookmarkProvider.isBookmarked(widget.user.id, movie.id),
            onTap: () => _navigateToDetail(context, movie, bookmarkProvider),
            onBookmark: () =>
                bookmarkProvider.toggleBookmark(widget.user.id, movie),
          );
        },
      ),
    );
  }

  Widget _buildBookmarkList(BookmarkProvider bookmarkProvider) {
    final bookmarks =
        bookmarkProvider.getBookmarksForUser(widget.user.id);
    if (bookmarks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border,
                size: 56.sp, color: Colors.grey.shade300),
            SizedBox(height: 12.h),
            Text(
              'No bookmarks yet',
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500),
            ),
            SizedBox(height: 6.h),
            Text(
              'Bookmark movies from the Trending tab',
              style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade400),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 0.58,
      ),
      itemCount: bookmarks.length,
      itemBuilder: (context, index) {
        final movie = bookmarks[index];
        return MovieCard(
          movie: movie,
          isBookmarked: true,
          onTap: () => _navigateToDetail(context, movie, bookmarkProvider),
          onBookmark: () =>
              bookmarkProvider.toggleBookmark(widget.user.id, movie),
        );
      },
    );
  }

  void _navigateToDetail(BuildContext context, MovieEntity movie,
      BookmarkProvider bookmarkProvider) {
    final movieProvider = sl<MovieProvider>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: movieProvider),
            ChangeNotifierProvider.value(value: bookmarkProvider),
          ],
          child: MovieDetailScreen(
            movie: movie,
            userId: widget.user.id,
          ),
        ),
      ),
    );
  }
}
