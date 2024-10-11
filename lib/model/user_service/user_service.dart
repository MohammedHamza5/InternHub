import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:internhub/model/users/users_model.dart';

class UserService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // تحديث بيانات المستخدم
  static Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      print('Error updating user data: $e');
      throw Exception('Failed to update user data');
    }
  }

  // جلب دور المستخدم
  static Future<String?> getUserRole(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>?;
        if (data != null) {
          return data['role'] as String?;
        } else {
          print('User document data is null');
          return null;
        }
      } else {
        print('User document does not exist for UID: $uid');
        return null;
      }
    } catch (e) {
      print('Error fetching user role: $e');
      throw Exception('Failed to fetch user role');
    }
  }

  // جلب بيانات المستخدم بالكامل
  static Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>?;
        if (data != null) {
          return UserModel.fromJson(data);
        } else {
          print('User document data is null');
          return null;
        }
      } else {
        print('User document does not exist for UID: $uid');
        return null;
      }
    } catch (e) {
      print('Error fetching user data: $e');
      throw Exception('Failed to fetch user data');
    }
  }
}