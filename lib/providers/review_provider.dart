import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';

class ReviewProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Review> _productReviews = [];
  List<Review> _userReviews = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<Review> get productReviews => _productReviews;
  List<Review> get userReviews => _userReviews;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<List<Review>?> fetchProductReviews(String productId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('productId', isEqualTo: productId)
          .orderBy('createdAt', descending: true)
          .get();
      _productReviews = snapshot.docs
          .map((doc) => Review.fromMap(doc.id, doc.data()))
          .toList();
      _errorMessage = '';
      return _productReviews;
    } catch (e) {
      _errorMessage = 'Error fetching reviews: $e';
      print(_errorMessage);
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUserReviews(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      _userReviews = snapshot.docs
          .map((doc) => Review.fromMap(doc.id, doc.data()))
          .toList();
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Error fetching your reviews: $e';
      print(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addReview(
    String productId,
    String userId,
    String userName,
    double rating,
    String title,
    String comment, {
    List<String> images = const [],
  }) async {
    try {
      await _firestore.collection('reviews').add({
        'productId': productId,
        'userId': userId,
        'userName': userName,
        'rating': rating,
        'title': title,
        'comment': comment,
        'createdAt': DateTime.now().toIso8601String(),
        'images': images,
      });
      await fetchProductReviews(productId);
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Error adding review: $e';
      print(_errorMessage);
      rethrow;
    }
  }

  Future<void> deleteReview(String reviewId, String productId) async {
    try {
      await _firestore.collection('reviews').doc(reviewId).delete();
      await fetchProductReviews(productId);
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Error deleting review: $e';
      print(_errorMessage);
      rethrow;
    }
  }

  Future<double> getAverageRating(String productId) async {
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('productId', isEqualTo: productId)
          .get();
      if (snapshot.docs.isEmpty) return 0.0;
      final totalRating = snapshot.docs
          .fold<double>(0.0, (sum, doc) => sum + (doc['rating'] as num).toDouble());
      return totalRating / snapshot.docs.length;
    } catch (e) {
      print('Error calculating average rating: $e');
      return 0.0;
    }
  }
}
