import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileLoading()) {
    currentUser = FirebaseAuth.instance.currentUser;
    loadProfile();
  }

  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  File? imgPath;
  User? currentUser;

  TextEditingController editNameController = TextEditingController();

  Future<void> loadProfile() async {
    try {
      if (currentUser == null) {
        emit(ProfileError('User not logged in'));
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      if (userDoc.exists) {
        final name = userDoc['name'] ?? 'User123';
        editNameController.text = name;
        emit(ProfileLoaded(image: userDoc['image'], name: name));
      } else {
        emit(ProfileLoaded(image: null, name: 'User123'));
      }
    } catch (e) {
      emit(ProfileError('Failed to load profile: ${e.toString()}'));
    }
  }

  Future<void> saveProfile() async {
    try {
      if (currentUser == null) {
        emit(ProfileError('User not logged in'));
        return;
      }

      final image = state is ProfileLoaded ? (state as ProfileLoaded).image : null;
      final name = editNameController.text.isNotEmpty ? editNameController.text : 'User123';

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .update({
        'image': image,
        'name': name,
      });

      emit(ProfileLoaded(image: image, name: name));
    } catch (e) {
      emit(ProfileError('Failed to save profile: ${e.toString()}'));
    }
  }

  Future<void> pickProfileImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imgPath = File(pickedFile.path);
      await uploadProfileImage();
    }
  }

  Future<void> uploadProfileImage() async {
    if (imgPath != null) {
      try {
        final storageRef = _firebaseStorage.ref('profile_images/${currentUser!.uid}/${DateTime.now().toIso8601String()}');
        final uploadTask = storageRef.putFile(imgPath!);

        final snapshot = await uploadTask.whenComplete(() {});
        final downloadUrl = await snapshot.ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .update({'image': downloadUrl});

        if (state is ProfileLoaded) {
          emit((state as ProfileLoaded).copyWith(image: downloadUrl));
        } else {
          emit(ProfileLoaded(image: downloadUrl, name: editNameController.text));
        }
      } catch (e) {
        emit(ProfileError('Failed to upload image: ${e.toString()}'));
      }
    }
  }

  @override
  Future<void> close() {
    editNameController.dispose();
    return super.close();
  }
}
