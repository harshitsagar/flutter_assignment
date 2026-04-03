// lib/features/users/presentation/screens/user_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/user_card.dart';
import '../widgets/reconnecting_banner.dart';
import '../../domain/entities/user_entity.dart';
import '../../../movies/presentation/screens/movie_list_screen.dart';
import 'add_user_screen.dart';
import '../../../../core/di/service_locator.dart';
import '../../../movies/presentation/providers/bookmark_provider.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  late UserProvider _provider;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _provider = sl<UserProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.loadUsers();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _provider.loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Consumer<UserProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: const Color(0xFFF5F7FA),
            appBar: AppBar(
              elevation: 0,
              backgroundColor: const Color(0xFF1A1F36),
              title: Text(
                'Users',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              actions: [
                if (!provider.isOnline)
                  Padding(
                    padding: EdgeInsets.only(right: 12.w),
                    child: Icon(Icons.wifi_off, color: Colors.orange, size: 20.sp),
                  ),
              ],
            ),
            body: Column(
              children: [
                // Reconnecting banner
                if (provider.isReconnecting)
                  const ReconnectingBanner(),

                // Offline badge
                if (!provider.isOnline)
                  Container(
                    width: double.infinity,
                    color: Colors.orange.shade100,
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.w, vertical: 6.h),
                    child: Row(
                      children: [
                        Icon(Icons.cloud_off,
                            size: 14.sp, color: Colors.orange.shade800),
                        SizedBox(width: 6.w),
                        Text(
                          'Offline mode — new users will sync when connected',
                          style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.orange.shade800),
                        ),
                      ],
                    ),
                  ),

                Expanded(
                  child: _buildBody(provider),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              backgroundColor: const Color(0xFF1A1F36),
              onPressed: () => _navigateToAddUser(context),
              icon: const Icon(Icons.person_add, color: Colors.white),
              label: Text(
                'Add User',
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(UserProvider provider) {
    if (provider.state == UserLoadState.loading && provider.users.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1A1F36)),
      );
    }

    if (provider.state == UserLoadState.error && provider.users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48.sp, color: Colors.red.shade300),
            SizedBox(height: 12.h),
            Text(provider.errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600)),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () => provider.loadUsers(refresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final users = provider.users;

    return RefreshIndicator(
      color: const Color(0xFF1A1F36),
      onRefresh: () => provider.loadUsers(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        itemCount: users.length + (provider.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == users.length) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF1A1F36)),
              ),
            );
          }
          return UserCard(
            user: users[index],
            onTap: () => _navigateToMovies(context, users[index]),
          );
        },
      ),
    );
  }

  void _navigateToMovies(BuildContext context, UserEntity user) {
    final bookmarkProvider = sl<BookmarkProvider>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: bookmarkProvider,
          child: MovieListScreen(user: user),
        ),
      ),
    );
  }

  void _navigateToAddUser(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: _provider,
          child: const AddUserScreen(),
        ),
      ),
    );
    // Refresh offline users list on return
    _provider.loadOfflineUsers();
  }
}
