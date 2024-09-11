part of 'auth_cubit.dart';

abstract class AuthState {}

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
