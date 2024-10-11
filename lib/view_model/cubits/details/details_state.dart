import 'package:equatable/equatable.dart';

abstract class DetailsState extends Equatable {
  @override
  List<Object> get props => [];
}

class DetailsInitial extends DetailsState {}

class DetailsLoading extends DetailsState {}
class UserRole extends Equatable {
  final String? role;

  UserRole({this.role});

  @override
  List<Object?> get props => [role];
}
class DetailsLoaded extends DetailsState {
  final String? downloadURL;
  final UserRole? userRole;

  DetailsLoaded({this.downloadURL, this.userRole});

  @override
  List<Object> get props => [downloadURL ?? "", userRole ?? ''];
}

class DetailsError extends DetailsState {
  final String error;

  DetailsError(this.error);

  @override
  List<Object> get props => [error];
}