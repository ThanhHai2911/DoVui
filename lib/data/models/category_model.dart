import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String name;
  final String image;
  final int order;
  final String type; // 👈 QUAN TRỌNG

  CategoryModel({
    required this.id,
    required this.name,
    required this.image,
    required this.order,
    required this.type,
  });

  factory CategoryModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    return CategoryModel(
      id: doc.id,
      name: data?['name'] ?? '',
      image: data?['image'] ?? '',
      order: data?['order'] ?? 0,
      type: data?['type'] ?? 'direct', // default an toàn
    );
  }
}