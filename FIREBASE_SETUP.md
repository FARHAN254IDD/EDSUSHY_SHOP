# Edsushy Shop - Firebase & Backend Setup Guide

This guide will help you set up the backend infrastructure for the Edsushy Shop application.

## Table of Contents
1. [Firebase Setup](#firebase-setup)
2. [Firestore Database Structure](#firestore-database-structure)
3. [Firebase Authentication Setup](#firebase-authentication-setup)
4. [Cloud Functions Setup (M-Pesa Integration)](#cloud-functions-setup-mpesa-integration)
5. [Firebase Storage Setup](#firebase-storage-setup)
6. [Security Rules](#security-rules)

---

## Firebase Setup

### Step 1: Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a new project"
3. Enter project name: `edsushy-shop`
4. Enable Google Analytics (optional)
5. Create the project

### Step 2: Register Flutter App
1. In Firebase console, click "Add app" 
2. Select Flutter
3. Follow the setup wizard to download `google-services.json` (Android) and configure iOS
4. Copy the configuration to your project

### Step 3: Enable Required Services
1. **Cloud Firestore**
   - Go to Firestore Database
   - Create database in "Test mode" (for development)
   - Select your nearest region

2. **Authentication**
   - Go to Authentication
   - Enable Email/Password provider
   - Enable Google Sign-In provider

3. **Storage**
   - Go to Storage
   - Create bucket with default location

---

## Firestore Database Structure

### Collections Overview

#### 1. Products Collection
```
products/ (collection)
├── {productId} (document)
│   ├── name: string
│   ├── description: string
│   ├── price: number
│   ├── category: string
│   ├── imageUrl: string
│   ├── stock: number
│   ├── rating: number
│   ├── reviewCount: number
│   └── createdAt: timestamp
```

**Example Product Document:**
```json
{
  "name": "iPhone 15",
  "description": "Latest Apple iPhone with 5G",
  "price": 89999,
  "category": "Electronics",
  "imageUrl": "https://...",
  "stock": 50,
  "rating": 4.5,
  "reviewCount": 128,
  "createdAt": "2024-01-15T10:00:00Z"
}
```

#### 2. Users Collection
```
users/ (collection)
├── {userId} (document - uses Firebase Auth UID)
│   ├── email: string
│   ├── role: string (customer|admin)
│   ├── createdAt: timestamp
│   └── phone: string (optional)
```

**Example User Document:**
```json
{
  "email": "user@example.com",
  "role": "customer",
  "createdAt": "2024-01-15T10:00:00Z",
  "phone": "+254712345678"
}
```

#### 3. Orders Collection
```
orders/ (collection)
├── {orderId} (document)
│   ├── userId: string (reference to users)
│   ├── items: array
│   │   └── {item}
│   │       ├── productId: string
│   │       ├── productName: string
│   │       ├── price: number
│   │       └── quantity: number
│   ├── totalAmount: number
│   ├── status: string (pending|confirmed|processing|shipped|delivered|cancelled)
│   ├── paymentMethod: string (mpesa|card|paypal)
│   ├── paymentStatus: string (pending|completed|failed)
│   ├── createdAt: timestamp
│   ├── deliveredAt: timestamp (nullable)
│   ├── shippingAddress: string
│   └── transactionId: string
```

**Example Order Document:**
```json
{
  "userId": "user123",
  "items": [
    {
      "productId": "prod456",
      "productName": "iPhone 15",
      "price": 89999,
      "quantity": 1
    }
  ],
  "totalAmount": 89999,
  "status": "pending",
  "paymentMethod": "mpesa",
  "paymentStatus": "pending",
  "createdAt": "2024-01-15T10:00:00Z",
  "deliveredAt": null,
  "shippingAddress": "123 Main Street, Nairobi, Kenya",
  "transactionId": ""
}
```

### Setting Up Indexes

For optimal search performance, create these indexes:

1. **Products by Category**
   - Collection: `products`
   - Field 1: `category` (Ascending)
   - Field 2: `createdAt` (Descending)

2. **Orders by User**
   - Collection: `orders`
   - Field 1: `userId` (Ascending)
   - Field 2: `createdAt` (Descending)

---

## Firebase Authentication Setup

### Email/Password Auth
1. In Firebase Console → Authentication → Sign-in method
2. Enable "Email/Password"
3. Disable "Email link sign-in" (optional)

### Google Sign-In
1. Enable "Google" in Sign-in methods
2. Configure consent screen:
   - User type: External
   - Add required information
   - Add test users

### Setup in Flutter
The app already has authentication configured in:
- `lib/services/auth_service.dart`
- `lib/providers/auth_provider.dart`

---

## Cloud Functions Setup (M-Pesa Integration)

### Step 1: Initialize Firebase Functions
```bash
firebase init functions
```

### Step 2: Install Dependencies
```bash
cd functions
npm install
```

### Step 3: Create M-Pesa Functions

**File: `functions/index.js`**
```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const axios = require('axios');

admin.initializeApp();

// M-Pesa Configuration
const MPESA_CONSUMER_KEY = process.env.MPESA_CONSUMER_KEY;
const MPESA_CONSUMER_SECRET = process.env.MPESA_CONSUMER_SECRET;
const MPESA_SHORTCODE = process.env.MPESA_SHORTCODE;
const MPESA_PASSKEY = process.env.MPESA_PASSKEY;
const CALLBACK_URL = process.env.CALLBACK_URL;

// Get M-Pesa Access Token
async function getMpesaAccessToken() {
  const auth = Buffer.from(
    `${MPESA_CONSUMER_KEY}:${MPESA_CONSUMER_SECRET}`
  ).toString('base64');

  try {
    const response = await axios.get(
      'https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials',
      {
        headers: {
          Authorization: `Basic ${auth}`,
        },
      }
    );
    return response.data.access_token;
  } catch (error) {
    console.error('Error getting access token:', error);
    throw error;
  }
}

// Initiate M-Pesa STK Push
exports.initiateMpesaPayment = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated'
    );
  }

  const { phoneNumber, amount, orderId, email } = data;

  if (!phoneNumber || !amount || !orderId) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Missing required fields'
    );
  }

  try {
    const accessToken = await getMpesaAccessToken();
    
    // Format phone number (254712345678)
    const formattedPhone = phoneNumber.replace(/^0/, '254');

    // Generate timestamp
    const timestamp = new Date()
      .toISOString()
      .replace(/[:-]/g, '')
      .split('.')[0];

    // Generate password
    const password = Buffer.from(
      `${MPESA_SHORTCODE}${MPESA_PASSKEY}${timestamp}`
    ).toString('base64');

    // Initiate STK Push
    const response = await axios.post(
      'https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest',
      {
        BusinessShortCode: MPESA_SHORTCODE,
        Password: password,
        Timestamp: timestamp,
        TransactionType: 'CustomerPayBillOnline',
        Amount: Math.floor(amount),
        PartyA: formattedPhone,
        PartyB: MPESA_SHORTCODE,
        PhoneNumber: formattedPhone,
        CallBackURL: `${CALLBACK_URL}/mpesaCallback`,
        AccountReference: orderId,
        TransactionDesc: `Payment for order ${orderId}`,
      },
      {
        headers: {
          Authorization: `Bearer ${accessToken}`,
        },
      }
    );

    // Save payment request to database
    await admin.firestore().collection('payments').doc(orderId).set({
      userId: context.auth.uid,
      orderId: orderId,
      phoneNumber: formattedPhone,
      amount: amount,
      email: email,
      status: 'initiated',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      mpesaRequestId: response.data.RequestId,
    });

    return {
      success: true,
      message: 'STK Push initiated successfully',
      requestId: response.data.RequestId,
    };
  } catch (error) {
    console.error('Error initiating M-Pesa payment:', error);
    throw new functions.https.HttpsError(
      'internal',
      'Failed to initiate payment: ' + error.message
    );
  }
});

// Handle M-Pesa Callback
exports.mpesaCallback = functions.https.onRequest(async (req, res) => {
  try {
    const callbackData = req.body.Body.stkCallback;
    const orderId = callbackData.CheckoutRequestID;
    const resultCode = callbackData.ResultCode;

    if (resultCode === 0) {
      // Payment successful
      const callbackMetadata = callbackData.CallbackMetadata;
      const items = callbackMetadata.Item;

      const amount = items.find(item => item.Name === 'Amount').Value;
      const mpesaCode = items.find(item => item.Name === 'MpesaReceiptNumber')
        .Value;
      const phone = items.find(item => item.Name === 'PhoneNumber').Value;

      // Update order status
      await admin.firestore().collection('orders').doc(orderId).update({
        paymentStatus: 'completed',
        transactionId: mpesaCode,
        status: 'confirmed',
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Update payment record
      await admin.firestore().collection('payments').doc(orderId).update({
        status: 'completed',
        mpesaCode: mpesaCode,
        completedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    } else {
      // Payment failed
      await admin.firestore().collection('orders').doc(orderId).update({
        paymentStatus: 'failed',
        status: 'cancelled',
      });
    }

    res.status(200).send({ ResultCode: 0 });
  } catch (error) {
    console.error('Error processing callback:', error);
    res.status(500).send({ ResultCode: 1 });
  }
});

// Check Payment Status
exports.checkPaymentStatus = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated'
    );
  }

  const { orderId } = data;

  try {
    const payment = await admin
      .firestore()
      .collection('payments')
      .doc(orderId)
      .get();

    if (!payment.exists) {
      throw new functions.https.HttpsError(
        'not-found',
        'Payment record not found'
      );
    }

    return {
      status: payment.data().status,
      amount: payment.data().amount,
      createdAt: payment.data().createdAt,
    };
  } catch (error) {
    throw new functions.https.HttpsError(
      'internal',
      'Error checking payment status: ' + error.message
    );
  }
});
```

### Step 4: Configure Environment Variables
Create `.env.local` file:
```
MPESA_CONSUMER_KEY=your_consumer_key
MPESA_CONSUMER_SECRET=your_consumer_secret
MPESA_SHORTCODE=your_shortcode
MPESA_PASSKEY=your_passkey
CALLBACK_URL=your_cloud_function_url
```

### Step 5: Deploy Functions
```bash
firebase deploy --only functions
```

---

## Firebase Storage Setup

### Enable Storage
1. Firebase Console → Storage
2. Create bucket
3. Update security rules for image uploads

### Storage Rules
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /products/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if isAdmin();
    }
    
    function isAdmin() {
      return request.auth != null &&
             get(/databases/(default)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

---

## Security Rules

### Deploy Firestore Rules
The project includes `firestore.rules`. To deploy:

```bash
firebase deploy --only firestore:rules
```

### Key Security Features
- ✅ Public read access to products (authenticated only)
- ✅ Users can only modify their own data
- ✅ Only admins can create/update/delete products
- ✅ Order data is private (users see own, admins see all)
- ✅ Payment information is protected

---

## Testing the Setup

### 1. Test Authentication
```dart
// Login test
await authService.login('test@example.com', 'password123');

// Register test
await authService.register('newuser@example.com', 'password123');
```

### 2. Test Product Management
```dart
// Add product (admin only)
await productProvider.addProduct(productModel);

// Fetch products
await productProvider.fetchProducts();
```

### 3. Test M-Pesa Payment
```dart
// Initiate payment
await paymentProvider.initiateMpesaPayment(
  phoneNumber: '0712345678',
  amount: 1000,
  orderId: 'order123',
  email: 'user@example.com',
);
```

---

## Troubleshooting

### Issue: Functions not deploying
- Check Firebase CLI is installed: `firebase --version`
- Ensure you're logged in: `firebase login`
- Check Node.js version (10.0+ required)

### Issue: M-Pesa errors
- Verify credentials are correct in `.env.local`
- Check Safaricom API status
- Ensure callback URL is accessible
- Test with sandbox credentials first

### Issue: Firestore rules blocking access
- Check user role in Firestore users collection
- Verify authentication before operations
- Check rule syntax in `firestore.rules`

---

## Additional Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [M-Pesa API Documentation](https://developer.safaricom.co.ke/)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/start)
- [Cloud Functions Guide](https://firebase.google.com/docs/functions)

---

## Production Checklist

Before deploying to production:

- [ ] Switch M-Pesa from sandbox to production
- [ ] Update all API keys and secrets
- [ ] Change Firestore from test mode to production rules
- [ ] Enable SSL certificates
- [ ] Set up backup and disaster recovery
- [ ] Configure monitoring and logging
- [ ] Review and audit security rules
- [ ] Test all payment flows
- [ ] Set up customer support channels

