import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../model/user_service.dart';
import '../../view/internhub_main_screen/internhub_main_screen.dart';
import 'package:internhub/view_model/utils/app_navigation.dart';
import '../../view_model/utils/app_colors.dart';

enum UserRole { student, company }

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  @override
  _RoleSelectionScreenState createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  UserRole? selectedRole;
  int? selectedAge;
  final TextEditingController companyNameController = TextEditingController();
  final List<int> ages = List<int>.generate(7, (int index) => 16 + index);
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryBlue.withOpacity(0.8),
                AppColors.primaryGreen.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Your Role',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Are you a student or a company?',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<UserRole>(
                          title: const Text('Student', style: TextStyle(color: Colors.white)),
                          value: UserRole.student,
                          groupValue: selectedRole,
                          activeColor: AppColors.primaryGreen,
                          onChanged: (UserRole? value) {
                            setState(() {
                              selectedRole = value;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<UserRole>(
                          title: const Text('Company', style: TextStyle(color: Colors.white)),
                          value: UserRole.company,
                          groupValue: selectedRole,
                          activeColor: AppColors.primaryGreen,
                          onChanged: (UserRole? value) {
                            setState(() {
                              selectedRole = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  if (selectedRole == UserRole.student)
                    DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: 'Select Age',
                        labelStyle: TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: ages.map((int age) {
                        return DropdownMenuItem<int>(
                          value: age,
                          child: Text(age.toString(), style: TextStyle(color: Colors.black)),
                        );
                      }).toList(),
                      value: selectedAge,
                      onChanged: (int? newValue) {
                        setState(() {
                          selectedAge = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select your age';
                        }
                        return null;
                      },
                    ),
                  if (selectedRole == UserRole.company)
                    TextFormField(
                      controller: companyNameController,
                      decoration: InputDecoration(
                        labelText: 'Company Name',
                        labelStyle: TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your company name';
                        }
                        return null;
                      },
                    ),
                  const Spacer(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      padding: EdgeInsets.symmetric(
                        vertical: 12.h,
                        horizontal: 24.w,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate() && selectedRole != null) {
                        try {
                          await _updateUserData();
                          await AppNavigation.pushAndRemove(context, const InternHubMainScreen());
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: ${e.toString()}')),
                          );
                        }
                      } else if (selectedRole == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select a role')),
                        );
                      }
                    },
                    child: const Text('Continue', style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _updateUserData() async {
    final updatedData = <String, dynamic>{
      'role': selectedRole.toString().split('.').last,
    };

    if (selectedRole == UserRole.student && selectedAge != null) {
      updatedData['age'] = selectedAge;
    }

    if (selectedRole == UserRole.company && companyNameController.text.isNotEmpty) {
      updatedData['companyName'] = companyNameController.text;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await UserService.updateUserData(uid, updatedData);
    } else {
      throw Exception('User not authenticated');
    }
  }
}