import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show AnchorElement, Url, Blob;

class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generate Sales Report
  Future<Map<String, dynamic>> generateSalesReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore.collection('orders');
      
      if (startDate != null) {
        query = query.where('createdAt', isGreaterThanOrEqualTo: startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.where('createdAt', isLessThanOrEqualTo: endDate.toIso8601String());
      }

      final snapshot = await query.get();
      
      double totalRevenue = 0;
      double pendingRevenue = 0;
      double completedRevenue = 0;
      int totalOrders = snapshot.docs.length;
      int pendingOrders = 0;
      int completedOrders = 0;
      int cancelledOrders = 0;

      final ordersList = <Map<String, dynamic>>[];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final amount = (data['totalAmount'] ?? 0.0).toDouble();
        final status = data['status'] ?? 'pending';
        
        totalRevenue += amount;
        
        if (status == 'cancelled') {
          cancelledOrders++;
        } else if (status == 'delivered') {
          completedOrders++;
          completedRevenue += amount;
        } else {
          pendingOrders++;
          pendingRevenue += amount;
        }

        ordersList.add({
          'orderId': doc.id,
          'date': data['createdAt'] ?? '',
          'userId': data['userId'] ?? '',
          'amount': amount,
          'status': status,
          'items': data['items']?.length ?? 0,
          'paymentMethod': data['paymentMethod'] ?? '',
          'paymentStatus': data['paymentStatus'] ?? '',
        });
      }

      return {
        'summary': {
          'totalOrders': totalOrders,
          'totalRevenue': totalRevenue,
          'pendingOrders': pendingOrders,
          'pendingRevenue': pendingRevenue,
          'completedOrders': completedOrders,
          'completedRevenue': completedRevenue,
          'cancelledOrders': cancelledOrders,
          'averageOrderValue': totalOrders > 0 ? totalRevenue / totalOrders : 0.0,
        },
        'orders': ordersList,
      };
    } catch (e) {
      print('Error generating sales report: $e');
      rethrow;
    }
  }

  // Generate Product Performance Report
  Future<Map<String, dynamic>> generateProductReport() async {
    try {
      final ordersSnapshot = await _firestore.collection('orders').get();
      final productsSnapshot = await _firestore.collection('products').get();
      
      final productSales = <String, Map<String, dynamic>>{};

      // Initialize with all products
      for (var doc in productsSnapshot.docs) {
        final data = doc.data();
        productSales[doc.id] = {
          'id': doc.id,
          'name': data['name'] ?? '',
          'category': data['category'] ?? '',
          'price': (data['price'] ?? 0.0).toDouble(),
          'stock': data['stock'] ?? 0,
          'quantitySold': 0,
          'revenue': 0.0,
        };
      }

      // Calculate sales data
      for (var order in ordersSnapshot.docs) {
        final data = order.data();
        final status = data['status'] ?? 'pending';
        
        if (status == 'cancelled') continue;
        
        final items = data['items'] as List<dynamic>? ?? [];
        for (var item in items) {
          final productId = item['productId'] ?? '';
          if (productSales.containsKey(productId)) {
            final quantity = item['quantity'] ?? 0;
            final price = (item['price'] ?? 0.0).toDouble();
            
            productSales[productId]!['quantitySold'] += quantity;
            productSales[productId]!['revenue'] += (price * quantity);
          }
        }
      }

      final sortedProducts = productSales.values.toList()
        ..sort((a, b) => (b['revenue'] as double).compareTo(a['revenue'] as double));

      return {
        'totalProducts': productsSnapshot.docs.length,
        'productsInStock': productsSnapshot.docs.where((d) => (d.data()['stock'] ?? 0) > 0).length,
        'productsOutOfStock': productsSnapshot.docs.where((d) => (d.data()['stock'] ?? 0) == 0).length,
        'products': sortedProducts,
      };
    } catch (e) {
      print('Error generating product report: $e');
      rethrow;
    }
  }

  // Generate Customer Report
  Future<Map<String, dynamic>> generateCustomerReport() async {
    try {
      final usersSnapshot = await _firestore
          .collection('users')
          .where('role', whereIn: ['customer', 'user']).get();
      
      final ordersSnapshot = await _firestore.collection('orders').get();
      
      final customerData = <String, Map<String, dynamic>>{};

      // Initialize customer data
      for (var doc in usersSnapshot.docs) {
        final data = doc.data();
        customerData[doc.id] = {
          'userId': doc.id,
          'email': data['email'] ?? 'No email',
          'totalOrders': 0,
          'totalSpent': 0.0,
          'lastOrderDate': '',
        };
      }

      // Calculate order data
      for (var order in ordersSnapshot.docs) {
        final data = order.data();
        final userId = data['userId'] ?? '';
        final status = data['status'] ?? 'pending';
        
        if (status == 'cancelled') continue;
        
        if (customerData.containsKey(userId)) {
          customerData[userId]!['totalOrders'] += 1;
          customerData[userId]!['totalSpent'] += (data['totalAmount'] ?? 0.0).toDouble();
          
          final orderDate = data['createdAt'] ?? '';
          if (customerData[userId]!['lastOrderDate'].isEmpty || 
              orderDate.compareTo(customerData[userId]!['lastOrderDate']) > 0) {
            customerData[userId]!['lastOrderDate'] = orderDate;
          }
        }
      }

      final sortedCustomers = customerData.values.toList()
        ..sort((a, b) => (b['totalSpent'] as double).compareTo(a['totalSpent'] as double));

      return {
        'totalCustomers': usersSnapshot.docs.length,
        'activeCustomers': sortedCustomers.where((c) => c['totalOrders'] > 0).length,
        'customers': sortedCustomers,
      };
    } catch (e) {
      print('Error generating customer report: $e');
      rethrow;
    }
  }

  // Export Sales Report to CSV
  Future<String?> exportSalesReportToCsv(Map<String, dynamic> reportData) async {
    try {
      final orders = reportData['orders'] as List<Map<String, dynamic>>;
      
      final List<List<dynamic>> rows = [
        ['Order ID', 'Date', 'User ID', 'Amount (KSh)', 'Status', 'Items', 'Payment Method', 'Payment Status'],
      ];

      for (var order in orders) {
        rows.add([
          order['orderId'],
          order['date'],
          order['userId'],
          order['amount'].toStringAsFixed(2),
          order['status'],
          order['items'].toString(),
          order['paymentMethod'],
          order['paymentStatus'],
        ]);
      }

      final csv = const ListToCsvConverter().convert(rows);
      return await _saveCsvFile(csv, 'sales_report_${DateTime.now().millisecondsSinceEpoch}.csv');
    } catch (e) {
      print('Error exporting sales report: $e');
      return null;
    }
  }

  // Export Product Report to CSV
  Future<String?> exportProductReportToCsv(Map<String, dynamic> reportData) async {
    try {
      final products = reportData['products'] as List<Map<String, dynamic>>;
      
      final List<List<dynamic>> rows = [
        ['Product ID', 'Name', 'Category', 'Price (KSh)', 'Stock', 'Quantity Sold', 'Revenue (KSh)'],
      ];

      for (var product in products) {
        rows.add([
          product['id'],
          product['name'],
          product['category'],
          product['price'].toStringAsFixed(2),
          product['stock'].toString(),
          product['quantitySold'].toString(),
          product['revenue'].toStringAsFixed(2),
        ]);
      }

      final csv = const ListToCsvConverter().convert(rows);
      return await _saveCsvFile(csv, 'product_report_${DateTime.now().millisecondsSinceEpoch}.csv');
    } catch (e) {
      print('Error exporting product report: $e');
      return null;
    }
  }

  // Export Customer Report to CSV
  Future<String?> exportCustomerReportToCsv(Map<String, dynamic> reportData) async {
    try {
      final customers = reportData['customers'] as List<Map<String, dynamic>>;
      
      final List<List<dynamic>> rows = [
        ['User ID', 'Email', 'Total Orders', 'Total Spent (KSh)', 'Last Order Date'],
      ];

      for (var customer in customers) {
        rows.add([
          customer['userId'],
          customer['email'],
          customer['totalOrders'].toString(),
          customer['totalSpent'].toStringAsFixed(2),
          customer['lastOrderDate'],
        ]);
      }

      final csv = const ListToCsvConverter().convert(rows);
      return await _saveCsvFile(csv, 'customer_report_${DateTime.now().millisecondsSinceEpoch}.csv');
    } catch (e) {
      print('Error exporting customer report: $e');
      return null;
    }
  }

  // Save CSV file (platform-specific)
  Future<String?> _saveCsvFile(String csvContent, String filename) async {
    try {
      if (kIsWeb) {
        // Web: trigger download
        final bytes = utf8.encode(csvContent);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute('download', filename)
          ..click();
        html.Url.revokeObjectUrl(url);
        return 'Downloaded: $filename';
      } else {
        // Mobile/Desktop: save to downloads
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$filename');
        await file.writeAsString(csvContent);
        return file.path;
      }
    } catch (e) {
      print('Error saving CSV file: $e');
      return null;
    }
  }
}
