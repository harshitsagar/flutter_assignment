// lib/features/movies/presentation/screens/movie_detail_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/movie_entity.dart';
import '../providers/movie_provider.dart';
import '../providers/bookmark_provider.dart';

class MovieDetailScreen extends StatefulWidget {
  final MovieEntity movie;
  final String userId;

  const MovieDetailScreen(
      {super.key, required this.movie, required this.userId});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieProvider>().loadMovieDetail(widget.movie.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<MovieProvider, BookmarkProvider>(
      builder: (context, movieProvider, bookmarkProvider, _) {
        final movie = movieProvider.selectedMovie ?? widget.movie;
        final isBookmarked =
            bookmarkProvider.isBookmarked(widget.userId, movie.id);

        return Scaffold(
          backgroundColor: const Color(0xFF0F0F1A),
          body: CustomScrollView(
            slivers: [
              // Large poster header
              SliverAppBar(
                expandedHeight: 380.h,
                pinned: true,
                backgroundColor: const Color(0xFF1A1F36),
                foregroundColor: Colors.white,
                actions: [
                  IconButton(
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: isBookmarked ? Colors.amber : Colors.white,
                      size: 26.sp,
                    ),
                    onPressed: () =>
                        bookmarkProvider.toggleBookmark(widget.userId, movie),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      movie.fullPosterUrlLarge.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: movie.fullPosterUrlLarge,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                  color: const Color(0xFF1A1F36)),
                              errorWidget: (_, __, ___) => Container(
                                  color: const Color(0xFF1A1F36),
                                  child: Icon(Icons.movie,
                                      size: 64.sp, color: Colors.grey)),
                            )
                          : Container(
                              color: const Color(0xFF1A1F36),
                              child: Icon(Icons.movie,
                                  size: 64.sp, color: Colors.grey)),
                      // Gradient overlay
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              const Color(0xFF0F0F1A).withOpacity(0.9),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                  child: movieProvider.isLoadingDetail
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: Colors.white))
                      : _buildContent(movie, isBookmarked, bookmarkProvider),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(
      MovieEntity movie, bool isBookmarked, BookmarkProvider bookmarkProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          movie.title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.sp,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        SizedBox(height: 10.h),

        // Meta row
        Wrap(
          spacing: 10.w,
          runSpacing: 8.h,
          children: [
            _chip(Icons.calendar_today, movie.formattedDate),
            if (movie.voteAverage > 0)
              _chip(Icons.star_rounded, '${movie.voteAverage.toStringAsFixed(1)} / 10',
                  color: Colors.amber),
          ],
        ),
        SizedBox(height: 20.h),

        // Bookmark button
        SizedBox(
          width: double.infinity,
          height: 48.h,
          child: ElevatedButton.icon(
            onPressed: () =>
                bookmarkProvider.toggleBookmark(widget.userId, movie),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isBookmarked ? Colors.amber.shade700 : Colors.white,
              foregroundColor:
                  isBookmarked ? Colors.white : const Color(0xFF1A1F36),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r)),
            ),
            icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_add,
                size: 18.sp),
            label: Text(
              isBookmarked ? 'Bookmarked' : 'Bookmark This Movie',
              style:
                  TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        SizedBox(height: 24.h),

        // Overview
        if (movie.overview.isNotEmpty) ...[
          Text(
            'Overview',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            movie.overview,
            style: TextStyle(
              color: Colors.grey.shade300,
              fontSize: 14.sp,
              height: 1.6,
            ),
          ),
        ],
        SizedBox(height: 40.h),
      ],
    );
  }

  Widget _chip(IconData icon, String label, {Color? color}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: color ?? Colors.grey.shade300),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
                color: color ?? Colors.grey.shade300, fontSize: 12.sp),
          ),
        ],
      ),
    );
  }
}
