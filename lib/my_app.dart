import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:internhub/view/internhub_main_screen/internhub_main_screen.dart';
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
          home: child,
        );
      },
      child:   const InternHubMainScreen(),
    );
  }
}
