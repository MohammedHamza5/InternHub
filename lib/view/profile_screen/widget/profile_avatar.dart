import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../view_model/cubits/profile/profile_cubit.dart';
import '../../../view_model/utils/app_colors.dart';

class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;

  const ProfileAvatar({Key? key, this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 70,
          backgroundColor: AppColors.darkGray,
          backgroundImage: imageUrl != null
              ? NetworkImage(imageUrl!)
              : const AssetImage('assets/images/default_profile.png') as ImageProvider,
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: CircleAvatar(
            backgroundColor: AppColors.darkGray,
            radius: 18,
            child: IconButton(
              icon: Icon(
                Icons.edit,
                size: 18.sp,
                color: AppColors.white,
              ),
              onPressed: () async {
                await context.read<ProfileCubit>().pickProfileImage();
              },
            ),
          ),
        ),
      ],
    );
  }
}
