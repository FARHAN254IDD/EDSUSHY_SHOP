class Category {
  final String id;
  final String name;
  final String? imageUrl;
  final String? description;
  final DateTime createdAt;

  Category({
    required this.id,
    required this.name,
    this.imageUrl,
    this.description,
    required this.createdAt,
  });

  factory Category.fromMap(String id, Map<String, dynamic> data) {
    return Category(
      id: id,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'],
      description: data['description'],
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
