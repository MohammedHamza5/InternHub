import 'package:equatable/equatable.dart';

abstract class DetailsState extends Equatable {
  @override
  List<Object> get props => [];
}

class DetailsInitial extends DetailsState {}

class DetailsLoading extends DetailsState {}

class DetailsLoaded extends DetailsState {
  final String downloadURL;

  DetailsLoaded(this.downloadURL);

  @override
  List<Object> get props => [downloadURL];
}

class DetailsError extends DetailsState {
  final String error;

  DetailsError(this.error);

  @override
  List<Object> get props => [error];
}
