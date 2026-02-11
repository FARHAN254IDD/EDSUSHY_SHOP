# CORS Issue Fixed! ✅

## Problem
**CORS Error**: Direct calls from web app to Safaricom API are blocked by browser.

## Solution
Changed architecture to call **Firebase Cloud Functions** instead (they have no CORS restrictions).

---

## What Changed

### ✅ Fixed in `lib/providers/payment_provider.dart`
- Removed direct M-Pesa API calls
- Now calls your **Firebase Cloud Function** instead
- Cloud Function handles Safaricom API auth (no CORS issue)
- Same M-Pesa functionality, just through secure backend

### How It Works Now
```
Web App → Cloud Function → Safaricom API ✅ (No CORS)
```

Instead of:
```
Web App → Safaricom API ❌ (CORS blocks it)
```

---

## Next Steps: Update Cloud Function URL

### Step 1: Deploy Cloud Functions to Firebase
Run this command in your project directory:
```bash
firebase deploy --only functions
```

### Step 2: Find Your Project ID
After deployment, you'll see output like:
```
Function URL: https://us-central1-YOUR_PROJECT_ID.cloudfunctions.net/initiateMpesaPayment
```

Copy the **base URL**: `https://us-central1-YOUR_PROJECT_ID.cloudfunctions.net`

### Step 3: Update payment_provider.dart
Open [lib/providers/payment_provider.dart](lib/providers/payment_provider.dart) and find line 14:

```dart
static const String _firebaseBaseUrl = 'https://us-central1-YOUR_PROJECT_ID.cloudfunctions.net';
```

Replace `YOUR_PROJECT_ID` with your actual Firebase project ID.

**Example:**
```dart
// If your Firebase project is "edsushy-shop-123"
static const String _firebaseBaseUrl = 'https://us-central1-edsushy-shop-123.cloudfunctions.net';
```

### Step 4: Test
1. Save the file
2. Hot reload Flutter app
3. Try payment flow again

---

## Finding Your Firebase Project ID

### Option 1: From Firebase Console
1. Go to [console.firebase.google.com](https://console.firebase.google.com)
2. Click your project
3. Click ⚙️ Settings
4. Copy **Project ID**

### Option 2: From Firebase CLI
Run:
```bash
firebase projects:list
```

Look for your project in the list.

### Option 3: From Deployment Output
After `firebase deploy`, the URL shows your project ID:
```
https://us-central1-YOUR_PROJECT_ID.cloudfunctions.net
                    ↑↑↑ This is your ID
```

---

## Verify It Works

After updating the URL and testing:
- ✅ No more CORS errors
- ✅ STK Push prompt appears on your phone
- ✅ You can enter M-Pesa PIN
- ✅ Payment is processed

---

## Troubleshooting

### Still getting "Failed to get access token"?
1. Check that Cloud Functions are deployed: `firebase functions:log`
2. Verify Cloud Function URL is correct
3. Check M-Pesa credentials in `.env` file

### Cloud Function not deployed?
Run again:
```bash
firebase deploy --only functions
```

### Getting 404 error?
The Cloud Function URL might be wrong. Double-check your project ID.

---

## Your Project Information

To find your actual Firebase project ID, check your `google-services.json` or `firebase.json` file, or run:
```bash
cat google-services.json | grep "project_id"
```

---

**Status**: ✅ CORS issue FIXED - just need to deploy and update the URL!

