# M-Pesa Integration Deployment Checklist ✅

## Pre-Deployment

- [x] M-Pesa credentials provided
- [x] MpesaService implemented
- [x] PaymentProvider updated
- [x] PaymentScreen enhanced
- [x] Cloud Functions created
- [x] Firestore rules ready
- [x] Documentation complete
- [x] Code compiled (0 errors)
- [x] Environment variables configured

## Deployment Steps

### Step 1: Install Dependencies
```bash
cd functions
npm install
```
- [ ] firebase-admin installed
- [ ] firebase-functions installed
- [ ] axios installed
- [ ] express installed
- [ ] cors installed

### Step 2: Configure Firebase

```bash
firebase init functions  # If not already set up
```

### Step 3: Deploy Cloud Functions
```bash
firebase deploy --only functions
```

After deployment, you'll see:
```
✓ functions[initiateMpesaPayment(us-central1)] deployed
✓ functions[mpesaCallback(us-central1)] deployed
✓ functions[queryStkPushStatus(us-central1)] deployed
✓ functions[verifyPayment(us-central1)] deployed
```

- [ ] Deployment successful
- [ ] Copy the deployed function URLs

### Step 4: Update Callback URL

In `lib/providers/payment_provider.dart`, line 26:

```dart
// OLD:
callbackUrl: 'https://1d1d8ae8dadd.ngrok-free.app/user/mpesa/callback',

// NEW (from Firebase Console):
callbackUrl: 'https://YOUR-REGION-YOUR-PROJECT.cloudfunctions.net/mpesaCallback',
```

- [ ] Callback URL updated

### Step 5: Firestore Rules (Optional but Recommended)

Add to your Firestore security rules:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Allow authenticated users to read/write their own orders
    match /orders/{orderId} {
      allow read: if request.auth.uid == resource.data.userId;
      allow write: if request.auth.uid == resource.data.userId;
    }
    
    // Allow Cloud Functions to write transactions
    match /transactions/{transactionId} {
      allow read, write: if request.auth == null || request.auth.token.admin == true;
    }
  }
}
```

- [ ] Firestore rules updated

### Step 6: Test Locally (Optional)

```bash
# Terminal 1: Start Firebase emulator
firebase emulators:start

# Terminal 2: Start ngrok
ngrok http 3000

# Terminal 3: Run Flutter app
flutter run
```

- [ ] Emulator started
- [ ] ngrok running
- [ ] Flutter app running
- [ ] Test payment flow

### Step 7: Test Payment Flow

1. Open Edsushy Shop app
2. Add products to cart
3. Go to Checkout
4. Enter customer details:
   - [ ] Name: Test User
   - [ ] Email: test@example.com
   - [ ] Phone: 0712345678
   - [ ] Address: Test Address

5. Select Payment Method:
   - [ ] M-Pesa selected

6. Place Order:
   - [ ] Click "Place Order"
   - [ ] Review order details

7. Payment Screen:
   - [ ] Amount displays correctly
   - [ ] Phone shows: 0712345678
   - [ ] Agree to terms
   - [ ] Click "Complete Payment"

8. STK Push:
   - [ ] Loading indicator shown
   - [ ] STK prompt appears on phone
   - [ ] App shows "Please check your phone"

9. Confirm Payment:
   - [ ] Enter M-Pesa PIN on phone
   - [ ] Payment confirmed
   - [ ] App shows success message

10. Order Confirmation:
    - [ ] Navigates back to home
    - [ ] "Order placed successfully" shown
    - [ ] Cart is cleared

### Step 8: Verify Firestore

Check Firebase Console:

```
Collections → transactions → [orderID]
```

Should see:
```
{
  "orderId": "...",
  "phoneNumber": "+254712345678",
  "amount": 1000,
  "status": "completed",
  "mpesaReceiptNumber": "RCH61V1QZ60",
  "createdAt": timestamp,
  "updatedAt": timestamp,
  "checkoutRequestId": "...",
  "requestId": "..."
}
```

- [ ] Transaction logged
- [ ] Receipt number saved
- [ ] Status is "completed"

### Step 9: Check Cloud Function Logs

```bash
firebase functions:log
```

Should see entries for:
- [ ] initiateMpesaPayment called
- [ ] STK Push sent
- [ ] mpesaCallback received
- [ ] Transaction updated

---

## Post-Deployment Verification

### Functionality Checks
- [ ] STK Push sends correctly
- [ ] Callback received and processed
- [ ] Firestore updated with transaction
- [ ] Order created in orders collection
- [ ] Cart cleared after successful payment
- [ ] Error messages display correctly
- [ ] User can cancel and retry payment
- [ ] Loading states work properly

### Security Checks
- [ ] Credentials not exposed in logs
- [ ] HTTPS enforced
- [ ] CORS properly configured
- [ ] Phone numbers validated
- [ ] Amounts verified
- [ ] Callbacks authenticated
- [ ] Error messages sanitized

### Performance Checks
- [ ] API calls within 30 second timeout
- [ ] No memory leaks in long-running sessions
- [ ] Token caching working (API calls faster)
- [ ] Firestore writes within limits
- [ ] No N+1 database queries

---

## Production Readiness

Before going live:

### Requirements
- [ ] Registered M-Pesa Business account with Safaricom
- [ ] Production API credentials obtained
- [ ] Production domain secured
- [ ] HTTPS certificate configured
- [ ] Database backups configured
- [ ] Error monitoring set up (Firebase Crashlytics)
- [ ] Payment monitoring enabled

### Configuration Updates
```dart
// In lib/providers/payment_provider.dart

