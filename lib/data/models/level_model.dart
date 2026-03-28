class LevelModel {
  final String id;
  final String name;
  final int order;
  

  LevelModel({
    required this.id,
    required this.name,
    required this.order,
    
  });

  factory LevelModel.fromDoc(doc) {
    final data = doc.data();
    return LevelModel(
      id: doc.id,
      name: data['name'] ?? '',
      order: data['order'] ?? 0,
      
    );
  }
}