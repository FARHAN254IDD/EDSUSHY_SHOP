import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentProvider extends ChangeNotifier {
  bool _isProcessing = false;
  String? _errorMessage;
  String? _successMessage;
  String? _checkoutRequestId;
  Map<String, dynamic>? _lastTransactionData;

  // M-Pesa Backend URL (ngrok tunnel)
  static const String _firebaseBaseUrl = 'https://e6e1-129-222-187-201.ngrok-free.app';

  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String? get checkoutRequestId => _checkoutRequestId;
  Map<String, dynamic>? get lastTransactionData => _lastTransactionData;

  PaymentProvider() {
    // Cloud Functions will handle M-Pesa API calls (solves CORS issue)
  }

  /// Initiate M-Pesa STK Push via Firebase Cloud Function
  /// This avoids CORS issues by calling through your backend
  Future<bool> initiateMpesaPayment({
    required String phoneNumber,
    required double amount,
    required String orderId,
    required String customerEmail,
    String? transactionDescription,
  }) async {
    _isProcessing = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      print('DEBUG: Calling Cloud Function to initiate M-Pesa payment');
      print('DEBUG: Phone: $phoneNumber, Amount: $amount, OrderID: $orderId');

      // Call Cloud Function endpoint
      final response = await http.post(
        Uri.parse('$_firebaseBaseUrl/initiateMpesaPayment'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'amount': amount,
          'orderId': orderId,
          'customerEmail': customerEmail,
          'transactionDescription': transactionDescription ?? 'Edsushy Shop Order',
        }),
      ).timeout(const Duration(seconds: 30));

      print('DEBUG: Cloud Function Response Code: ${response.statusCode}');
      print('DEBUG: Cloud Function Response: ${response.body}');

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        
        if (result['success'] == true) {
          _checkoutRequestId = result['checkoutRequestId'];
          _successMessage = 'STK Push sent successfully. Please enter your M-Pesa PIN.';
          _lastTransactionData = result;
          _isProcessing = false;
          notifyListeners();
          return true;
        } else {
          _errorMessage = result['message'] ?? 'Failed to initiate payment';
          _isProcessing = false;
          notifyListeners();
          return false;
        }
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
        _isProcessing = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('ERROR initiating M-Pesa payment: $e');
      _errorMessage = 'Error: $e';
      _isProcessing = false;
      notifyListeners();
      return false;
    }
  }

  /// Check payment status
  Future<bool> checkPaymentStatus({required String checkoutRequestId}) async {
    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$_firebaseBaseUrl/checkPaymentStatus?checkoutRequestId=$checkoutRequestId'),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        _lastTransactionData = result;

        if (result['success'] == true) {
          _successMessage = 'Payment completed successfully!';
          _isProcessing = false;
          notifyListeners();
          return true;
        } else {
          _errorMessage = result['message'] ?? 'Payment pending';
          _isProcessing = false;
          notifyListeners();
          return false;
        }
      } else {
        _errorMessage = 'Failed to check payment status';
        _isProcessing = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error checking payment status: $e';
      _isProcessing = false;
      notifyListeners();
      return false;
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void resetPaymentState() {
    _isProcessing = false;
    _errorMessage = null;
    _successMessage = null;
    _checkoutRequestId = null;
    _lastTransactionData = null;
    notifyListeners();
  }
}
