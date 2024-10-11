import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:internhub/view/intern_details/intern_details.dart';
import 'package:internhub/view_model/utils/app_navigation.dart';
import 'package:internhub/view_model/utils/app_colors.dart'; // استدعاء كلاس الألوان
import '../../../model/internship_model/internship.dart';

class InternshipCard extends StatelessWidget {
  final Internship internship;

  const InternshipCard({super.key, required this.internship});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        AppNavigation.navigateTo(context, InternDetails(internship: internship));
      },
      child: Card(
        color: AppColors.cardBackground,
        margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        elevation: 12,
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                internship.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                  color: AppColors.primaryBlue, // اللون الأزرق للنص
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                internship.company,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.primaryTextColor, // اللون الأساسي للنصوص
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                internship.createdAt.toString(),
                style: const TextStyle(color: AppColors.secondaryTextColor),  // اللون الثانوي للنصوص
              ),
            ],
          ),
        ),
      ),
    );
  }
}