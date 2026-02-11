# M-Pesa STK Push - Quick Reference

## What's Implemented

### 1. MpesaService (`lib/services/mpesa_service.dart`)
Complete M-Pesa API integration with:
- Access token generation and caching
- STK Push initiation with phone number formatting
- STK status checking
- Callback parsing
- Sandbox & Production support

### 2. PaymentProvider (`lib/providers/payment_provider.dart`)
State management for payments with:
- Error and success message tracking
- Payment initiation and status checking
- Callback processing
- Transaction data storage

### 3. Enhanced PaymentScreen (`lib/features/customer/payment_screen.dart`)
Full payment UI with:
- Payment details display
- M-Pesa specific instructions
- Error/Success messaging
- Payment status checking workflow
- Cancel payment option
- Loading states

### 4. Firebase Cloud Functions (`functions/index.js`)
Backend payment processing:
- STK Push initiation endpoint
- Callback webhook handler
- Payment status query
- Payment verification
- Firestore transaction logging

## How to Use

### For Users (Customer Flow)

1. **Browse & Add Products**
   - Browse products in the app
   - Add items to cart
   - Click "Cart" tab

2. **Checkout**
   - Click "Proceed to Checkout"
   - Fill shipping information:
     - Full Name
     - Email
     - Phone Number (e.g., 0712345678)
     - Address
   - Select "M-Pesa" as payment method
   - Click "Place Order"

3. **Payment**
   - Review order summary and total amount
   - Agree to terms and conditions
   - Click "Complete Payment"
   - **Check Your Phone!** - STK prompt will appear
   - Enter your M-Pesa PIN
   - Return to app

4. **Confirmation**
   - App automatically checks payment status
   - Once confirmed: "Payment successful! Order placed."
   - Order appears in "My Orders" section

### For Developers/Admins

#### Testing Locally
```bash
# 1. Start Firebase emulator
firebase emulators:start

# 2. In another terminal, start ngrok
ngrok http 3000

# 3. Update MPESA_CALLBACK_URL in PaymentProvider with ngrok URL
# Example: https://abc123.ngrok-free.app/user/mpesa/callback

# 4. Test payment flow in app
```

#### Checking Payment Status in Firebase Console
```
Firestore → Collections → transactions
- Look for order ID
- Check "status" field (pending/completed/failed)
- View transaction details like mpesaReceiptNumber
```

#### View Cloud Function Logs
```bash
firebase functions:log
# or
firebase functions:log -m initiateMpesaPayment
firebase functions:log -m mpesaCallback
```

## Key Features

### ✅ Implemented
- STK Push initiation
- Phone number validation and formatting
- Access token caching
- Payment status checking
- Callback processing
- Transaction logging to Firestore
- Error handling and user feedback
- Loading states and UI feedback
- Cancel payment option
- Multiple payment methods support

### ⏳ Optional Enhancements
- SMS notifications for payment status
- Email receipts
- Payment history with filters
- Partial refunds support
- Multiple payment methods (Card, Stripe)
- Rate limiting on payment endpoints
- Advanced fraud detection

## Configuration

### Sandbox Testing
```dart
MpesaService(
  consumerKey: 'A3x09Kvm8A8xiGHha5yloAdL36U3GpZP8nySX4syRGiet4Eu',
  consumerSecret: 'Reg1ULoAJfx88r64LiI3SGrAevNEKhqvYcdOGtCiGsyd1ECmpxrABE9lo1Ltk3uX',
  shortcode: '174379',
  passkey: 'bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919',
  callbackUrl: 'https://your-callback-url.ngrok.app/callback',
  isSandbox: true, // Change to false for production
)
```

### Phone Number Formats Supported
- `0712345678` ✅
- `712345678` ✅
- `+254712345678` ✅
- `254712345678` ✅

All formats are automatically converted to `254712345678` format required by M-Pesa.

## Firestore Queries

### Get all pending payments
```
db.collection('transactions').where('status', '==', 'pending').get()
```

