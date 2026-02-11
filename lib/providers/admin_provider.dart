import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';
import '../models/banner_model.dart' as banner_model;
import '../models/notification_model.dart';

class AdminProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<Category> _categories = [];
  List<banner_model.Banner> _banners = [];
  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<Category> get categories => _categories;
  List<banner_model.Banner> get banners => _banners;
  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // ============ CATEGORIES ============
  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _firestore.collection('categories').get();
      _categories = snapshot.docs
          .map((doc) => Category.fromMap(doc.id, doc.data()))
          .toList();
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Error fetching categories: $e';
      print(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCategory(String name, {String? imageUrl, String? description}) async {
    try {
      await _firestore.collection('categories').add({
        'name': name,
        'imageUrl': imageUrl,
        'description': description,
        'createdAt': DateTime.now().toIso8601String(),
      });
      await fetchCategories();
    } catch (e) {
      _errorMessage = 'Error adding category: $e';
      print(_errorMessage);
      rethrow;
    }
  }

  Future<void> updateCategory(String categoryId, String name, {String? imageUrl, String? description}) async {
    try {
      await _firestore.collection('categories').doc(categoryId).update({
        'name': name,
        'imageUrl': imageUrl,
        'description': description,
      });
      await fetchCategories();
    } catch (e) {
      _errorMessage = 'Error updating category: $e';
      print(_errorMessage);
      rethrow;
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      await _firestore.collection('categories').doc(categoryId).delete();
      await fetchCategories();
    } catch (e) {
      _errorMessage = 'Error deleting category: $e';
      print(_errorMessage);
      rethrow;
    }
  }

  // ============ BANNERS ============
  Future<void> fetchBanners() async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _firestore.collection('banners').get();
      _banners = snapshot.docs
          .map((doc) => banner_model.Banner.fromMap(doc.id, doc.data()))
          .toList();
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Error fetching banners: $e';
      print(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addBanner(String title, String imageUrl, {String? description, String? link, bool isActive = true}) async {
    try {
      await _firestore.collection('banners').add({
        'title': title,
        'description': description,
        'imageUrl': imageUrl,
        'link': link,
        'isActive': isActive,
        'createdAt': DateTime.now().toIso8601String(),
      });
      await fetchBanners();
    } catch (e) {
      _errorMessage = 'Error adding banner: $e';
      print(_errorMessage);
      rethrow;
    }
  }

  Future<void> updateBanner(String bannerId, String title, String imageUrl, {String? description, String? link, bool isActive = true}) async {
    try {
      await _firestore.collection('banners').doc(bannerId).update({
        'title': title,
        'description': description,
        'imageUrl': imageUrl,
        'link': link,
        'isActive': isActive,
      });
      await fetchBanners();
    } catch (e) {
      _errorMessage = 'Error updating banner: $e';
      print(_errorMessage);
      rethrow;
    }
  }

  Future<void> deleteBanner(String bannerId) async {
    try {
      await _firestore.collection('banners').doc(bannerId).delete();
      await fetchBanners();
    } catch (e) {
      _errorMessage = 'Error deleting banner: $e';
      print(_errorMessage);
      rethrow;
    }
  }

  // ============ NOTIFICATIONS ============
  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .get();
      _notifications = snapshot.docs
          .map((doc) => AppNotification.fromMap(doc.id, doc.data()))
          .toList();
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Error fetching notifications: $e';
      print(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendNotification(String title, String message, NotificationType type, {DateTime? scheduledFor}) async {
    try {
      await _firestore.collection('notifications').add({
        'title': title,
        'message': message,
        'type': type.toString().split('.').last,
        'createdAt': DateTime.now().toIso8601String(),
        'scheduledFor': scheduledFor?.toIso8601String(),
        'isSent': scheduledFor == null ? true : false,
        'recipientCount': 0,
      });
      await fetchNotifications();
    } catch (e) {
      _errorMessage = 'Error sending notification: $e';
      print(_errorMessage);
      rethrow;
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
      await fetchNotifications();
    } catch (e) {
      _errorMessage = 'Error deleting notification: $e';
      print(_errorMessage);
      rethrow;
    }
  }

  // ============ REVENUE TRACKING ============
  Future<Map<String, dynamic>> getRevenueStats() async {
    try {
      final ordersSnapshot = await _firestore
          .collection('orders')
          .where('status', isNotEqualTo: 'cancelled')
          .get();

      double totalRevenue = 0;
      int totalOrders = 0;

      for (var doc in ordersSnapshot.docs) {
        final data = doc.data();
        totalRevenue += (data['totalAmount'] ?? 0.0).toDouble();
        totalOrders++;
      }

      return {
        'totalRevenue': totalRevenue,
        'totalOrders': totalOrders,
        'averageOrderValue': totalOrders > 0 ? totalRevenue / totalOrders : 0.0,
      };
    } catch (e) {
      _errorMessage = 'Error fetching revenue stats: $e';
      print(_errorMessage);
      return {
        'totalRevenue': 0.0,
        'totalOrders': 0,
        'averageOrderValue': 0.0,
      };
    }
  }
}
