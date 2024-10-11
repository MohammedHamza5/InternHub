import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:internhub/view_model/utils/app_colors.dart';
import '../../../model/internship_model/internship.dart';
import '../../view_model/cubits/details/details_cubit.dart';
import '../../view_model/cubits/details/details_state.dart';

class InternDetails extends StatelessWidget {
  final Internship internship;
  final bool isAlreadyApplied;

  InternDetails({
    Key? key,
    required this.internship,
    this.isAlreadyApplied = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DetailsCubit()..fetchUserRole(),
      child: Scaffold(
        backgroundColor: AppColors.lightGrayBackground,
        appBar: AppBar(
          title: Text(
            internship.title,
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w400,
            ),
          ),
          backgroundColor: AppColors.primaryBlue,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocConsumer<DetailsCubit, DetailsState>(
            listener: (context, state) {
              if (state is DetailsLoaded && state.downloadURL != null && state.downloadURL!.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('CV uploaded Successfully')),
                );
              } else if (state is DetailsError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${state.error}')),
                );
              }
            },
            builder: (context, state) {
              if (state is DetailsLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is DetailsLoaded) {
                return SingleChildScrollView( // إضافة التمرير هنا
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        internship.title,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryTextColor,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        internship.company,
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: AppColors.secondaryTextColor,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        "Country: ${internship.country}",
                        style: TextStyle(
                            fontSize: 16.sp, color: AppColors.primaryTextColor),
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
                        style: TextStyle(
                            fontSize: 16.sp, color: AppColors.primaryTextColor),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        "Posted on: ${internship.createdAt.toLocal()}",
                        style: TextStyle(
                          color: AppColors.secondaryTextColor,
                        ),
                      ),
                       SizedBox(height: 40.h),
                      Center(
                        child: state.userRole?.role == 'student' && !isAlreadyApplied
                            ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            padding: EdgeInsets.symmetric(
                              vertical: 10.h,
                              horizontal: 25.w,
                            ),
                          ),
                          onPressed: () {
                            context.read<DetailsCubit>().uploadCV(internship.id);
                          },
                          child: Text('Send Resume'),
                        )
                            : isAlreadyApplied
                            ? Text(
                          'You have already applied for this internship',
                          style: TextStyle(
                            color: AppColors.secondaryTextColor,
                            fontStyle: FontStyle.italic,
                          ),
                        )
                            : SizedBox.shrink(),
                      ),
                    ],
                  ),
                );
              } else if (state is DetailsError) {
                return Center(child: Text('Error: ${state.error}'));
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ),
      ),
    );
  }
}