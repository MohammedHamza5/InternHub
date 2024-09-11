import '../../../model/internship_model/internship.dart';

abstract class InternshipsState {}

class InternshipsInitial extends InternshipsState {}

class InternshipsLoading extends InternshipsState {}

class InternshipsLoaded extends InternshipsState {
  final List<Internship> internships;

  InternshipsLoaded(this.internships);
}

class InternshipsEmpty extends InternshipsState {}
class Deleted extends InternshipsState {}


class InternshipsError extends InternshipsState {
  final String message;

  InternshipsError(this.message);
}
