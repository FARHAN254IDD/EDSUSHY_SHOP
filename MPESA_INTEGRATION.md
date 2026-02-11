# M-Pesa STK Push Integration Guide

## Overview
This document provides complete setup instructions for integrating M-Pesa STK Push payments into the Edsushy Shop Flutter application using Daraja API.

## Prerequisites
- M-Pesa Business Account
- Daraja API Credentials (Consumer Key and Secret)
- Firebase Project Setup
- Node.js 18+ for Cloud Functions

## Credentials Provided

```env
MPESA_CONSUMER_KEY=A3x09Kvm8A8xiGHha5yloAdL36U3GpZP8nySX4syRGiet4Eu
MPESA_CONSUMER_SECRET=Reg1ULoAJfx88r64LiI3SGrAevNEKhqvYcdOGtCiGsyd1ECmpxrABE9lo1Ltk3uX
MPESA_SHORTCODE=174379
MPESA_PASSKEY=bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919
MPESA_ENV=sandbox
MPESA_CALLBACK_URL=https://1d1d8ae8dadd.ngrok-free.app/user/mpesa/callback
```

## Architecture

### Client-Side (Flutter)
- `MpesaService` - Handles all M-Pesa API calls
- `PaymentProvider` - State management for payment transactions
- `PaymentScreen` - UI for payment processing and status checking

### Server-Side (Firebase Cloud Functions)
- `initiateMpesaPayment` - Initiates STK Push request
- `mpesaCallback` - Processes payment callbacks from M-Pesa
- `queryStkPushStatus` - Queries payment status
- `verifyPayment` - Verifies completed transactions

## Installation & Setup

### 1. Flutter Dependencies
Add to `pubspec.yaml`:
```yaml
dependencies:
  http: ^1.1.0
  provider: ^6.1.0
  firebase_core: ^2.24.0
  cloud_firestore: ^4.13.0
```

### 2. Firebase Functions Setup

#### Install Node Dependencies
```bash
cd functions
npm install firebase-admin firebase-functions axios express cors
```

#### Environment Variables
Create `.env.local` in functions directory:
```env
MPESA_CONSUMER_KEY=A3x09Kvm8A8xiGHha5yloAdL36U3GpZP8nySX4syRGiet4Eu
MPESA_CONSUMER_SECRET=Reg1ULoAJfx88r64LiI3SGrAevNEKhqvYcdOGtCiGsyd1ECmpxrABE9lo1Ltk3uX
MPESA_SHORTCODE=174379
MPESA_PASSKEY=bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919
MPESA_ENV=sandbox
MPESA_CALLBACK_URL=https://1d1d8ae8dadd.ngrok-free.app/user/mpesa/callback
```

### 3. Deploy Firebase Functions
```bash
cd functions
npm run deploy
```

## Implementation Flow

### Payment Initiation Flow
```
1. User enters phone number on CheckoutScreen
2. User clicks "Place Order" → Creates order → PaymentScreen
3. User clicks "Complete Payment"
4. PaymentProvider.initiateMpesaPayment() called
   ├─ MpesaService.initiateStkPush()
   │  ├─ Gets M-Pesa access token
   │  ├─ Formats phone number to +254XXXXXXXXX
   │  ├─ Generates timestamp and password
   │  └─ Sends STK Push request to M-Pesa API
   └─ Saves transaction record to Firestore
5. M-Pesa sends prompt to customer's phone
6. Customer enters PIN and confirms payment
7. M-Pesa sends callback to webhook
8. Cloud Function processes callback and updates Firestore
9. App polls payment status periodically
10. Payment confirmed → Order created → Navigate to home
```

### Key Components

#### MpesaService (`lib/services/mpesa_service.dart`)
```dart
// Initiate STK Push
await mpesaService.initiateStkPush(
  phoneNumber: '0712345678',
  amount: 1000.0,
  accountReference: 'ORDER123',
  transactionDescription: 'Purchase Order'
)

// Query STK Status
await mpesaService.queryStkStatus(
  checkoutRequestId: 'checkoutId'
)

// Parse Callback
final result = MpesaService.parseCallback(callbackData)
```

#### PaymentProvider (`lib/providers/payment_provider.dart`)
```dart
// Initiate payment with STK Push
await paymentProvider.initiateMpesaPayment(
  phoneNumber: '0712345678',
  amount: 1000.0,
  orderId: 'ORDER123',
  customerEmail: 'user@example.com'
)

// Check payment status
await paymentProvider.checkPaymentStatus(
  checkoutRequestId: 'checkoutId'
)

// Process callback
paymentProvider.processCallback(callbackData)
```

## Payment Status Codes

