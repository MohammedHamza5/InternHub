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
  String? userRole;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }



  Future<void> _fetchUserRole() async {
    try {
      // الحصول على المستخدم الحالي
      User? user = FirebaseAuth.instance.currentUser;
print(user);
      if (user != null) {
        final uid = user.uid;
        print("Fetching user role...");
        final role = await UserService.getUserRole(uid);
         print(role);
        setState(() {
          userRole = role;
          isLoading = false;
        });
      } else {
        print('Error: User not authenticated');
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

    _pages = [
      const InternshipsPage(),
      const NotificationsScreen(),
      if (userRole == 'company') const AddInternScreen(),
      if (userRole == 'company') const MyInternPage(),
      if (userRole == 'student')  MyApplicationsScreen(),
      ProfileScreen(user: widget.user),
    ];

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
          if (userRole == "company")
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
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: AppColors.secondaryTextColor,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
    );
  }
}