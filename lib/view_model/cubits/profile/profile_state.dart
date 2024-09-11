abstract class ProfileState {
  const ProfileState();
}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final String? image;
  final String? name;

  const ProfileLoaded({this.image, this.name});

  ProfileLoaded copyWith({String? image, String? name}) {
    return ProfileLoaded(
      image: image ?? this.image,
      name: name ?? this.name,
    );
  }
}


class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);
}
