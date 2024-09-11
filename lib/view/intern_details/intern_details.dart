import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:internhub/view_model/cubits/details/details_cubit.dart';
import 'package:internhub/view_model/utils/app_colors.dart'; // استدعاء كلاس الألوان
import '../../../model/internship_model/internship.dart';
import '../../view_model/cubits/details/details_state.dart';

class InternDetails extends StatelessWidget {
  final Internship internship;

  const InternDetails({super.key, required this.internship});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DetailsCubit(),
      child: Scaffold(
        backgroundColor: AppColors.lightGrayBackground,
        appBar: AppBar(
          title: Text(
            internship.title,
            style: const TextStyle(
              color: AppColors.white,  // استخدام اللون الأبيض من كلاس الألوان
              fontWeight: FontWeight.w400,
            ),
          ),
          backgroundColor: AppColors.primaryBlue,  // اللون الأزرق الأساسي
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocConsumer<DetailsCubit, DetailsState>(
            listener: (context, state) {
              if (state is DetailsLoaded) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('CV uploaded successfully!')),
                );
              } else if (state is DetailsError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.error)),
                );
              }
            },
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    internship.title,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryTextColor,  // اللون الأساسي للنصوص
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    internship.company,
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: AppColors.secondaryTextColor,  // اللون الثانوي للنصوص
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    "Country: ${internship.country}",
                    style: TextStyle(fontSize: 16.sp, color: AppColors.primaryTextColor),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    "Description:",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryTextColor,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    internship.description,
                    style: TextStyle(fontSize: 16.sp, color: AppColors.primaryTextColor),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    "Posted on: ${internship.createdAt.toLocal()}",
                    style: TextStyle(color: AppColors.secondaryTextColor,),
                  ),
                  const Spacer(),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<DetailsCubit>().uploadCV(internship.id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,  // اللون الأخضر للأزرار
                        padding: EdgeInsets.symmetric(
                          vertical: 10.h,
                          horizontal: 25.w,
                        ),
                      ),
                      child: state is DetailsLoading
                          ? const CircularProgressIndicator(color: AppColors.white)
                          : Text(
                        'Send Resume',
                        style: TextStyle(fontSize: 16.sp, color: AppColors.white),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}