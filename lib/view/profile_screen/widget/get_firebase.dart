import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../view_model/cubits/profile/profile_cubit.dart';


class GetUserName extends StatelessWidget {
  final String documentId;

  const GetUserName({required this.documentId, super.key});

  @override
  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    final profileCubit = context.read<ProfileCubit>();
    final credential = FirebaseAuth.instance.currentUser;

    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(documentId).get(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text("Something went wrong");
        }

        if (snapshot.hasData && !snapshot.data!.exists) {
          return const Text("Document does not exist");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;

          return Column(
            children: [
              SizedBox(height: 30.h),
              const Divider(),
              ListTile(
                trailing: IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11.r),
                          ),
                          child: Container(
                            padding: EdgeInsets.all(22.r),
                            height: 200.h,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextField(
                                  controller: profileCubit.editNameController,
                                  maxLength: 20,
                                  decoration: InputDecoration(
                                    hintText: "${data['name']}",
                                  ),
                                ),
                                SizedBox(height: 22.h),
                                TextButton(
                                  onPressed: () {
                                    if (credential != null) {
                                      // Update name in Firestore
                                      users.doc(credential.uid).update({
                                        "name": profileCubit.editNameController.text,
                                      }).then((_) {
                                        // Close the dialog
                                        Navigator.of(context).pop();
                                        // Update ProfileCubit state to reload data
                                        profileCubit.loadProfile();
                                      });
                                    }
                                  },
                                  child: Text(
                                    "Edit",
                                    style: TextStyle(fontSize: 22.sp),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.edit_rounded),
                  color: Colors.black,
                ),
                leading: const Icon(Icons.person_outline_outlined),
                title: Text("Name: ${data['name']}"),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: Text("Email: ${data['email']}"),
              ),
            ],
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
