import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../view_model/cubits/Internships/internships_cubit.dart';
import '../../view_model/cubits/Internships/internships_state.dart';
import '../../view_model/utils/app_colors.dart';
import '../add_intern_screen/add_intern_screen.dart';
import '../view_applications_screen/view_applications_screen.dart';

class MyInternPage extends StatelessWidget {
  const MyInternPage({super.key});

  Future<void> _refreshData(BuildContext context) async {
    await context
        .read<InternshipsCubit>()
        .fetchUserInternships(FirebaseAuth.instance.currentUser?.uid ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      return const Scaffold(
        body: Center(child: Text('User ID is empty')),
      );
    }

    return BlocProvider(
      create: (context) => InternshipsCubit()
        ..fetchUserInternships(FirebaseAuth.instance.currentUser?.uid ?? ''),
      child: Scaffold(
        backgroundColor: AppColors.lightGrayBackground,
        appBar: AppBar(
          title: const Text(
            'My Internships',
            style:
                TextStyle(color: AppColors.white, fontWeight: FontWeight.w400),
          ),
          backgroundColor: AppColors.primaryBlue,
        ),
        body: BlocBuilder<InternshipsCubit, InternshipsState>(
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () => _refreshData(context),
              child: state is InternshipsLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state is InternshipsLoaded
                      ? state.internships.isEmpty
                          ? const Center(
                              child: Text('No internships added',
                                  style: TextStyle(
                                      color: AppColors.primaryTextColor)))
                          : ListView.builder(
                              itemCount: state.internships.length,
                              itemBuilder: (context, index) {
                                final internship = state.internships[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 20.0),
                                  child: Column(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.cardBackground
                                              .withOpacity(0.95),
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(15),
                                            topRight: Radius.circular(15),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              spreadRadius: 3,
                                              blurRadius: 7,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: ListTile(
                                          // leading: CircleAvatar(
                                          //   backgroundImage: NetworkImage(internship.companyLogo), // شعار الشركة
                                          // ),
                                          title: Text(
                                            internship.title,
                                            style: TextStyle(
                                              color: AppColors.darkGray,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                          subtitle: Text(
                                            internship.company,
                                            style: TextStyle(
                                                color: AppColors.primaryBlue,
                                                fontSize: 16),
                                          ),
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AddInternScreen(
                                                        internship: internship

                                                    ),
                                              ),
                                            );
                                          },
                                          trailing: IconButton(
                                            icon: Icon(Icons.delete,
                                                color: AppColors.red
                                                    .withOpacity(0.8)),
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                  title: const Text(
                                                      'Confirm Deletion'),
                                                  content: const Text(
                                                      'Are you sure you want to delete this internship?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child:
                                                          const Text('Cancel'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () async {
                                                        try {
                                                          await context
                                                              .read<
                                                                  InternshipsCubit>()
                                                              .deleteInternship(
                                                                  internship
                                                                      .id);
                                                          Navigator.of(context)
                                                              .pop();
                                                          await _refreshData(
                                                              context);
                                                        } catch (e) {
                                                          print(
                                                              'Error in deleting internship: $e');
                                                        }
                                                      },
                                                      child:
                                                          const Text('Delete'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      Divider(
                                        color: AppColors.darkGray,
                                        thickness: 1.5,
                                        indent: 20,
                                        endIndent: 20,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ViewApplicationsScreen(
                                                      internshipId:
                                                          internship.id),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryBlue
                                                .withOpacity(0.1),
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(15),
                                              bottomRight: Radius.circular(15),
                                            ),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 15),
                                          child: Center(
                                            child: Text(
                                              'View applications for this internship',
                                              style: TextStyle(
                                                color:
                                                    AppColors.primaryTextColor,
                                                fontWeight: FontWeight.w500,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                      : state is InternshipsEmpty
                          ? const Center(
                              child: Text('No internships added',
                                  style: TextStyle(
                                      color: AppColors.primaryTextColor)))
                          : state is InternshipsError
                              ? Center(
                                  child: Text('Error: ${state.message}',
                                      style: const TextStyle(
                                          color: AppColors.red)))
                              : const SizedBox(),
            );
          },
        ),
      ),
    );
  }
}
