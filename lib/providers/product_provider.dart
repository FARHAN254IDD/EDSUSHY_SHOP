import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/product_model.dart';
import '../services/sample_products_service.dart';

class ProductProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _productsSub;

  List<Product> get allProducts => _allProducts;
  List<Product> get filteredProducts => _filteredProducts;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;

  Future<void> fetchProducts() async {
    if (_productsSub != null) return;
    _isLoading = true;
    notifyListeners();
    _productsSub = _firestore
        .collection('products')
        .snapshots()
        .listen(
          (snapshot) async {
            await _handleProductsSnapshot(snapshot);
          },
          onError: (e) {
            _allProducts = SampleProductsService.getAllProducts();
            _applyFilters();
            _isLoading = false;
            print(
              'Error fetching products from Firestore, using sample data: $e',
            );
            notifyListeners();
          },
        );
  }

  // Initialize with sample data immediately
  void initializeSampleData() {
    _allProducts = SampleProductsService.getAllProducts();
    _filteredProducts = _allProducts;
    notifyListeners();
  }

  List<Product> getFeaturedProducts() {
    return _allProducts.where((p) => p.isFeatured).toList();
  }

  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void searchProducts(String query) {
    _searchQuery = query.trim();
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    final query = _searchQuery.toLowerCase();
    Iterable<Product> results = _allProducts;

    if (_selectedCategory != 'All') {
      results = results.where((p) => p.category == _selectedCategory);
    }

    if (query.isNotEmpty) {
      results = results.where((product) {
        final name = product.name.toLowerCase();
        final description = product.description.toLowerCase();
        final category = product.category.toLowerCase();
        final subcategory = (product.subcategory ?? '').toLowerCase();
        final brand = (product.brand ?? '').toLowerCase();
        final seller = (product.seller ?? '').toLowerCase();

        return name.contains(query) ||
            description.contains(query) ||
            category.contains(query) ||
            subcategory.contains(query) ||
            brand.contains(query) ||
            seller.contains(query);
      });
    }

    _filteredProducts = results.toList();
  }

  Future<void> _handleProductsSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) async {
    if (snapshot.docs.isEmpty) {
      _allProducts = SampleProductsService.getAllProducts();
      _applyFilters();
      _isLoading = false;
      notifyListeners();
      return;
    }

    final List<Product> products = [];
    for (var doc in snapshot.docs) {
      final data = Map<String, dynamic>.from(doc.data());
      try {
        if (data['imageUrl'] is String &&
            (data['imageUrl'] as String).startsWith('gs://')) {
          try {
            final ref = FirebaseStorage.instance.refFromURL(
              data['imageUrl'] as String,
            );
            final url = await ref.getDownloadURL();
            data['imageUrl'] = url;
          } catch (e) {
            print('Failed to convert imageUrl for ${doc.id}: $e');
          }
        }

        if (data['imageUrls'] is Iterable) {
          final List urls = List.from(data['imageUrls']);
          for (int i = 0; i < urls.length; i++) {
            if (urls[i] is String && (urls[i] as String).startsWith('gs://')) {
              try {
                final ref = FirebaseStorage.instance.refFromURL(
                  urls[i] as String,
                );
                urls[i] = await ref.getDownloadURL();
              } catch (e) {
                print('Failed to convert imageUrls[$i] for ${doc.id}: $e');
              }
            }
          }
          data['imageUrls'] = urls;
        }
      } catch (e) {
        print('Error processing storage urls for ${doc.id}: $e');
      }

      products.add(Product.fromMap(doc.id, data));
    }

    _allProducts = products;
    _applyFilters();
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _productsSub?.cancel();
    super.dispose();
  }

  List<String> getCategories() {
    Set<String> categories = {'All'};
    for (var product in _allProducts) {
      categories.add(product.category);
    }
    return categories.toList();
  }

  Future<void> addProduct(Product product) async {
    try {
      await _firestore.collection('products').add(product.toMap());
      await fetchProducts();
    } catch (e) {
      print('Error adding product: $e');
    }
  }

  Future<void> updateProduct(String productId, Product product) async {
    try {
      await _firestore
          .collection('products')
          .doc(productId)
          .update(product.toMap());
      await fetchProducts();
    } catch (e) {
      print('Error updating product: $e');
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
      await fetchProducts();
    } catch (e) {
      print('Error deleting product: $e');
    }
  }
}
