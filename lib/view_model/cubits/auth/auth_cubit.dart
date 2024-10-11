import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../model/user_service.dart';
import '../../../model/users/users_model.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  static AuthCubit get(context) => BlocProvider.of<AuthCubit>(context);

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool hidePassword = true;

  // المتغير لإدارة دور المستخدم
  UserRole _selectedRole = UserRole.student; // الافتراضي هو الطالب

  UserRole get selectedRole => _selectedRole;

  void togglePasswordVisibility() {
    hidePassword = !hidePassword;
    emit(AppPasswordVisibilityChanged());
  }

  // دالة لتغيير دور المستخدم
  void selectRole(UserRole role) {
    _selectedRole = role;
    emit(RoleSelected(selectedRole: role));
  }

  Future<void> registerFromFirebase() async {
    emit(RegisterLoading());
    try {
      final UserCredential credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      UserModel user = UserModel(
        name: nameController.text,
        uid: credential.user?.uid,
        email: credential.user?.email,
      );

      await addUser(user);

      emit(RegisterSuccess());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        emit(RegisterFailed(errorMassage: 'كلمة مرور ضعيفة: ${e.message}'));
      } else if (e.code == 'email-already-in-use') {
        emit(RegisterFailed(
            errorMassage: 'البريد الإلكتروني مستخدم بالفعل: ${e.message}'));
      } else {
        emit(RegisterFailed(errorMassage: 'خطأ أثناء التسجيل: ${e.message}'));
      }
    } catch (e) {
      emit(RegisterFailed(
          errorMassage: 'حدث خطأ أثناء التسجيل: ${e.toString()}'));
    }
  }

  Future<void> addUser(UserModel user) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set(user.toJson());
  }

  Future<void> signInFromFirebase() async {
    emit(LoginLoading());
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      emit(LoginSuccess());
      // يمكنك هنا استرجاع دور المستخدم من Firestore إذا لزم الأمر
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        emit(LoginFailed(errorMassage: 'المستخدم غير موجود: ${e.message}'));
      } else if (e.code == 'wrong-password') {
        emit(LoginFailed(errorMassage: 'كلمة المرور خاطئة: ${e.message}'));
      } else {
        emit(LoginFailed(errorMassage: 'خطأ أثناء تسجيل الدخول: ${e.message}'));
      }
    } catch (e) {
      emit(LoginFailed(
          errorMassage: 'حدث خطأ أثناء تسجيل الدخول: ${e.toString()}'));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(GoogleSignInLoading());
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        print("تم إلغاء تسجيل الدخول بواسطة المستخدم");
        emit(AuthInitial()); // العودة إلى الحالة الأولية إذا تم إلغاء التسجيل
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        final userRef =
            FirebaseFirestore.instance.collection('users').doc(user.uid);

        // التحقق مما إذا كانت بيانات المستخدم موجودة بالفعل
        final doc = await userRef.get();
        if (!doc.exists) {
          // إضافة بيانات المستخدم إلى Firestore
          await userRef.set({
            'name': user.displayName ?? 'لا يوجد اسم',
            'uid': user.uid,
            'email': user.email ?? 'لا يوجد بريد إلكتروني',
            'role':
                'student', // تعيين الدور الافتراضي كطالب أو يمكنك تعديل ذلك حسب الحاجة
            'image': user.photoURL ??
                'assets/images/default_profile.png', // صورة افتراضية إذا لم تكن متوفرة
          });
        }
      }

      print("تم تسجيل الدخول بنجاح باستخدام Google");
      emit(GoogleSignInSuccess()); // الإشارة إلى تسجيل الدخول الناجح
    } on FirebaseAuthException catch (e) {
      String errorMessage = '';
      if (e.code == 'account-exists-with-different-credential') {
        errorMessage = 'يوجد حساب بالفعل باستخدام بيانات اعتماد مختلفة.';
      } else if (e.code == 'invalid-credential') {
        errorMessage = 'بيانات الاعتماد غير صالحة. يرجى المحاولة مرة أخرى.';
      } else {
        errorMessage = 'حدث خطأ أثناء تسجيل الدخول. يرجى المحاولة مرة أخرى.';
      }
      print('Firebase Auth Error: $errorMessage');
      emit(GoogleSignInFailed(
          errorMessage: errorMessage)); // الإشارة إلى حدوث خطأ
    } catch (e) {
      print('خطأ أثناء تسجيل الدخول باستخدام Google: $e');
      emit(GoogleSignInFailed(
          errorMessage: 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.'));
    }
  }

  // تسجيل الخروج
  // Future<void> signOut() async {
  //   await _auth.signOut();
  //   await SharedPrefs.clearUserRole();
  //   emit(AuthInitial());
  // }

  Future<void> deleteAccount(String uid, {String? password}) async {
    emit(AuthDeletingAccount());

    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      final User? user = auth.currentUser;

      if (user == null) {
        emit(AuthDeleteAccountFailed(
            errorMessage: 'لا يوجد مستخدم مسجل دخوله حالياً.'));
        return;
      }
      // إعادة المصادقة بناءً على مزود المصادقة
      List<UserInfo> providers = user.providerData;
      if (providers.isNotEmpty) {
        String providerId = providers.first.providerId;
        if (providerId == 'password') {
          if (password == null) {
            emit(AuthDeleteAccountFailed(
                errorMessage: 'كلمة المرور مطلوبة لإعادة المصادقة.'));
            return;
          }
          AuthCredential credential = EmailAuthProvider.credential(
              email: user.email!, password: password);
          await user.reauthenticateWithCredential(credential);
        } else if (providerId == 'google.com') {
          // إعادة المصادقة باستخدام Google
          final GoogleSignIn googleSignIn = GoogleSignIn();
          final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
          if (googleUser == null) {
            emit(AuthDeleteAccountFailed(
                errorMessage: 'تم إلغاء تسجيل الدخول بواسطة Google.'));
            return;
          }
          final GoogleSignInAuthentication googleAuth =
              await googleUser.authentication;
          final AuthCredential googleCredential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          await user.reauthenticateWithCredential(googleCredential);
        }
        // التعامل مع مزودات أخرى إذا وجدت
      }

      // حذف البيانات من Firestore و Storage
      await _deleteUserDataFromFirestore(uid);
      await _deleteUserFilesFromStorage(uid);

      // حذف المستخدم من Firebase Auth
      await user.delete();

      // تسجيل الخروج
      await auth.signOut();

      emit(AuthAccountDeleted());
    } on FirebaseAuthException catch (e) {
      emit(AuthDeleteAccountFailed(errorMessage: _mapFirebaseAuthException(e)));
    } catch (e) {
      emit(AuthDeleteAccountFailed(errorMessage: e.toString()));
    }
  }

  Future<void> _deleteUserDataFromFirestore(String uid) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // قائمة المجموعات المتعلقة بالمستخدم
    List<String> collections = ['users', 'internships', 'applications'];

    for (String collection in collections) {
      final QuerySnapshot snapshot = await firestore
          .collection(collection)
          .where('uid', isEqualTo: uid)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    }
  }

  Future<void> _deleteUserFilesFromStorage(String uid) async {
    final FirebaseStorage storage = FirebaseStorage.instance;

    // حذف صورة الملف الشخصي
    try {
      await storage.ref('profile_pictures/$uid.jpg').delete();
    } catch (e) {
      // التعامل مع عدم وجود الملف
      print('لا توجد صورة ملف شخصي للمستخدم $uid');
    }

    // حذف ملفات أخرى إذا وجدت
    try {
      // على سبيل المثال، السيرة الذاتية المخزنة تحت 'resumes/{uid}/'
      final ListResult result = await storage.ref('resumes/$uid/').listAll();
      for (var item in result.items) {
        await item.delete();
      }
    } catch (e) {
      print('لا توجد سير ذاتية للمستخدم $uid');
    }
  }

  String _mapFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-mismatch':
        return 'بيانات الاعتماد المقدمة لا تطابق المستخدم الحالي.';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة. يرجى المحاولة مرة أخرى.';
      case 'user-not-found':
        return 'لا يوجد مستخدم بهذا البريد الإلكتروني.';
      case 'weak-password':
        return 'كلمة المرور ضعيفة للغاية.';
      case 'email-already-in-use':
        return 'هذا البريد الإلكتروني مستخدم بالفعل.';
      case 'account-exists-with-different-credential':
        return 'يوجد حساب بالفعل باستخدام بيانات اعتماد مختلفة.';
      case 'invalid-credential':
        return 'بيانات الاعتماد غير صالحة.';
      default:
        return 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.';
    }
  }



}