MpesaService(
  consumerKey: 'PRODUCTION_KEY',        // ← Update this
  consumerSecret: 'PRODUCTION_SECRET',  // ← Update this
  shortcode: 'PRODUCTION_SHORTCODE',    // ← Update this
  passkey: 'PRODUCTION_PASSKEY',        // ← Update this
  callbackUrl: 'https://yourdomain.com/callback', // ← Update this
  isSandbox: false,  // ← CRITICAL: Change to false
)
```

- [ ] Consumer Key updated
- [ ] Consumer Secret updated
- [ ] Shortcode updated
- [ ] Passkey updated
- [ ] Callback URL changed to production domain
- [ ] isSandbox set to false
- [ ] All credentials verified

### Testing in Production
- [ ] Test with real M-Pesa account
- [ ] Test with different amounts
- [ ] Verify callback webhook
- [ ] Monitor logs for errors
- [ ] Test error scenarios
- [ ] Load test with multiple payments
- [ ] Verify payment reconciliation

### Monitoring
- [ ] Set up Firebase Crashlytics
- [ ] Monitor Cloud Function performance
- [ ] Track payment failure rate
- [ ] Set up alerts for errors
- [ ] Monitor Firestore usage

---

## Rollback Plan

If issues occur:

1. **Immediate**: Disable payment in UI (show "Maintenance" message)
2. **Investigate**: Check Cloud Function logs
3. **Fix**: Update code and redeploy
4. **Verify**: Test complete payment flow
5. **Re-enable**: Update UI to show payment again
6. **Monitor**: Watch logs for 24 hours

- [ ] Rollback plan documented
- [ ] Contact info for Safaricom support documented
- [ ] Emergency contact created

---

## Support Contacts

| Contact | Info |
|---------|------|
| **Safaricom Daraja** | https://developer.safaricom.co.ke |
| **Firebase Support** | https://firebase.google.com/support |
| **Documentation** | See MPESA_INTEGRATION.md |

---

## Final Checklist

- [ ] All files created/updated
- [ ] Code compiles with 0 errors
- [ ] Dependencies installed
- [ ] Cloud Functions deployed
- [ ] Callback URL updated
- [ ] Firestore rules configured
- [ ] Payment flow tested
- [ ] Transaction logged
- [ ] Logs reviewed
- [ ] Ready for production

---

## Sign-Off

**Completed by**: [Your Name]
**Date**: February 11, 2026
**Status**: ✅ READY TO DEPLOY

---

**Next**: Deploy to Firebase and test with real M-Pesa account! 🚀

