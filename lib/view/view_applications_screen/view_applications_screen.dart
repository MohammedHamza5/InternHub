import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:internhub/view_model/utils/app_colors.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class ViewApplicationsScreen extends StatelessWidget {
  final String internshipId;

  const ViewApplicationsScreen({Key? key, required this.internshipId})
      : super(key: key);

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Date not available';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(date); // Format: 01 Jan 2023
    } catch (e) {
      print('Error parsing date: $e');
      return 'Invalid date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrayBackground,
      appBar: AppBar(
        title: const Text(
          'Submitted Applications',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w400),
        ),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('internships')
            .doc(internshipId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('Error fetching data: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No data found'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final applicants = data['applicants'] as List<dynamic>?;

          if (applicants == null || applicants.isEmpty) {
            return const Center(child: Text('No applications submitted yet'));
          }

          return ListView.builder(
            itemCount: applicants.length,
            itemBuilder: (context, index) {
              final applicant = applicants[index] as Map<String, dynamic>;
              final cvUrl = applicant['cvUrl'] as String?;
              final dateApplied = applicant['dateApplied'] as String?;
              final formattedDate = _formatDate(dateApplied);

              return ListTile(
                title: Text('Application ${index + 1}'),
                subtitle: Text('Applied on: $formattedDate'),
                trailing: cvUrl != null
                    ? IconButton(
                        icon: const Icon(Icons.visibility,
                            color: AppColors.primaryBlue),
                        onPressed: () => _openPDFView(context, cvUrl),
                      )
                    : null,
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _openPDFView(BuildContext context, String url) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      // Download the PDF file
      final response = await http.get(Uri.parse(url));
      final bytes = response.bodyBytes;

      // Get temporary directory
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/resume.pdf');

      // Write the file
      await file.writeAsBytes(bytes);

      // Close loading indicator
      Navigator.of(context).pop();

      // Open PDF viewer
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: Text(
                'PDF Viewer',
                style: TextStyle(color: AppColors.white),
              ),
              backgroundColor: AppColors.primaryBlue,
            ),
            body: PDFView(
              filePath: file.path,
            ),
            backgroundColor: AppColors.lightGrayBackground,
          ),
        ),
      );
    } catch (e) {
      // Close loading indicator if it's still showing
      Navigator.of(context).pop();

      print('Error opening PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening the file: ${e.toString()}'),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}
