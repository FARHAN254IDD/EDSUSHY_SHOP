enum OrderStatus { 
  unpaid,           // Payment initiated but not yet completed
  toBeShipped,      // Payment completed, ready for shipping
  shipped,          // Order has been shipped
  toBeReviewed,     // Delivered, awaiting review
  returnFunds,      // Customer requested return/refund
  cancelled 
}

enum PaymentMethod { mpesa, card, paypal }

class OrderItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
  });

  double get subtotal => price * quantity;

  factory OrderItem.fromMap(Map<String, dynamic> data) {
    return OrderItem(
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      quantity: data['quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
    };
  }
}

class Order {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double totalAmount;
  final OrderStatus status;
  final PaymentMethod paymentMethod;
  final String paymentStatus;
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final String shippingAddress;
  final String transactionId;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    this.status = OrderStatus.unpaid,
    required this.paymentMethod,
    this.paymentStatus = 'pending',
    required this.createdAt,
    this.deliveredAt,
    required this.shippingAddress,
    this.transactionId = '',
  });

  factory Order.fromMap(String id, Map<String, dynamic> data) {
    return Order(
      id: id,
      userId: data['userId'] ?? '',
      items: (data['items'] as List?)
              ?.map((item) => OrderItem.fromMap(item))
              .toList() ??
          [],
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      status: OrderStatus.values.firstWhere(
        (status) => status.toString().split('.').last == data['status'],
        orElse: () => OrderStatus.unpaid,
      ),
      paymentMethod: PaymentMethod.values.firstWhere(
        (method) => method.toString().split('.').last == data['paymentMethod'],
        orElse: () => PaymentMethod.mpesa,
      ),
      paymentStatus: data['paymentStatus'] ?? 'pending',
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
      deliveredAt: data['deliveredAt'] != null
          ? DateTime.parse(data['deliveredAt'])
          : null,
      shippingAddress: data['shippingAddress'] ?? '',
      transactionId: data['transactionId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status.toString().split('.').last,
      'paymentMethod': paymentMethod.toString().split('.').last,
      'paymentStatus': paymentStatus,
      'createdAt': createdAt.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'shippingAddress': shippingAddress,
      'transactionId': transactionId,
    };
  }
}
