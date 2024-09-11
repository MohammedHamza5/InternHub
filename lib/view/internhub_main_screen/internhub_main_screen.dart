import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:internhub/view/my_intern_page/my_intern_page.dart';
import '../../view_model/utils/app_colors.dart';
import '../add_intern_screen/add_intern_screen.dart';
import '../home_screen/home_screen.dart';
import '../notifications_screen/notifications_screen.dart';
import '../profile_screen/profile_screen.dart';

class InternHubMainScreen extends StatefulWidget {
  final User? user;

  const InternHubMainScreen({super.key, this.user});

  @override
  _InternHubMainScreenState createState() => _InternHubMainScreenState();
}

class _InternHubMainScreenState extends State<InternHubMainScreen> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const InternshipsPage(),
      const NotificationsScreen(),
      const AddInternScreen(),
      ProfileScreen(user: widget.user),
      const MyInternPage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrayBackground,
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.primaryBlue,
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Container(
              width: 45.w,
              height: 45.h,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.green,
                    Colors.greenAccent,
                    Colors.blue,
                  ], // تدرج الألوان حول الأيقونة
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Container(
                  width: 35.w, // حجم الدائرة البيضاء الداخلية
                  height: 35.h,
                  decoration: const BoxDecoration(
                    color: AppColors.lightGray, // خلفية بيضاء
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add,
                    size: 25.sp,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_sharp),
            label: 'My Internship',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor:
            AppColors.primaryGreen,
        unselectedItemColor:
            AppColors.secondaryTextColor,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
    );
  }
}
