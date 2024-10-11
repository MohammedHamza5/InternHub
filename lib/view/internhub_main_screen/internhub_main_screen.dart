import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:internhub/view/my_intern_page/my_intern_page.dart';
import '../../model/user_service.dart';
import '../../view_model/utils/app_colors.dart';
import '../add_intern_screen/add_intern_screen.dart';
import '../applications_screen/applications_screen.dart';
import '../home_screen/home_screen.dart';
import '../notifications_screen/notifications_screen.dart';
import '../profile_screen/profile_screen.dart';

class InternHubMainScreen extends StatefulWidget {
  final User? user;

  const InternHubMainScreen({Key? key, this.user}) : super(key: key);

  @override
  _InternHubMainScreenState createState() => _InternHubMainScreenState();
}

class _InternHubMainScreenState extends State<InternHubMainScreen> {
  int _selectedIndex = 0;
  late List<Widget> _pages;
  late List<BottomNavigationBarItem> _navItems;
  String? userRole;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final uid = user.uid;
        final role = await UserService.getUserRole(uid);
        setState(() {
          userRole = role;
          isLoading = false;
        });
      } else {
        throw Exception('User not authenticated');
      }
    } catch (e) {
      print('Error fetching user role: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.lightGrayBackground,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // بناء القوائم بناءً على دور المستخدم
    if (userRole == 'company') {
      _pages = [
        const InternshipsPage(),
        const NotificationsScreen(),
        const AddInternScreen(),
        const MyInternPage(),
        ProfileScreen(user: widget.user),
      ];

      _navItems = [
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
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Container(
                width: 35.w,
                height: 35.h,
                decoration: const BoxDecoration(
                  color: AppColors.lightGray,
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
          icon: Icon(Icons.account_balance_sharp),
          label: 'My Internship',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    } else if (userRole == 'student') {
      _pages = [
        const InternshipsPage(),
        const NotificationsScreen(),
        MyApplicationsScreen(),
        ProfileScreen(user: widget.user),
      ];

      _navItems = [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.notifications_active),
          label: 'Notifications',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_sharp),
          label: 'My Applications',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    } else {
      // حالة افتراضية إذا لم يكن الدور 'company' أو 'student'
      _pages = [
        const InternshipsPage(),
        const NotificationsScreen(),
        ProfileScreen(user: widget.user),
      ];

      _navItems = [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.notifications_active),
          label: 'Notifications',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    }

    // التأكد من أن _selectedIndex لا يتجاوز طول _pages
    if (_selectedIndex >= _pages.length) {
      _selectedIndex = 0;
    }

    return Scaffold(
      backgroundColor: AppColors.lightGrayBackground,
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.primaryBlue,
        items: _navItems,
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: AppColors.secondaryTextColor,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
    );
  }
}
