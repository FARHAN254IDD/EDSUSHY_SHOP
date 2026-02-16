import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/payment_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/order_model.dart';

class PaymentScreen extends StatefulWidget {
  final Order order;
  final String phoneNumber;

  const PaymentScreen({
    super.key,
    required this.order,
    required this.phoneNumber,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _agreedToTerms = false;
  bool _paymentInitiated = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Don't allow going back during payment
        if (_paymentInitiated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please complete or cancel your payment'),
            ),
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Payment'),
          elevation: 0,
          automaticallyImplyLeading: !_paymentInitiated,
        ),
        body: Consumer<PaymentProvider>(
          builder: (context, paymentProvider, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Payment info
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Payment Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Amount:'),
                              Text(
                                'KSh ${widget.order.totalAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Phone:'),
                              Text(widget.phoneNumber),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Method:'),
                              Chip(
                                label: Text(widget.order.paymentMethod
                                    .toString()
                                    .split('.')
                                    .last),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // M-Pesa STK Push info
                  if (widget.order.paymentMethod == PaymentMethod.mpesa)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'M-Pesa Payment',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'A payment prompt will be sent to your phone. Enter your M-Pesa PIN to complete the payment.',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Payment status messages
                  if (paymentProvider.errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red[700]),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  paymentProvider.errorMessage!,
                                  style: TextStyle(color: Colors.red[700]),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (_paymentInitiated)
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _paymentInitiated = false;
                                });
                                paymentProvider.clearMessages();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text('Cancel Payment'),
                            ),
                        ],
                      ),
                    ),
                  if (paymentProvider.successMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green[700]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              paymentProvider.successMessage!,
                              style: TextStyle(color: Colors.green[700]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Terms checkbox (only show if not payment initiated)
                  if (!_paymentInitiated)
                    Column(
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _agreedToTerms,
                              onChanged: (value) {
                                setState(() {
                                  _agreedToTerms = value ?? false;
                                });
                              },
                            ),
                            const Expanded(
                              child: Text(
                                'I agree to the terms and conditions',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),

                  // Action buttons
                  if (!_paymentInitiated)
                    // Complete payment button (only show before payment)
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _agreedToTerms && !paymentProvider.isProcessing
                            ? () async {
                                setState(() => _paymentInitiated = true);
                                final success =
                                    await paymentProvider.initiateMpesaPayment(
                                  phoneNumber: widget.phoneNumber,
                                  amount: widget.order.totalAmount,
                                  orderId: widget.order.id,
                                  customerEmail: '',
                                  transactionDescription:
                                      'Order #${widget.order.id}',
                                );

                                if (mounted && success) {
                                  // Create order immediately as "unpaid" when STK push is sent
                                  final unpaidOrder = Order(
                                    id: widget.order.id,
                                    userId: widget.order.userId,
                                    items: widget.order.items,
                                    totalAmount: widget.order.totalAmount,
                                    status: OrderStatus.unpaid, // Mark as unpaid initially
                                    paymentMethod: widget.order.paymentMethod,
                                    paymentStatus: 'pending',
                                    createdAt: DateTime.now(),
                                    shippingAddress: widget.order.shippingAddress,
                                    transactionId: '',
                                  );
                                  
                                  // Save order to Firestore as unpaid
                                  await context.read<OrderProvider>().createOrder(unpaidOrder);
                                  
                                  // Clear cart
                                  context.read<CartProvider>().clearCart();
                                  
                                  // Small delay to ensure Firestore syncs
                                  await Future.delayed(const Duration(milliseconds: 500));
                                  
                                  if (mounted) {
                                    // Refresh user orders to show the new unpaid order
                                    await context.read<OrderProvider>().fetchUserOrders(widget.order.userId);
                                    
                                    // Show success message
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('STK push sent! Check your phone. Order created as unpaid.'),
                                        backgroundColor: Colors.green,
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                    
                                    // Redirect to orders page (orders list is now refreshed)
                                    Navigator.of(context).pop(); // Close payment screen
                                  }
                                } else if (mounted) {
                                  setState(() => _paymentInitiated = false);
                                }
                              }
                            : null,
                        child: paymentProvider.isProcessing
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Complete Payment'),
                      ),
                    ),
                  const SizedBox(height: 24),
                  
                  // Information card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue[700]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'After clicking "Complete Payment", check your phone for the STK push\nand enter your PIN to complete the payment.',
                                style: TextStyle(color: Colors.blue[700]),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
