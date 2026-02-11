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

  List<Product> get allProducts => _allProducts;
  List<Product> get filteredProducts => _filteredProducts;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _firestore.collection('products').get();
      if (snapshot.docs.isEmpty) {
        // If no products in Firestore, use sample data
        _allProducts = SampleProductsService.getAllProducts();
      } else {
        final List<Product> products = [];
        for (var doc in snapshot.docs) {
          final data = Map<String, dynamic>.from(doc.data());
          print('========== FETCHED PRODUCT FROM FIRESTORE ==========');
          print('Doc ID: ${doc.id}');
          print('Raw imageUrl: ${data['imageUrl']}');
          print('Raw data: $data');
          try {
            // Convert any gs:// Firebase Storage paths to downloadable HTTPS URLs
            if (data['imageUrl'] is String &&
                (data['imageUrl'] as String).startsWith('gs://')) {
              try {
                final ref = FirebaseStorage.instance
                    .refFromURL(data['imageUrl'] as String);
                final url = await ref.getDownloadURL();
                data['imageUrl'] = url;
                print('Converted gs:// to: ${data['imageUrl']}');
              } catch (e) {
                // leave original value if conversion fails
                print('Failed to convert imageUrl for ${doc.id}: $e');
              }
            }

            // Convert any entries in imageUrls list
            if (data['imageUrls'] is Iterable) {
              final List urls = List.from(data['imageUrls']);
              for (int i = 0; i < urls.length; i++) {
                if (urls[i] is String && (urls[i] as String).startsWith('gs://')) {
                  try {
                    final ref = FirebaseStorage.instance.refFromURL(urls[i] as String);
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

          final product = Product.fromMap(doc.id, data);
          print('Created Product with imageUrl: ${product.imageUrl}');
          print('====================================================');
          products.add(product);
        }
        _allProducts = products;
      }
      _filteredProducts = _allProducts;
      notifyListeners();
    } catch (e) {
      // If Firestore fails, use sample data
      _allProducts = SampleProductsService.getAllProducts();
      _filteredProducts = _allProducts;
      print('Error fetching products from Firestore, using sample data: $e');
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
    if (category == 'All') {
      _filteredProducts = _allProducts;
    } else {
      _filteredProducts = _allProducts
          .where((product) => product.category == category)
          .toList();
    }
    notifyListeners();
  }

  void searchProducts(String query) {
    if (query.isEmpty) {
      _filteredProducts = _selectedCategory == 'All'
          ? _allProducts
          : _allProducts
              .where((p) => p.category == _selectedCategory)
              .toList();
    } else {
      _filteredProducts = _allProducts
          .where((product) =>
              product.name.toLowerCase().contains(query.toLowerCase()) ||
              product.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
      if (_selectedCategory != 'All') {
        _filteredProducts = _filteredProducts
            .where((p) => p.category == _selectedCategory)
            .toList();
      }
    }
    notifyListeners();
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
