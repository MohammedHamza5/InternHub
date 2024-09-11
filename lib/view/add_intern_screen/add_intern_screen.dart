import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:internhub/view_model/utils/app_colors.dart'; // استدعاء كلاس الألوان
import '../../model/internship_model/internship.dart';
import '../../view_model/cubits/addInternship/add_internship_cubit.dart';
import '../../view_model/cubits/addInternship/add_internship_state.dart';
import '../internhub_main_screen/internhub_main_screen.dart';

class AddInternScreen extends StatefulWidget {
  final Internship? internship;

  const AddInternScreen({super.key, this.internship});

  @override
  _AddInternScreenState createState() => _AddInternScreenState();
}

class _AddInternScreenState extends State<AddInternScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _companyController;
  late TextEditingController _countryController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.internship?.title ?? '');
    _companyController = TextEditingController(text: widget.internship?.company ?? '');
    _countryController = TextEditingController(text: widget.internship?.country ?? '');
    _descriptionController = TextEditingController(text: widget.internship?.description ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _countryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveInternship(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final internship = widget.internship?.copyWith(
        title: _titleController.text,
        company: _companyController.text,
        country: _countryController.text,
        description: _descriptionController.text,
      ) ?? Internship(
        title: _titleController.text,
        company: _companyController.text,
        country: _countryController.text,
        description: _descriptionController.text,
        createdAt: DateTime.now(),
        id: uid,
      );

      if (widget.internship != null) {
        await context.read<AddInternshipCubit>().updateInternship(internship);
      } else {
        await context.read<AddInternshipCubit>().addInternship(internship);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddInternshipCubit(),
      child: Scaffold(
        backgroundColor: AppColors.lightGrayBackground,
        appBar: AppBar(
          title: Text(
            widget.internship != null ? 'Edit Internship' : 'Add Internship',
            style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w400),
          ),
          backgroundColor: AppColors.primaryBlue,
        ),
        body: BlocListener<AddInternshipCubit, AddInternshipState>(
          listener: (context, state) {
            if (state is AddInternshipSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(widget.internship != null
                      ? 'Internship updated successfully!'
                      : 'Internship added successfully!'),
                ),
              );
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const InternHubMainScreen()),
                    (route) => false,
              );
            } else if (state is AddInternshipFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${state.error}')),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Internship Title'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the internship title';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20.h),
                  TextFormField(
                    controller: _companyController,
                    decoration: const InputDecoration(labelText: 'Company Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the company name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20.h),
                  TextFormField(
                    controller: _countryController,
                    decoration: const InputDecoration(labelText: 'Country'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the country';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20.h),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Internship Description'),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the internship description';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 50.h),
                  BlocBuilder<AddInternshipCubit, AddInternshipState>(
                    builder: (context, state) {
                      if (state is AddInternshipLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else {
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                          ),
                          onPressed: () {
                            _saveInternship(context);
                          },
                          child: Text(widget.internship != null ? 'Update' : 'Save'),
                        );
                      }
                    },
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
