import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart' as order_model;

class OrderProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<order_model.Order> _userOrders = [];
  List<order_model.Order> _allOrders = [];
  bool _isLoading = false;

  List<order_model.Order> get userOrders => _userOrders;
  List<order_model.Order> get allOrders => _allOrders;
  bool get isLoading => _isLoading;

  Future<void> fetchUserOrders(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      _userOrders = snapshot.docs
          .map((doc) => order_model.Order.fromMap(doc.id, doc.data()))
          .toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching user orders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllOrders() async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _firestore
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .get();
      _allOrders = snapshot.docs
          .map((doc) => order_model.Order.fromMap(doc.id, doc.data()))
          .toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching all orders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createOrder(order_model.Order order) async {
    try {
      await _firestore.collection('orders').add(order.toMap());
    } catch (e) {
      print('Error creating order: $e');
      rethrow;
    }
  }

  Future<void> updateOrderStatus(String orderId, order_model.OrderStatus status) async {
    try {
      await _firestore
          .collection('orders')
          .doc(orderId)
          .update({'status': status.toString().split('.').last});
      await fetchAllOrders();
      notifyListeners();
    } catch (e) {
      print('Error updating order: $e');
    }
  }

  Future<void> updatePaymentStatus(String orderId, String status) async {
    try {
      await _firestore
          .collection('orders')
          .doc(orderId)
          .update({'paymentStatus': status});
      await fetchAllOrders();
    } catch (e) {
      print('Error updating payment status: $e');
    }
  }

  Future<void> cancelOrder(String orderId, {String? refundReason}) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': 'cancelled',
        'cancelledAt': DateTime.now().toIso8601String(),
        'refundReason': refundReason,
      });
      await fetchAllOrders();
    } catch (e) {
      print('Error cancelling order: $e');
      rethrow;
    }
  }

  Future<void> requestRefund(String orderId, {String? reason}) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': 'returnFunds',
        'refundRequested': true,
        'refundReason': reason ?? 'User requested refund',
        'refundRequestedAt': DateTime.now().toIso8601String(),
      });
      await fetchAllOrders();
    } catch (e) {
      print('Error requesting refund: $e');
      rethrow;
    }
  }

  Future<void> confirmPayment(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'paymentStatus': 'confirmed',
        'status': 'confirmed',
        'confirmedAt': DateTime.now().toIso8601String(),
      });
      await fetchAllOrders();
    } catch (e) {
      print('Error confirming payment: $e');
      rethrow;
    }
  }
}