| ResultCode | Status | Meaning |
|-----------|--------|---------|
| 0 | Success | Payment completed successfully |
| 1 | User Cancelled | User cancelled the payment prompt |
| 2 | Timeout | Payment prompt expired (STK timeout) |
| 1032 | Cancelled by Service | M-Pesa system issue |
| Other | Failed | Various M-Pesa errors |

## Firestore Data Structure

### Transactions Collection
```json
{
  "orderId": "ORDER123",
  "phoneNumber": "+254712345678",
  "amount": 1000.0,
  "paymentMethod": "mpesa",
  "status": "completed|pending|failed",
  "checkoutRequestId": "ws_CO_DMZ_123456789_012345678",
  "requestId": "25150403191559818",
  "mpesaReceiptNumber": "RCH61V1QZ60",
  "transactionDate": "20231201120000",
  "failureReason": "User cancelled",
  "createdAt": "2023-12-01T12:00:00Z",
  "updatedAt": "2023-12-01T12:05:00Z"
}
```

### Orders Collection
```json
{
  "id": "ORDER123",
  "userId": "user_uid",
  "items": [...],
  "totalAmount": 1000.0,
  "paymentMethod": "mpesa",
  "paymentStatus": "completed|pending|failed",
  "transactionId": "RCH61V1QZ60",
  "shippingAddress": "...",
  "createdAt": "2023-12-01T12:00:00Z",
  "updatedAt": "2023-12-01T12:05:00Z"
}
```

## Testing

### Sandbox Environment
- Account Number: 123456
- Amount: Any amount
- Phone: +254712345678 (or any valid Kenyan number)

### Test Credentials
Use the provided sandbox credentials to test STK Push:
```
Consumer Key: A3x09Kvm8A8xiGHha5yloAdL36U3GpZP8nySX4syRGiet4Eu
Consumer Secret: Reg1ULoAJfx88r64LiI3SGrAevNEKhqvYcdOGtCiGsyd1ECmpxrABE9lo1Ltk3uX
```

## Production Migration

### Before Going Live
1. Register for M-Pesa Business Account
2. Get production Consumer Key and Secret from Safaricom
3. Update credentials in:
   - `lib/providers/payment_provider.dart`
   - `functions/.env.local`
   - Firebase Environment Variables
4. Change `MPESA_ENV` from `sandbox` to `production`
5. Update `MPESA_API_URL` to production endpoint
6. Test thoroughly with real tokens

### Production Configuration
```env
MPESA_CONSUMER_KEY=your_production_key
MPESA_CONSUMER_SECRET=your_production_secret
MPESA_SHORTCODE=your_merchant_code
MPESA_PASSKEY=your_production_passkey
MPESA_ENV=production
MPESA_API_URL=https://api.safaricom.co.ke
MPESA_CALLBACK_URL=https://yourdomain.com/api/mpesa/callback
```

## Ngrok Setup for Callbacks

### Local Testing with Ngrok
```bash
# Install ngrok
# https://ngrok.com/download

# Start ngrok on port 3000
ngrok http 3000

# Update callback URL with ngrok URL
# Example: https://1d1d8ae8dadd.ngrok-free.app/user/mpesa/callback
```

## Security Considerations

1. **API Credentials**: Store securely in Firebase Environment Variables
2. **Phone Number Validation**: Validate and format phone numbers properly
3. **Amount Validation**: Validate amounts server-side
4. **Callback Verification**: Save all callbacks and verify against Firestore
5. **HTTPS Only**: Always use HTTPS for callback endpoints
6. **Rate Limiting**: Implement rate limiting on payment endpoints
7. **Logging**: Log all transactions for audit trail

## Troubleshooting

### Common Issues

#### "Failed to get access token"
- Check Consumer Key and Secret
- Verify API credentials are correct
- Check network connectivity

#### "Invalid phone number format"
- Ensure phone starts with 07 or 254
- Remove spaces and special characters
- Test with known valid number: 0712345678

#### "Callback not received"
- Check ngrok URL is public
- Verify callback URL in M-Pesa settings
- Check firewall/security rules
- Review Cloud Functions logs

#### "Payment status stuck on pending"
- Use "Check Payment Status" button in app
- Verify checkoutRequestId is correct
- Check Firestore for transaction record

## Support & Resources

- [Daraja API Documentation](https://developer.safaricom.co.ke/apis)
- [M-Pesa STK Push Documentation](https://developer.safaricom.co.ke/apis/post-simulate-stk-push)
- [Firebase Cloud Functions](https://firebase.google.com/docs/functions)
- [Flutter Firebase Integration](https://firebase.flutter.dev/)

## Next Steps

1. ✅ Configure Flutter SDK with M-Pesa service
2. ✅ Deploy Cloud Functions
3. ✅ Test STK Push in sandbox
4. ✅ Implement callback handling
5. ⏳ Test payment status checking
6. ⏳ Load test payment processing
7. ⏳ Get production approval from Safaricom
8. ⏳ Migrate to production environment
