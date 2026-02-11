class Wishlist {
  final String id;
  final String userId;
  final List<String> productIds;
  final DateTime createdAt;

  Wishlist({
    required this.id,
    required this.userId,
    required this.productIds,
    required this.createdAt,
  });

  factory Wishlist.fromMap(String id, Map<String, dynamic> data) {
    return Wishlist(
      id: id,
      userId: data['userId'] ?? '',
      productIds: List<String>.from(data['productIds'] ?? []),
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'productIds': productIds,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
