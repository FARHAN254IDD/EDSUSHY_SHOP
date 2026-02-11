import 'package:flutter/material.dart';
import '../services/mpesa_service.dart';

class PaymentProvider extends ChangeNotifier {
  bool _isProcessing = false;
  String? _errorMessage;
  String? _successMessage;
  String? _checkoutRequestId;
  Map<String, dynamic>? _lastTransactionData;

  late MpesaService _mpesaService;

  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String? get checkoutRequestId => _checkoutRequestId;
  Map<String, dynamic>? get lastTransactionData => _lastTransactionData;

  PaymentProvider() {
    // Initialize M-Pesa service with credentials
    _mpesaService = MpesaService(
      consumerKey: 'A3x09Kvm8A8xiGHha5yloAdL36U3GpZP8nySX4syRGiet4Eu',
      consumerSecret: 'Reg1ULoAJfx88r64LiI3SGrAevNEKhqvYcdOGtCiGsyd1ECmpxrABE9lo1Ltk3uX',
      shortcode: '174379',
      passkey: 'bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919',
      callbackUrl: 'https://1d1d8ae8dadd.ngrok-free.app/user/mpesa/callback',
      isSandbox: true,
    );
  }

  /// Initiate M-Pesa STK Push
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
      final result = await _mpesaService.initiateStkPush(
        phoneNumber: phoneNumber,
        amount: amount,
        accountReference: orderId,
        transactionDescription: transactionDescription ?? 'Edsushy Shop Order',
        orderId: orderId,
      );

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
    } catch (e) {
      _errorMessage = 'Error initiating payment: $e';
      _isProcessing = false;
      notifyListeners();
      return false;
    }
  }

  /// Query the status of an initiated STK Push
  Future<bool> checkPaymentStatus({required String checkoutRequestId}) async {
    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _mpesaService.queryStkStatus(
        checkoutRequestId: checkoutRequestId,
      );

      _lastTransactionData = result;

      final resultCode = result['ResultCode'];
      if (resultCode == '0') {
        _successMessage = 'Payment completed successfully!';
        _isProcessing = false;
        notifyListeners();
        return true;
      } else if (resultCode == '1' || resultCode == 1) {
        _errorMessage = 'Payment cancelled by user';
        _isProcessing = false;
        notifyListeners();
        return false;
      } else {
        _errorMessage = result['ResultDesc'] ?? 'Payment status unknown';
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

  /// Process M-Pesa callback
  void processCallback(Map<String, dynamic> callbackData) {
    try {
      final parsedData = MpesaService.parseCallback(callbackData);
      _lastTransactionData = parsedData;

      if (parsedData['resultCode'] == 0) {
        _successMessage = 'Payment successful! Receipt: ${parsedData['mpesaReceiptNumber']}';
      } else {
        _errorMessage = parsedData['resultDesc'] ?? 'Payment failed';
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error processing callback: $e';
      notifyListeners();
    }
  }

  /// Verify payment with backend
  Future<bool> verifyPaymentWithBackend({
    required String orderId,
    required String transactionId,
  }) async {
    try {
      _isProcessing = true;
      notifyListeners();

      // This would typically call a Cloud Function to verify with your backend
      // For now, we'll assume it's verified through the callback
      _isProcessing = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error verifying payment: $e';
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
