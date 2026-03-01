import 'package:cloud_firestore/cloud_firestore.dart';

class TopicModel {
  final String id;
  final String name;
  final String image;
  final String category; 

  TopicModel({
    required this.id,
    required this.name,
    required this.image,
    required this.category,
  });
  factory TopicModel.fromMap(Map<String, dynamic> data) {
    return TopicModel(
      id: '',
      name: data['name'] ?? '',
      image: data['image'] ?? '',
      category: data['category'] ?? '', 
    );
  }
}