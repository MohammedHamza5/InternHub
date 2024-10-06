abstract class ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final String? image;
  final String? name;
  final bool isImageUploading;

  ProfileLoaded({this.image, this.name, this.isImageUploading = false});

  ProfileLoaded copyWith({
    String? image,
    String? name,
    bool? isImageUploading,
  }) {
    return ProfileLoaded(
      image: image ?? this.image,
      name: name ?? this.name,
      isImageUploading: isImageUploading ?? this.isImageUploading,
    );
  }
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}