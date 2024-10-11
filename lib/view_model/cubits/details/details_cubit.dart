import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../model/user_service/user_service.dart';
import 'details_state.dart';

class DetailsCubit extends Cubit<DetailsState> {
  DetailsCubit() : super(DetailsInitial());

  static DetailsCubit get(context) => BlocProvider.of<DetailsCubit>(context);


  Future<void> uploadCV(String internshipUid) async {
    emit(DetailsLoading());

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null) {
        final file = result.files.single;
        final fileName = file.name;
        final filePath = file.path!;

        // رفع الملف إلى Firebase Storage
        final storageRef = FirebaseStorage.instance.ref().child('resumes/$fileName');
        await storageRef.putFile(File(filePath));

        // الحصول على رابط التحميل
        final downloadURL = await storageRef.getDownloadURL();

        // تحديث حقل المتقدمين في وثيقة التدريب
        final internshipRef = FirebaseFirestore.instance.collection('internships').doc(internshipUid);

        final userId = FirebaseAuth.instance.currentUser!.uid;
        final timestamp = DateTime.now().toUtc().toIso8601String();

        await internshipRef.update({
          'applicants': FieldValue.arrayUnion([{
            'userId': userId,
            'cvUrl': downloadURL,
            'dateApplied': timestamp,
          }])
        });

        // إضافة التدريب إلى قائمة تطبيقات المستخدم مع تجنب التكرار
        final userApplicationsRef = FirebaseFirestore.instance.collection('userApplications').doc(userId);

        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final docSnapshot = await transaction.get(userApplicationsRef);
          if (docSnapshot.exists) {
            final applications = List<Map<String, dynamic>>.from(docSnapshot.data()?['applications'] ?? []);
            final existingApplicationIndex = applications.indexWhere((app) => app['internshipId'] == internshipUid);

            if (existingApplicationIndex != -1) {
              // تحديث التطبيق الموجود
              applications[existingApplicationIndex] = {
                'internshipId': internshipUid,
                'dateApplied': timestamp,
                'status': 'pending',
              };
            } else {
              // إضافة تطبيق جديد
              applications.add({
                'internshipId': internshipUid,
                'dateApplied': timestamp,
                'status': 'pending',
              });
            }

            transaction.set(userApplicationsRef, {'applications': applications}, SetOptions(merge: true));
          } else {
            // إنشاء وثيقة جديدة إذا لم تكن موجودة
            transaction.set(userApplicationsRef, {
              'applications': [{
                'internshipId': internshipUid,
                'dateApplied': timestamp,
                'status': 'pending',
              }]
            });
          }
        });

        emit(DetailsLoaded(downloadURL: downloadURL));
      } else {
        emit(DetailsError('No file selected'));
      }
    } catch (e) {
      print('Error: $e');
      if (e is FirebaseException) {
        emit(DetailsError('FirebaseException: ${e.message}'));
      } else if (e is PlatformException) {
        emit(DetailsError('PlatformException: ${e.message}'));
      } else {
        emit(DetailsError('Unexpected error occurred: ${e.toString()}'));
      }
    }
  }


  // Future<void> uploadCV(String internshipUid) async {
  //   emit(DetailsLoading());
  //
  //   try {
  //     final result = await FilePicker.platform.pickFiles(
  //       type: FileType.custom,
  //       allowedExtensions: ['pdf', 'doc', 'docx'],
  //     );
  //
  //     if (result != null) {
  //       final file = result.files.single;
  //       final fileName = file.name;
  //       final filePath = file.path!;
  //
  //       // رفع الملف إلى Firebase Storage
  //       final storageRef = FirebaseStorage.instance.ref().child('resumes/$fileName');
  //       await storageRef.putFile(File(filePath));
  //
  //       // الحصول على رابط التحميل
  //       final downloadURL = await storageRef.getDownloadURL();
  //
  //       // تحديث حقل المتقدمين في وثيقة التدريب
  //       final internshipRef = FirebaseFirestore.instance.collection('internships').doc(internshipUid);
  //
  //       final userId = FirebaseAuth.instance.currentUser!.uid;
  //       final timestamp = DateTime.now().toUtc().toIso8601String();
  //
  //       await internshipRef.update({
  //         'applicants': FieldValue.arrayUnion([{
  //           'userId': userId,
  //           'cvUrl': downloadURL,
  //           'dateApplied': timestamp,
  //         }])
  //       });
  //
  //       // إضافة التدريب إلى قائمة تطبيقات المستخدم
  //       final userApplicationsRef = FirebaseFirestore.instance.collection('userApplications').doc(userId);
  //
  //       await userApplicationsRef.set({
  //         'applications': FieldValue.arrayUnion([{
  //           'internshipId': internshipUid,
  //           'dateApplied': timestamp,
  //           'status': 'pending', // يمكنك تعديل الحالة حسب الحاجة
  //         }])
  //       }, SetOptions(merge: true));
  //
  //       emit(DetailsLoaded(downloadURL: downloadURL));
  //     } else {
  //       emit(DetailsError('No file selected'));
  //     }
  //   } catch (e) {
  //     print('Error: $e');
  //     if (e is FirebaseException) {
  //       emit(DetailsError('FirebaseException: ${e.message}'));
  //     } else if (e is PlatformException) {
  //       emit(DetailsError('PlatformException: ${e.message}'));
  //     } else {
  //       emit(DetailsError('Unexpected error occurred: ${e.toString()}'));
  //     }
  //   }
  // }



  Future<void> fetchUserRole() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final role = await UserService.getUserRole(user.uid);

        String? currentDownloadURL;
        if (state is DetailsLoaded) {
          currentDownloadURL = (state as DetailsLoaded).downloadURL;
        }

        emit(DetailsLoaded(
          userRole: UserRole(role: role),
          downloadURL: currentDownloadURL,
        ));
      } else {
        emit(DetailsError('User not authenticated'));
      }
    } catch (e) {
      emit(DetailsError('Error fetching user role: ${e.toString()}'));
    }
  }

}

