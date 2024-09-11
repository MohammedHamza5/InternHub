
class Users {
  String? name;
  int? age;
  String? uid;
  String? email;
  String? image;

  Users({
    this.name,
    this.age,
    this.uid,
    this.email,
    this.image,
  });

  factory Users.fromJson(Map<String, dynamic> json) => Users(
    name: json['name'],
    age: json['age'],
    uid: json['uid'],
    email: json['email'],
    image: json['image'],
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'age': age,
    'uid': uid,
    'email': email,
    'image': image,
  };
}
