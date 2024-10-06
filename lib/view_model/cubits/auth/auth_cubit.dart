import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../model/users/users_model.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  static AuthCubit get(context) => BlocProvider.of<AuthCubit>(context);

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool hidePassword = true;

  void togglePasswordVisibility() {
    hidePassword = !hidePassword;
    emit(AppPasswordVisibilityChanged());
  }

  Future<void> registerFromFirebase() async {
    emit(RegisterLoading());
    try {
      final UserCredential credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Add user to Firestore
      Users user = Users(
        name: nameController.text,
        uid: credential.user?.uid,
        email: credential.user?.email,
      );

      await addUser(user);

      emit(RegisterSuccess());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        emit(RegisterFailed(errorMassage: 'Weak password: ${e.message}'));
      } else if (e.code == 'email-already-in-use') {
        emit(RegisterFailed(errorMassage: 'Email already in use: ${e.message}'));
      } else {
        emit(RegisterFailed(errorMassage: 'Error during registration: ${e.message}'));
      }
    } catch (e) {
      emit(RegisterFailed(errorMassage: 'Something went wrong during registration: ${e.toString()}'));
    }
  }

  Future<void> addUser(Users user) async {
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
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        emit(LoginFailed(errorMassage: 'User not found: ${e.message}'));
      } else if (e.code == 'wrong-password') {
        emit(LoginFailed(errorMassage: 'Wrong password: ${e.message}'));
      } else {
        emit(LoginFailed(errorMassage: 'Error during login: ${e.message}'));
      }
    } catch (e) {
      emit(LoginFailed(errorMassage: 'Something went wrong during login: ${e.toString()}'));
    }
  }


  Future<void> signInWithGoogle() async {
    emit(GoogleSignInLoading());
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        print("Login cancelled by user");
        emit(AuthInitial()); // العودة إلى الحالة الأولية إذا تم إلغاء التسجيل
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

        // Check if user data already exists
        final doc = await userRef.get();
        if (!doc.exists) {
          // Add user data to Firestore
          await userRef.set({
            'name': user.displayName ?? 'No Name',
            'age': null, // Initialize with null if not available
            'uid': user.uid,
            'email': user.email ?? 'No Email',
            'image': user.photoURL ?? 'assets/images/default_profile.png', // Default image if not available
          });
        }
      }

      print("Successfully signed in with Google");
      emit(GoogleSignInSuccess()); // الإشارة إلى تسجيل الدخول الناجح

    } on FirebaseAuthException catch (e) {
      String errorMessage = '';
      if (e.code == 'account-exists-with-different-credential') {
        errorMessage = 'An account already exists with a different credential.';
      } else if (e.code == 'invalid-credential') {
        errorMessage = 'Invalid credentials. Please try again.';
      } else {
        errorMessage = 'An error occurred during login. Please try again.';
      }
      print('Firebase Auth Error: $errorMessage');
      emit(GoogleSignInFailed(errorMessage: errorMessage)); // الإشارة إلى حدوث خطأ
    } catch (e) {
      print('Error signing in with Google: $e');
      emit(GoogleSignInFailed(errorMessage: 'An unexpected error occurred. Please try again.'));
    }
  }




}
