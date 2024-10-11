class UserModel {
  String? name;
  int? age;
  String? uid;
  String? email;
  String? image;
  String? role;
  String? companyName;

  UserModel({
    this.role,
    this.name,
    this.age,
    this.uid,
    this.email,
    this.image,
    this.companyName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    name: json['name'],
    age: json['age'],
    uid: json['uid'],
    email: json['email'],
    image: json['image'],
    role: json['role'],
    companyName: json['companyName'],
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'age': age,
    'uid': uid,
    'email': email,
    'image': image,
    'role': role,
    'companyName': companyName,
  };
}
