import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:internhub/view/internhub_main_screen/internhub_main_screen.dart';
import 'package:internhub/view/role_selection_screen/role_selection_screen.dart';
import 'package:internhub/view/signin_screen/signin.dart';

class InternHub extends StatelessWidget {
  const InternHub({super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Text("Loading..."),
                );
              } else if (snapshot.hasError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Something went wrong"),
                  ),
                );
                return const SizedBox();
              } else if (snapshot.hasData) {
                return  InternHubMainScreen();
              } else {
                return  SignInScreen();
              }
            },
          ),
        );
      },
    );
  }
}