### Get completed payments for a user
```
db.collection('transactions')
  .where('status', '==', 'completed')
  .orderBy('createdAt', 'desc')
  .get()
```

### Get payment by order ID
```
db.collection('transactions').doc(orderId).get()
```

## Callbacks & Webhooks

### M-Pesa Callback Structure
```json
{
  "Body": {
    "stkCallback": {
      "MerchantRequestID": "25150403191559818",
      "CheckoutRequestID": "ws_CO_DMZ_123456789_012345678",
      "ResultCode": 0,
      "ResultDesc": "The service request has been processed successfully",
      "CallbackMetadata": {
        "Item": [
          {"Name": "Amount", "Value": 1000},
          {"Name": "MpesaReceiptNumber", "Value": "RCH61V1QZ60"},
          {"Name": "TransactionDate", "Value": 20231201120000},
          {"Name": "PhoneNumber", "Value": 254712345678}
        ]
      }
    }
  }
}
```

## Error Handling

### Common Error Codes
| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Insufficient funds |
| 2 | Less than minimum transaction value |
| 3 | More than maximum transaction value |
| 6 | Transaction timed out |
| 12 | Declined by customer |
| 13 | Invalid amount |
| 14 | Invalid account number |
| 1001 | Unable to lock subscriber |
| 1032 | Request cancelled by service provider |

### User-Friendly Error Messages
- "STK Push sent successfully. Please enter your M-Pesa PIN." ✅
- "Payment cancelled by user" ❌
- "Failed to authenticate with M-Pesa" ❌
- "An error occurred: Network timeout" ❌

## Testing Scenarios

### Successful Payment
1. Enter phone: 0712345678
2. Enter amount: 1000 KSh (any amount works in sandbox)
3. User enters PIN on phone
4. Status: Completed ✅

### User Cancels Payment
1. Enter phone: 0712345678
2. User clicks Cancel on phone prompt
3. Status: Failed (User cancelled) ❌

### Payment Timeout
1. Enter phone: 0712345678
2. Wait more than 2 minutes without responding
3. STK prompt expires
4. Status: Failed (Timeout) ❌

## Migrating to Production

When ready for production:

1. **Get Production Credentials**
   - Register M-Pesa Business account with Safaricom
   - Request production API credentials
   - Update shortcode and passkey

2. **Update Configuration**
   ```dart
   PaymentProvider() {
     _mpesaService = MpesaService(
       consumerKey: 'your_production_key',
       consumerSecret: 'your_production_secret',
       shortcode: 'your_production_shortcode',
       passkey: 'your_production_passkey',
       callbackUrl: 'https://yourdomain.com/callback',
       isSandbox: false, // Switch to production
     );
   }
   ```

3. **Update Cloud Functions**
   ```bash
   firebase functions:config:set mpesa.key="your_production_key" mpesa.secret="your_production_secret"
   firebase deploy --only functions
   ```

4. **Update Callback URL**
   - Change from ngrok URL to production domain
   - Update in M-Pesa settings and PaymentProvider

5. **Load Testing**
   - Test with real M-Pesa accounts
   - Verify callback handling
   - Monitor Cloud Function logs

## Support

For issues:
1. Check Cloud Function logs: `firebase functions:log`
2. Review Firestore transactions collection
3. Verify phone number format
4. Check M-Pesa API status
5. Review MPESA_INTEGRATION.md for detailed docs

## Files Overview

| File | Purpose |
|------|---------|
| `lib/services/mpesa_service.dart` | M-Pesa API integration |
| `lib/providers/payment_provider.dart` | Payment state management |
| `lib/features/customer/payment_screen.dart` | Payment UI |
| `functions/index.js` | Cloud Functions backend |
| `functions/package.json` | Functions dependencies |
| `.env` | Environment configuration |
| `MPESA_INTEGRATION.md` | Full documentation |

---

**Status**: ✅ Ready to Use
**Environment**: Sandbox (Switch to Production in config)
**Last Updated**: February 2026
