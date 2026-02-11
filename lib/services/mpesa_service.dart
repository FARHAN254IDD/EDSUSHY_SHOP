import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class MpesaService {
  static const String _sandboxUrl = 'https://sandbox.safaricom.co.ke';
  static const String _productionUrl = 'https://api.safaricom.co.ke';
  
  final String consumerKey;
  final String consumerSecret;
  final String shortcode;
  final String passkey;
  final String callbackUrl;
  final bool isSandbox;
  
  String? _accessToken;
  DateTime? _tokenExpiry;

  MpesaService({
    required this.consumerKey,
    required this.consumerSecret,
    required this.shortcode,
    required this.passkey,
    required this.callbackUrl,
    this.isSandbox = true,
  });

  String get _baseUrl => isSandbox ? _sandboxUrl : _productionUrl;

  /// Get M-Pesa access token
  Future<String?> _getAccessToken() async {
    // Return cached token if still valid
    if (_accessToken != null && _tokenExpiry != null && DateTime.now().isBefore(_tokenExpiry!)) {
      return _accessToken;
    }

    try {
      final String credentials = base64.encode(utf8.encode('$consumerKey:$consumerSecret'));
      final response = await http.get(
        Uri.parse('$_baseUrl/oauth/v1/generate?grant_type=client_credentials'),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['access_token'];
        // Token typically expires in 3600 seconds, cache for 3500 seconds
        _tokenExpiry = DateTime.now().add(const Duration(seconds: 3500));
        return _accessToken;
      } else {
        print('Error getting access token: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception getting access token: $e');
      return null;
    }
  }

  /// Initiate STK Push for M-Pesa payment
  Future<Map<String, dynamic>> initiateStkPush({
    required String phoneNumber,
    required double amount,
    required String accountReference,
    required String transactionDescription,
    String? orderId,
  }) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Failed to get access token',
          'error': 'Unable to authenticate with M-Pesa',
        };
      }

      // Validate phone number format
      String formattedPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
      if (formattedPhone.startsWith('0')) {
        formattedPhone = '254' + formattedPhone.substring(1);
      } else if (!formattedPhone.startsWith('254')) {
        formattedPhone = '254$formattedPhone';
      }

      final timestamp = DateTime.now();
      final formattedTimestamp = 
          '${timestamp.year}${_padZero(timestamp.month)}${_padZero(timestamp.day)}'
          '${_padZero(timestamp.hour)}${_padZero(timestamp.minute)}${_padZero(timestamp.second)}';

      // Generate the password
      final password = base64.encode(
        utf8.encode('$shortcode$passkey$formattedTimestamp'),
      );

      final requestBody = {
        'BusinessShortCode': shortcode,
        'Password': password,
        'Timestamp': formattedTimestamp,
        'TransactionType': 'CustomerPayBillOnline',
        'Amount': amount.toInt(),
        'PartyA': formattedPhone,
        'PartyB': shortcode,
        'PhoneNumber': formattedPhone,
        'CallBackURL': callbackUrl,
        'AccountReference': accountReference,
        'TransactionDesc': transactionDescription,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/mpesa/stkpush/v1/processrequest'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 30));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['ResponseCode'] == '0') {
        return {
          'success': true,
          'message': 'STK Push sent successfully',
          'checkoutRequestId': responseData['CheckoutRequestID'],
          'requestId': responseData['RequestId'],
          'responseCode': responseData['ResponseCode'],
          'responseDescription': responseData['ResponseDescription'],
          'orderId': orderId,
        };
      } else {
        return {
          'success': false,
          'message': responseData['ResponseDescription'] ?? 'Failed to send STK Push',
          'error': responseData['errorMessage'],
          'responseCode': responseData['ResponseCode'],
        };
      }
    } catch (e) {
      print('Exception in initiateStkPush: $e');
      return {
        'success': false,
        'message': 'An error occurred: $e',
        'error': e.toString(),
      };
    }
  }

  /// Query the status of an STK push
  Future<Map<String, dynamic>> queryStkStatus({
    required String checkoutRequestId,
  }) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Failed to get access token',
        };
      }

      final timestamp = DateTime.now();
      final formattedTimestamp = 
          '${timestamp.year}${_padZero(timestamp.month)}${_padZero(timestamp.day)}'
          '${_padZero(timestamp.hour)}${_padZero(timestamp.minute)}${_padZero(timestamp.second)}';

      final password = base64.encode(
        utf8.encode('$shortcode$passkey$formattedTimestamp'),
      );

      final requestBody = {
        'BusinessShortCode': shortcode,
        'Password': password,
        'Timestamp': formattedTimestamp,
        'CheckoutRequestID': checkoutRequestId,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/mpesa/stkpushquery/v1/query'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 30));

      final responseData = jsonDecode(response.body);
      return responseData;
    } catch (e) {
      print('Exception in queryStkStatus: $e');
      return {
        'success': false,
        'message': 'An error occurred: $e',
      };
    }
  }

  /// Parse M-Pesa callback response
  static Map<String, dynamic> parseCallback(Map<String, dynamic> body) {
    try {
      final result = body['Body']['stkCallback'];
      return {
        'merchantRequestId': result['MerchantRequestID'],
        'checkoutRequestId': result['CheckoutRequestID'],
        'resultCode': result['ResultCode'],
        'resultDesc': result['ResultDesc'],
        'amount': result['CallbackMetadata'] != null 
            ? result['CallbackMetadata']['Item']
                .firstWhere((item) => item['Name'] == 'Amount')['Value']
            : null,
        'mpesaReceiptNumber': result['CallbackMetadata'] != null
            ? result['CallbackMetadata']['Item']
                .firstWhere((item) => item['Name'] == 'MpesaReceiptNumber', orElse: () => {'Value': null})['Value']
            : null,
        'transactionDate': result['CallbackMetadata'] != null
            ? result['CallbackMetadata']['Item']
                .firstWhere((item) => item['Name'] == 'TransactionDate', orElse: () => {'Value': null})['Value']
            : null,
        'phoneNumber': result['CallbackMetadata'] != null
            ? result['CallbackMetadata']['Item']
                .firstWhere((item) => item['Name'] == 'PhoneNumber', orElse: () => {'Value': null})['Value']
            : null,
      };
    } catch (e) {
      print('Error parsing callback: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  String _padZero(int value) => value.toString().padLeft(2, '0');
}
