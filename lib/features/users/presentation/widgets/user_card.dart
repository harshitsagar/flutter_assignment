// lib/features/users/presentation/widgets/user_card.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/user_entity.dart';

class UserCard extends StatelessWidget {
  final UserEntity user;
  final VoidCallback onTap;

  const UserCard({super.key, required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Row(
            children: [
              // Avatar
              _buildAvatar(),
              SizedBox(width: 14.w),

              // Name & email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            user.fullName,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1A1F36),
                            ),
                          ),
                        ),
                        if (user.isOffline)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              'Offline',
                              style: TextStyle(
                                  fontSize: 10.sp,
                                  color: Colors.orange.shade800,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                      ],
                    ),
                    if (user.email.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Text(
                        user.email,
                        style: TextStyle(
                            fontSize: 12.sp, color: Colors.grey.shade500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(Icons.movie_outlined,
                            size: 12.sp, color: Colors.grey.shade400),
                        SizedBox(width: 4.w),
                        Text(
                          'View movies',
                          style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Icon(Icons.chevron_right,
                  color: Colors.grey.shade400, size: 20.sp),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (user.isOffline || user.avatar.isEmpty) {
      return CircleAvatar(
        radius: 28.r,
        backgroundColor: const Color(0xFF1A1F36),
        child: Text(
          _initials(),
          style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700),
        ),
      );
    }
    return CircleAvatar(
      radius: 28.r,
      backgroundColor: Colors.grey.shade200,
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: user.avatar,
          width: 56.w,
          height: 56.w,
          fit: BoxFit.cover,
          placeholder: (_, __) => const CircularProgressIndicator(
              strokeWidth: 2, color: Color(0xFF1A1F36)),
          errorWidget: (_, __, ___) => Text(
            _initials(),
            style: TextStyle(
                fontSize: 16.sp, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }

  String _initials() {
    final f =
        user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '';
    final l =
        user.lastName.isNotEmpty ? user.lastName[0].toUpperCase() : '';
    return '$f$l';
  }
}
