class Banner {
  final String id;
  final String title;
  final String? description;
  final String imageUrl;
  final String? link;
  final bool isActive;
  final DateTime createdAt;

  Banner({
    required this.id,
    required this.title,
    this.description,
    required this.imageUrl,
    this.link,
    this.isActive = true,
    required this.createdAt,
  });

  factory Banner.fromMap(String id, Map<String, dynamic> data) {
    return Banner(
      id: id,
      title: data['title'] ?? '',
      description: data['description'],
      imageUrl: data['imageUrl'] ?? '',
      link: data['link'],
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'link': link,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
