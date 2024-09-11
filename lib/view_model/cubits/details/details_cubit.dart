import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

        // تحديث حقل السير الذاتية في Firestore
        final firestoreRef = FirebaseFirestore.instance.collection('internships').doc(internshipUid);

        await firestoreRef.update({
          'cvUrls': FieldValue.arrayUnion([downloadURL])  // إضافة الرابط إلى قائمة السير الذاتية
        });

        // إطلاق حالة النجاح
        emit(DetailsLoaded(downloadURL));
      } else {
        emit(DetailsError('No file selected'));
      }
    } catch (e) {
      if (e is FirebaseException) {
        emit(DetailsError('FirebaseException: ${e.message}'));
      } else if (e is PlatformException) {
        emit(DetailsError('PlatformException: ${e.message}'));
      } else {
        emit(DetailsError('Unexpected error occurred: ${e.toString()}'));
      }
    }
  }

}

