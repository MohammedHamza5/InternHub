import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:internhub/view_model/utils/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  Future<void> _refreshNotifications(BuildContext context) async {
    // Simulate fetching new data
    // Replace this with your actual data fetching logic
    await Future.delayed(const Duration(seconds: 2));
    // Example: context.read<NotificationsCubit>().fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    // Sample data for notifications
    final notifications = [
      {'title': 'New Internship Opportunity', 'message': 'Check out the latest internship opportunities that match your profile.', 'time': '2 hours ago'},
      {'title': 'Profile Update Required', 'message': 'Please update your profile information to continue receiving relevant notifications.', 'time': '1 day ago'},
      {'title': 'Application Status', 'message': 'Your application for the Software Engineering internship has been reviewed.', 'time': '3 days ago'},
    ];

    return Scaffold(
      backgroundColor: AppColors.lightGrayBackground,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w400),
        ),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshNotifications(context),
        child: notifications.isEmpty
            ? Center(
          child: Text(
            'No notifications available',
            style: TextStyle(color: AppColors.primaryTextColor, fontSize: 16.sp), // Using ScreenUtil for responsive text size
          ),
        )
            : ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return ListTile(
              leading: const Icon(
                Icons.notifications,
                color: AppColors.primaryBlue,
              ),
              title: Text(
                notification['title']!,
                style: TextStyle(color: AppColors.primaryTextColor, fontWeight: FontWeight.bold, fontSize: 18.sp),
              ),
              subtitle: Text(
                notification['message']!,
                style: TextStyle(color: AppColors.primaryTextColor, fontSize: 16.sp),
              ),
              trailing: Text(
                notification['time']!,
                style: TextStyle(color: AppColors.primaryTextColor, fontSize: 14.sp),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
            );
          },
        ),
      ),
    );
  }
}
