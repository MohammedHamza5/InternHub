import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:internhub/view_model/utils/app_colors.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ViewApplicationsScreen extends StatelessWidget {
  final String internshipId;

  const ViewApplicationsScreen({Key? key, required this.internshipId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrayBackground,
      appBar: AppBar(
        title: const Text(
          'Submitted Resumes',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w400),
        ),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('internships').doc(internshipId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error fetching data'));
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No resumes found'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final cvUrls = List<String>.from(data['cvUrls'] ?? []);

          if (cvUrls.isEmpty) {
            return const Center(child: Text('No resumes submitted yet'));
          }

          return ListView.builder(
            itemCount: cvUrls.length,
            itemBuilder: (context, index) {
              final cvUrl = cvUrls[index];
              return ListTile(
                title: Text('Resume ${index + 1}'),
                trailing: IconButton(
                  icon: const Icon(Icons.visibility, color: AppColors.primaryBlue),
                  onPressed: () {
                    _openPDFView(context, cvUrl);
                  },
                ),
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
              title:  Text('PDF Viewer' , style: TextStyle(color: AppColors.white),),
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