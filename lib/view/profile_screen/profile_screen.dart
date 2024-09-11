import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:internhub/view/profile_screen/widget/get_firebase.dart';
import 'package:internhub/view/signin_screen/signin.dart';
import 'package:internhub/view_model/cubits/profile/profile_cubit.dart';
import 'package:internhub/view_model/cubits/profile/profile_state.dart';
import 'package:internhub/view_model/utils/app_colors.dart';
import '../../view_model/utils/app_navigation.dart';

class ProfileScreen extends StatelessWidget {
  final User? user;
  final User? credential = FirebaseAuth.instance.currentUser;

  ProfileScreen({required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileCubit()..loadProfile(),
      child: Scaffold(
        backgroundColor: AppColors.lightGrayBackground,
        appBar: AppBar(
          title: const Text(
            'Profile',
            style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w400),
          ),
          backgroundColor: AppColors.primaryBlue,
          actions: [
            IconButton(
              onPressed: () {
                _showLogoutConfirmationDialog(context);  // استدعاء دالة لعرض رسالة التأكيد
              },
              icon: const Icon(Icons.logout, size: 24.0, color: AppColors.white),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ProfileLoaded) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 30.h),
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 70,
                          backgroundColor: AppColors.darkGray,
                          backgroundImage: state.image != null
                              ? NetworkImage(state.image!)
                              : const AssetImage('assets/images/default_profile.png') as ImageProvider,
                          child: state.image == null
                          ? null
                              : null,
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
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GetUserName(documentId: credential?.uid ?? ''),
                    ),
                    SizedBox(height: 20.h),
                    GestureDetector(
                      onTap: () async {
                        final confirm = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirm Deletion'),
                            content: const Text('Are you sure you want to delete your account?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        if (confirm) {
                          await _deleteAccount(context);
                        }
                      },
                      child: const Text(
                        'Delete Account',
                        style: TextStyle(
                          color: AppColors.primaryTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SizedBox(height: 30.h),
                  ],
                );
              } else if (state is ProfileError) {
                return Center(child: Text(state.message));
              } else {
                return Container();
              }
            },
          ),
        ),
      ),
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No user is currently logged in')),
      );
      return;
    }

    try {
      // طلب إعادة مصادقة المستخدم
      String? password = await _showPasswordDialog(context);
      if (password == null) return;

      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      // إعادة مصادقة المستخدم
      await user.reauthenticateWithCredential(credential);

      // حذف الحساب
      await user.delete();

      // حذف بيانات المستخدم من Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();

      // تسجيل الخروج وتوجيه المستخدم إلى شاشة تسجيل الدخول
      await auth.signOut();
      AppNavigation.pushAndRemove(context, SignInPage());
    } catch (e) {
      String errorMessage;
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-mismatch':
            errorMessage = 'The provided credentials do not match the current user.';
            break;
          case 'wrong-password':
            errorMessage = 'The password is incorrect. Please try again.';
            break;
          case 'user-not-found':
            errorMessage = 'No user found with this email.';
            break;
          default:
            errorMessage = 'An error occurred. Please try again later.';
        }
      } else {
        errorMessage = 'An unexpected error occurred.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $errorMessage')),
      );
    }
  }

  Future<String?> _showPasswordDialog(BuildContext context) async {
    final TextEditingController passwordController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Password'),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Enter your password',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(passwordController.text),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout Confirmation'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog without logging out
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Proceed with logout
                AppNavigation.pushAndRemove(context, SignInPage());
              },
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );
  }
}
