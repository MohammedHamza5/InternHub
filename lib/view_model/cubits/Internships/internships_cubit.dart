import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../model/internship_model/internship.dart';
import 'internships_state.dart';

class InternshipsCubit extends Cubit<InternshipsState> {
  InternshipsCubit() : super(InternshipsInitial());

  static InternshipsCubit get(context) => BlocProvider.of<InternshipsCubit>(context);

  List<Internship> allInternships = [];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> fetchInternships() async {
    emit(InternshipsLoading());
    try {
      final querySnapshot = await _firestore.collection('internships').get();
      final internships = querySnapshot.docs.map((doc) => Internship.fromDocument(doc)).toList();

      allInternships = internships;

      if (internships.isEmpty) {
        emit(InternshipsEmpty());
      } else {
        emit(InternshipsLoaded(internships));
      }
    } catch (e) {
      emit(InternshipsError(e.toString()));
    }
  }

  Future<void> fetchUserInternships(String uid) async {
    emit(InternshipsLoading());

    try {
      if (uid.isEmpty) {
        emit(InternshipsError('User ID is empty'));
        return;
      }

      // جلب التدريبات التي تخص المستخدم الحالي فقط
      final querySnapshot = await _firestore
          .collection('internships')
          .where('uid', isEqualTo: uid)
          .get();

      final internships = querySnapshot.docs
          .map((doc) => Internship.fromDocument(doc))
          .toList();

      // تحديث المتغير allInternships مع البيانات الجديدة
      allInternships = internships;

      // إصدار الحالة المناسبة بناءً على عدد التدريبات
      if (internships.isEmpty) {
        emit(InternshipsEmpty());
      } else {
        emit(InternshipsLoaded(internships));
      }
    } catch (e) {
      // التعامل مع الأخطاء وتقديم رسالة خطأ
      emit(InternshipsError('Failed to fetch internships: ${e.toString()}'));
    }
  }


  void filterInternships(String query) {
    if (query.isEmpty) {
      emit(InternshipsLoaded(allInternships));
    } else {
      final filteredInternships = allInternships.where((internship) =>
      internship.title.toLowerCase().startsWith(query.toLowerCase()) ||
          internship.company.toLowerCase().startsWith(query.toLowerCase())).toList();

      if (filteredInternships.isEmpty) {
        emit(InternshipsEmpty());
      } else {
        emit(InternshipsLoaded(filteredInternships));
      }
    }
  }

  Future<void> deleteInternship(String internshipId) async {
    try {
      print('Attempting to delete internship with ID: $internshipId');
      await _firestore.collection('internships').doc(internshipId).delete();
      print('Internship deleted successfully.');

      final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
      final updatedInternships = await _fetchUserInternships(currentUserId);

      if (!isClosed) {
        emit(InternshipsLoaded(updatedInternships));
      }
    } catch (e) {
      print('Error in deleting internship: ${e.toString()}');
      if (!isClosed) {
        emit(InternshipsError('Failed to delete internship: ${e.toString()}'));
      }
    }
  }

  Future<List<Internship>> _fetchUserInternships(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('internships')
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs.map((doc) => Internship.fromDocument(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch internships: ${e.toString()}');
    }
  }

  Future<void> delete(int index) async {
    allInternships.removeAt(index);
    emit(InternshipsLoaded(List.from(allInternships)));
  }
}
