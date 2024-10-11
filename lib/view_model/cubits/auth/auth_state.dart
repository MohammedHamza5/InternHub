// auth_state.dart
part of 'auth_cubit.dart';

abstract class AuthState {}

enum UserRole { student, company }

class AuthInitial extends AuthState {}

// State when registration is in progress
class RegisterLoading extends AuthState {}

// State when registration is successful
class RegisterSuccess extends AuthState {}

// State when registration fails
class RegisterFailed extends AuthState {
  final String errorMassage;
  RegisterFailed({required this.errorMassage});
}

// State when login is in progress
class LoginLoading extends AuthState {}

// State when login is successful
class LoginSuccess extends AuthState {}

// State when login fails
class LoginFailed extends AuthState {
  final String errorMassage;
  LoginFailed({required this.errorMassage});
}

// State when password visibility is toggled
class AppPasswordVisibilityChanged extends AuthState {}

// Google Sign-In States
class GoogleSignInSuccess extends AuthState {}
class GoogleSignInLoading extends AuthState {}
class GoogleSignInFailed extends AuthState {
  final String errorMessage;
  GoogleSignInFailed({
    required this.errorMessage,
  });
}

// Account Deletion States
class AuthDeletingAccount extends AuthState {}
class AuthAccountDeleted extends AuthState {}
class AuthDeleteAccountFailed extends AuthState {
  final String errorMessage;
  AuthDeleteAccountFailed({
    required this.errorMessage,
  });
}
// حالة المصادقة الناجحة مع بيانات المستخدم
class Authenticated extends AuthState {
  final UserModel user;

  Authenticated({required this.user});
}
// State for role selection
class RoleSelected extends AuthState {
  final UserRole selectedRole;
  RoleSelected({required this.selectedRole});
}
class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String? userRole; // تخزين دور المستخدم

  AuthAuthenticated({this.userRole});
}

class AuthError extends AuthState {
  final String error;

  AuthError(this.error);
}