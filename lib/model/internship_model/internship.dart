import 'package:cloud_firestore/cloud_firestore.dart';

class Internship {
  final String title;
  final String company;
  final String country;
  final String description;
  final DateTime createdAt;
  final String id;

  Internship({
    required this.title,
    required this.company,
    required this.country,
    required this.description,
    required this.createdAt,
    required this.id,
  });

  Internship copyWith({
    String? title,
    String? company,
    String? country,
    String? description,
    DateTime? createdAt,
    String? id,
  }) {
    return Internship(
      title: title ?? this.title,
      company: company ?? this.company,
      country: country ?? this.country,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      id: id ?? this.id,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'company': company,
      'country': country,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'id': id,
    };
  }

  static Internship fromMap(Map<String, dynamic> map) {
    return Internship(
      title: map['title'],
      company: map['company'],
      country: map['country'],
      description: map['description'],
      id: map['id'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  factory Internship.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Internship(
      title: data['title'] ?? '',
      company: data['company'] ?? '',
      country: data['country'] ?? '',
      description: data['description'] ?? '',
      id: data['id'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
