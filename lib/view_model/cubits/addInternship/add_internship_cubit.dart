import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../model/internship_model/internship.dart';
import 'add_internship_state.dart';

class AddInternshipCubit extends Cubit<AddInternshipState> {
  AddInternshipCubit() : super(AddInternshipInitial());

  static AddInternshipCubit get(context) => BlocProvider.of<AddInternshipCubit>(context);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;  // أضف FirebaseAuth هنا

  Future<void> addInternship(Internship internship) async {
    emit(AddInternshipLoading());
    try {
      // الحصول على uid المستخدم الحالي
      String uid = _auth.currentUser!.uid;

      // إنشاء معرف فريد للتدريب
      String internshipId = _firestore.collection('internships').doc().id;

      // تحويل كائن التدريب إلى خريطة وإضافة المعرف الفريد و uid
      Map<String, dynamic> internshipData = internship.toMap();
      internshipData['id'] = internshipId;
      internshipData['uid'] = uid;  // إضافة uid الخاص بالمستخدم

      // حفظ بيانات التدريب في Firestore
      await _firestore.collection('internships').doc(internshipId).set(internshipData);

      emit(AddInternshipSuccess());
    } catch (e) {
      emit(AddInternshipFailure(e.toString()));
    }
  }

  Future<void> updateInternship(Internship internship) async {
    emit(AddInternshipLoading());
    try {
      if (internship.id.isEmpty) {
        emit(AddInternshipFailure('Invalid internship UID'));
        return;
      }

      final docRef = _firestore.collection('internships').doc(internship.id);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        emit(AddInternshipFailure('Document with UID ${internship.id} does not exist.'));
        return;
      }

      await docRef.update(internship.toMap());
      emit(AddInternshipSuccess());
    } catch (e) {
      emit(AddInternshipFailure(e.toString()));
    }
  }
}
