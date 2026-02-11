#!/bin/bash
# M-Pesa Integration Deployment Script
# Run this script to deploy M-Pesa integration to Firebase

echo "🚀 M-Pesa STK Push Integration Deployment"
echo "=========================================="
echo ""

# Step 1: Install Node Dependencies
echo "📦 Step 1: Installing Node Dependencies..."
cd functions
npm install
if [ $? -eq 0 ]; then
    echo "✅ Dependencies installed successfully"
else
    echo "❌ Failed to install dependencies"
    exit 1
fi
cd ..
echo ""

# Step 2: Check Firebase login
echo "🔐 Step 2: Checking Firebase authentication..."
firebase projects:list > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Firebase authenticated"
else
    echo "⚠️  Need to login to Firebase"
    echo "Run: firebase login"
    exit 1
fi
echo ""

# Step 3: Deploy Cloud Functions
echo "📤 Step 3: Deploying Cloud Functions..."
firebase deploy --only functions
if [ $? -eq 0 ]; then
    echo "✅ Cloud Functions deployed successfully"
else
    echo "❌ Failed to deploy Cloud Functions"
    exit 1
fi
echo ""

# Step 4: Get deployed function URLs
echo "📋 Step 4: Getting deployed function URLs..."
echo ""
echo "Your deployed Cloud Functions are available at:"
echo "================================================="
echo ""
firebase functions:list
echo ""
echo "⚠️  IMPORTANT: Update the callback URL in:"
echo "   lib/providers/payment_provider.dart"
echo ""
echo "Replace the callback URL with your deployed function URL:"
echo "   https://YOUR-REGION-YOUR-PROJECT.cloudfunctions.net/mpesaCallback"
echo ""

# Step 5: Summary
echo "✅ Deployment Complete!"
echo ""
echo "📝 Next Steps:"
echo "  1. Copy the deployed function URL above"
echo "  2. Update CALLBACK_URL in payment_provider.dart (line ~26)"
echo "  3. Run 'flutter run' to test the payment flow"
echo "  4. Check Firebase Console → Cloud Functions for logs"
echo ""
echo "🧪 To test locally with ngrok:"
echo "  1. Open another terminal: ngrok http 3000"
echo "  2. Get the ngrok URL (https://xxxxx.ngrok-free.app)"
echo "  3. Update CALLBACK_URL with: https://xxxxx.ngrok-free.app/mpesaCallback"
echo ""
echo "Documentation:"
echo "  - MPESA_INTEGRATION.md      (Complete setup guide)"
echo "  - MPESA_QUICK_START.md      (Quick reference)"
echo "  - MPESA_COMPLETE.md         (Implementation summary)"
echo ""

