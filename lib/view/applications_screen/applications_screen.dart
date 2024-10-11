import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../model/internship_model/internship.dart';
import '../../view_model/utils/app_colors.dart';
import '../../view_model/utils/app_navigation.dart';
import '../intern_details/intern_details.dart';

class MyApplicationsScreen extends StatelessWidget {
  const MyApplicationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: AppColors.lightGrayBackground,
      appBar: AppBar(
        title: Text(
            'My Applications',
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w400,
          ),
        ),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('userApplications')
            .doc(userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('No applications found.'));
          }

          final applications = List<Map<String, dynamic>>.from(
              snapshot.data!['applications'] ?? []);

          // إزالة التطبيقات المكررة
          final uniqueApplications = applications
              .fold<Map<String, Map<String, dynamic>>>(
                {},
                (map, application) {
                  final internshipId = application['internshipId'];
                  if (!map.containsKey(internshipId) ||
                      DateTime.parse(application['dateApplied']).isAfter(
                          DateTime.parse(map[internshipId]!['dateApplied']))) {
                    map[internshipId] = application;
                  }
                  return map;
                },
              )
              .values
              .toList();

          return ListView.builder(
            itemCount: uniqueApplications.length,
            itemBuilder: (context, index) {
              final application = uniqueApplications[index];
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('internships')
                    .doc(application['internshipId'])
                    .get(),
                builder: (context, internshipSnapshot) {
                  if (internshipSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return ListTile(title: Text('Loading...'));
                  }
                  if (internshipSnapshot.hasError ||
                      !internshipSnapshot.hasData) {
                    return ListTile(
                        title: Text('Error loading internship details'));
                  }

                  final internship =
                      Internship.fromDocument(internshipSnapshot.data!);

                  return Card(
                    color: AppColors.cardBackground,
                    margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                    elevation: 12,
                    child: ListTile(
                      title: Text(internship.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Company: ${internship.company}'),
                          Text('Country: ${internship.country}'),
                          Text(
                              'Applied on: ${_formatDate(application['dateApplied'])}'),
                          Text('Status: ${application['status'] ?? 'Unknown'}'),
                        ],
                      ),
                      onTap: () {
                        AppNavigation.navigateTo(
                            context,
                            InternDetails(
                              internship: internship,
                              isAlreadyApplied: true,
                            ));
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
