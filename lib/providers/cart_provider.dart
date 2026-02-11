import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _cartItems = {};

  Map<String, CartItem> get cartItems => _cartItems;

  int get itemCount => _cartItems.length;

  double get totalPrice =>
      _cartItems.values.fold(0, (sum, item) => sum + item.subtotal);

  void addItem(CartItem item) {
    if (_cartItems.containsKey(item.productId)) {
      _cartItems[item.productId]!.quantity += item.quantity;
    } else {
      _cartItems[item.productId] = item;
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _cartItems.remove(productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    if (_cartItems.containsKey(productId)) {
      if (quantity <= 0) {
        _cartItems.remove(productId);
      } else {
        _cartItems[productId]!.quantity = quantity;
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  List<CartItem> getCartItemsList() => _cartItems.values.toList();
}
