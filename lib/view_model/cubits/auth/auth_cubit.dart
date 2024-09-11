import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
}
