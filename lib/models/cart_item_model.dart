class CartItem {
  final String productId;
  final String productName;
  final double price;
  int quantity;
  final String imageUrl;

  CartItem({
    required this.productId,
    required this.productName,
    required this.price,
    this.quantity = 1,
    required this.imageUrl,
  });

  double get subtotal => price * quantity;

  CartItem copyWith({
    String? productId,
    String? productName,
    double? price,
    int? quantity,
    String? imageUrl,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
