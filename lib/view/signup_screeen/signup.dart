import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:internhub/view/signin_screen/signin.dart';
import 'package:internhub/view_model/utils/app_colors.dart';
import '../../view_model/cubits/auth/auth_cubit.dart';
import '../../view_model/utils/app_assets.dart';
import '../../view_model/utils/app_navigation.dart';

class Signup extends StatelessWidget {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Signup({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blueBlack,
      body: SafeArea(
        top: true,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  Image.asset(
                    AppAssets.logo2,
                    width: double.infinity,
                    height: 128,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: 24.h),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  BlocProvider(
                    create: (context) => AuthCubit(),
                    child: BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Name field
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: TextFormField(
                                controller:
                                    AuthCubit.get(context).nameController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your name';
                                  }
                                  return null;
                                },
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                onTapOutside: (_) {
                                  FocusManager.instance.primaryFocus!.unfocus();
                                },
                                decoration: InputDecoration(
                                  labelText: 'Name',
                                  labelStyle: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 14.sp,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppColors.green,
                                      width: 2.w,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppColors.purpleA,
                                      width: 2.w,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20.h),
                            // Email field
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: TextFormField(
                                controller:
                                    AuthCubit.get(context).emailController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!RegExp(
                                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                                      .hasMatch(value)) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                onTapOutside: (_) {
                                  FocusManager.instance.primaryFocus!.unfocus();
                                },
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  labelStyle: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 14.sp,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppColors.green,
                                      width: 2.w,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppColors.purpleA,
                                      width: 2.w,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20.h),
                            // Password field
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: TextFormField(
                                controller:
                                    AuthCubit.get(context).passwordController,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                onTapOutside: (_) {
                                  FocusManager.instance.primaryFocus!.unfocus();
                                },
                                obscureText:
                                    AuthCubit.get(context).hidePassword,
                                obscuringCharacter: '*',
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  labelStyle: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 14.sp,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppColors.green,
                                      width: 2.w,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppColors.purpleA,
                                      width: 2.w,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      AuthCubit.get(context)
                                          .togglePasswordVisibility();
                                    },
                                    icon: Icon(
                                      AuthCubit.get(context).hidePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: AppColors.black54,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20.h),
                            // Confirm Password field
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: TextFormField(
                                controller: AuthCubit.get(context)
                                    .confirmPasswordController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please confirm your password';
                                  }
                                  if (value !=
                                      AuthCubit.get(context)
                                          .passwordController
                                          .text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                onTapOutside: (_) {
                                  FocusManager.instance.primaryFocus!.unfocus();
                                },
                                obscureText:
                                    AuthCubit.get(context).hidePassword,
                                obscuringCharacter: '*',
                                decoration: InputDecoration(
                                  labelText: 'Confirm Password',
                                  labelStyle: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 14.sp,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppColors.green,
                                      width: 2.w,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppColors.purpleA,
                                      width: 2.w,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      AuthCubit.get(context)
                                          .togglePasswordVisibility();
                                    },
                                    icon: Icon(
                                      AuthCubit.get(context).hidePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: AppColors.black54,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 30.h),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: state is RegisterLoading
                                  ? const CircularProgressIndicator()
                                  : ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.green,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 100.w, vertical: 14.h),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14.r),
                                        ),
                                      ),
                                      onPressed: () async {
                                        if (formKey.currentState!.validate()) {
                                         await AuthCubit.get(context)
                                              .registerFromFirebase();
                                          Future.delayed(Duration.zero, () {
                                            AppNavigation.pushAndRemove(
                                              context,
                                              SignInPage(),
                                            );
                                          });
                                        }
                                      },
                                      child: Text(
                                        'Sign Up',
                                        style: TextStyle(
                                            color: AppColors.white,
                                            fontSize: 18.sp),
                                      ),
                                    ),
                            ),
                            SizedBox(height: 30.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already have account?',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    AppNavigation.navigateTo(
                                        context, SignInPage());
                                  },
                                  child: Text(
                                    'SignIn',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      decoration: TextDecoration.underline,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
