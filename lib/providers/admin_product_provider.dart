import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/image_storage_service.dart';

class AdminProductProvider extends ChangeNotifier {
  final ImageStorageService _storageService = ImageStorageService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> products = [];
  bool isLoading = false;
  String? errorMessage;

  AdminProductProvider() {
    // loadProducts();
  }

  // Load all products
  Future<void> loadProducts() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final snapshot = await _firestore
          .collection('products')
          .orderBy('createdAt', descending: true)
          .get();

      products = snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();

      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to load products: $e';
      print('❌ $errorMessage');
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Add a new product with image URLs
  Future<String> addProductWithUrls({
    required String name,
    required String description,
    required double price,
    required double discount,
    required int stock,
    required String category,
    required List<String> imageUrls,
    required String adminId,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      // Add product directly to Firestore with image URLs
      final docRef = await _firestore.collection('products').add({
        'name': name,
        'description': description,
        'price': price,
        'discount': discount,
        'stock': stock,
        'category': category,
        'imageUrls': imageUrls,
        'adminId': adminId,
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
        'isActive': true,
      });

      print('✅ Product added successfully with ID: ${docRef.id}');

      // Reload products
      await loadProducts();

      return docRef.id;
    } catch (e) {
      errorMessage = 'Failed to add product: $e';
      print('❌ $errorMessage');
      notifyListeners();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Add a new product with images
  Future<String> addProduct({
    required String name,
    required String description,
    required double price,
    required double discount,
    required int stock,
    required String category,
    required List<File> imageFiles,
    required String adminId,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      // Generate product ID
      final productId = DateTime.now().millisecondsSinceEpoch.toString();

      // Upload images
      final imageUrls = await _storageService.uploadMultipleProductImages(
        imageFiles: imageFiles,
        productId: productId,
      );

      // Add product to Firestore
      final docRef = await _firestore.collection('products').add({
        'name': name,
        'description': description,
        'price': price,
        'discount': discount,
        'stock': stock,
        'category': category,
        'imageUrls': imageUrls,
        'adminId': adminId,
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
        'isActive': true,
      });

      print('✅ Product added successfully with ID: ${docRef.id}');

      // Reload products
      await loadProducts();

      return docRef.id;
    } catch (e) {
      errorMessage = 'Failed to add product: $e';
      print('❌ $errorMessage');
      notifyListeners();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Update product
  Future<void> updateProduct({
    required String productId,
    required String name,
    required String description,
    required double price,
    required double discount,
    required int stock,
    required String category,
    List<String>? newImageUrls,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      // Update product in Firestore
      await _firestore.collection('products').doc(productId).update({
        'name': name,
        'description': description,
        'price': price,
        'discount': discount,
        'stock': stock,
        'category': category,
        if (newImageUrls != null) 'imageUrls': newImageUrls,
        'updatedAt': DateTime.now(),
      });

      print('✅ Product updated successfully');

      // Reload products
      await loadProducts();
    } catch (e) {
      errorMessage = 'Failed to update product: $e';
      print('❌ $errorMessage');
      notifyListeners();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Delete product
  Future<void> deleteProduct({
    required String productId,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      // Delete product from Firestore
      await _firestore.collection('products').doc(productId).delete();

      print('✅ Product deleted successfully');

      // Reload products
      await loadProducts();
    } catch (e) {
      errorMessage = 'Failed to delete product: $e';
      print('❌ $errorMessage');
      notifyListeners();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Set product active/inactive
  Future<void> toggleProductStatus({
    required String productId,
    required bool isActive,
  }) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'isActive': isActive,
      });

      print('✅ Product status updated');
      await loadProducts();
    } catch (e) {
      errorMessage = 'Failed to update product status: $e';
      print('❌ $errorMessage');
      rethrow;
    }
  }

  // Search products
  List<Map<String, dynamic>> searchProducts(String query) {
    if (query.isEmpty) return products;

    return products
        .where((product) =>
            product['name'].toLowerCase().contains(query.toLowerCase()) ||
            product['description']
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            product['category'].toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Get products by category
  List<Map<String, dynamic>> getProductsByCategory(String category) {
    return products.where((product) => product['category'] == category).toList();
  }

  // Get stock summary
  Map<String, int> getStockSummary() {
    int totalStock = 0;
    int lowStockCount = 0;
    int outOfStockCount = 0;

    for (var product in products) {
      int stock = product['stock'] ?? 0;
      totalStock += stock;

      if (stock == 0) {
        outOfStockCount++;
      } else if (stock < 10) {
        lowStockCount++;
      }
    }

    return {
      'total': totalStock,
      'lowStock': lowStockCount,
      'outOfStock': outOfStockCount,
    };
  }

  // Clear error
  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
