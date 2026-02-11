import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/wishlist_model.dart';

class WishlistProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Wishlist? _userWishlist;
  bool _isLoading = false;

  Wishlist? get userWishlist => _userWishlist;
  List<String> get wishlistItems => _userWishlist?.productIds ?? [];
  bool get isLoading => _isLoading;

  Future<void> fetchUserWishlist(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _firestore
          .collection('wishlists')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        _userWishlist = Wishlist.fromMap(snapshot.docs.first.id, snapshot.docs.first.data());
      } else {
        // Create empty wishlist if doesn't exist
        _userWishlist = Wishlist(
          id: '',
          userId: userId,
          productIds: [],
          createdAt: DateTime.now(),
        );
      }
    } catch (e) {
      print('Error fetching wishlist: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToWishlist(String userId, String productId) async {
    try {
      if (_userWishlist == null) {
        // Create new wishlist
        final doc = await _firestore.collection('wishlists').add({
          'userId': userId,
          'productIds': [productId],
          'createdAt': DateTime.now().toIso8601String(),
        });
        _userWishlist = Wishlist(
          id: doc.id,
          userId: userId,
          productIds: [productId],
          createdAt: DateTime.now(),
        );
      } else if (!_userWishlist!.productIds.contains(productId)) {
        // Add to existing wishlist
        _userWishlist!.productIds.add(productId);
        await _firestore.collection('wishlists').doc(_userWishlist!.id).update({
          'productIds': _userWishlist!.productIds,
        });
      }
      notifyListeners();
    } catch (e) {
      print('Error adding to wishlist: $e');
      rethrow;
    }
  }

  Future<void> removeFromWishlist(String userId, String productId) async {
    try {
      if (_userWishlist != null) {
        _userWishlist!.productIds.remove(productId);
        await _firestore.collection('wishlists').doc(_userWishlist!.id).update({
          'productIds': _userWishlist!.productIds,
        });
        notifyListeners();
      }
    } catch (e) {
      print('Error removing from wishlist: $e');
      rethrow;
    }
  }

  bool isInWishlist(String productId) {
    return _userWishlist?.productIds.contains(productId) ?? false;
  }
}
