import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:internhub/view_model/utils/app_assets.dart';
import '../../view_model/cubits/auth/auth_cubit.dart';
import '../../view_model/utils/app_navigation.dart';
import '../../view_model/utils/app_colors.dart';
import '../internhub_main_screen/internhub_main_screen.dart';
import '../signup_screeen/signup.dart';

class SignInPage extends StatelessWidget {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(),
      child: Scaffold(
        backgroundColor: AppColors.blueBlack,
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: formKey,
                child: BlocConsumer<AuthCubit, AuthState>(
                  listener: (context, state) {
                    if (state is LoginSuccess || state is GoogleSignInSuccess) {
                      Future.delayed(Duration.zero, () {
                        AppNavigation.pushAndRemove(
                            context, const InternHubMainScreen());
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Login Successfully"),
                          ),
                        );
                      });
                    } else if (state is LoginFailed ||
                        state is GoogleSignInFailed) {
                      final errorMessage = state is LoginFailed
                          ? state.errorMassage
                          : (state as GoogleSignInFailed).errorMessage;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(errorMessage),
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                            'Sign In',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: TextFormField(
                            controller: AuthCubit.get(context).emailController,
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
                        SizedBox(height: 30.h),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: TextFormField(
                            controller:
                                AuthCubit.get(context).passwordController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            onTapOutside: (_) {
                              FocusManager.instance.primaryFocus!.unfocus();
                            },
                            obscureText: AuthCubit.get(context).hidePassword,
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
                        SizedBox(height: 30.h),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: state is LoginLoading
                              ? const CircularProgressIndicator()
                              : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.green,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 110.w, vertical: 14.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14.r),
                                    ),
                                  ),
                                  onPressed: () {
                                    if (formKey.currentState!.validate()) {
                                      AuthCubit.get(context)
                                          .signInFromFirebase();
                                    }
                                  },
                                  child: Text(
                                    'Sign In',
                                    style: TextStyle(
                                        color: AppColors.white,
                                        fontSize: 18.sp),
                                  ),
                                ),
                        ),
                        SizedBox(height: 20.h),
                        TextButton(
                          onPressed: () {
                            // Implement forgot password
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: AppColors.white,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        SizedBox(height: 30.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Don\'t have an account?',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 14.sp,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                AppNavigation.navigateTo(context, Signup());
                              },
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  decoration: TextDecoration.underline,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                            ),
                            onPressed: () {
                              AuthCubit.get(context).signInWithGoogle();
                            },
                            icon: Image.asset(
                              AppAssets.googleLogo,
                              height: 24.h,
                              width: 24.w,
                            ),
                            label: Text(
                              'Sign in with Google',
                              style: TextStyle(
                                  color: AppColors.black, fontSize: 16.sp),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
