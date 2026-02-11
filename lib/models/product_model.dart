class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final String category;
  final String? subcategory;
  final String imageUrl;
  final List<String> imageUrls;
  final int stock;
  final double rating;
  final int reviewCount;
  final DateTime createdAt;
  final List<String> specifications;
  final String? seller;
  final bool isFeatured;
  final String? brand;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.category,
    this.subcategory,
    required this.imageUrl,
    this.imageUrls = const [],
    required this.stock,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.createdAt,
    this.specifications = const [],
    this.seller,
    this.isFeatured = false,
    this.brand,
  });

  // Get discount percentage if original price exists
  int? getDiscount() {
    if (originalPrice == null) return null;
    return (((originalPrice! - price) / originalPrice!) * 100).toInt();
  }

  factory Product.fromMap(String id, Map<String, dynamic> data) {
    final imageUrl = data['imageUrl'] ?? '';
    print('[Product.fromMap] Creating Product id=$id, imageUrl="$imageUrl", data keys=${data.keys}');
    
    // Handle imageUrls: if empty or not provided, use imageUrl
    List<String> imageUrls = [];
    if (data['imageUrls'] is Iterable && (data['imageUrls'] as Iterable).isNotEmpty) {
      imageUrls = List<String>.from(data['imageUrls']);
    } else if (imageUrl.isNotEmpty) {
      imageUrls = [imageUrl];
    }
    
    return Product(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      originalPrice: data['originalPrice'] != null
          ? (data['originalPrice']).toDouble()
          : null,
      category: data['category'] ?? '',
      subcategory: data['subcategory'],
      imageUrl: imageUrl,
      imageUrls: imageUrls,
      stock: data['stock'] ?? 0,
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
      specifications: List<String>.from(data['specifications'] ?? []),
      seller: data['seller'],
      isFeatured: data['isFeatured'] ?? false,
      brand: data['brand'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'category': category,
      'subcategory': subcategory,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls,
      'stock': stock,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdAt': createdAt.toIso8601String(),
      'specifications': specifications,
      'seller': seller,
      'isFeatured': isFeatured,
      'brand': brand,
    };
  }
}
