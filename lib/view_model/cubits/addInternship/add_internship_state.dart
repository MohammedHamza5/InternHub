abstract class AddInternshipState {}

class AddInternshipInitial extends AddInternshipState {}

class AddInternshipLoading extends AddInternshipState {}

class AddInternshipSuccess extends AddInternshipState {}

class AddInternshipFailure extends AddInternshipState {
  final String error;

  AddInternshipFailure(this.error);
}
