@echo off
REM M-Pesa Integration Deployment Script for Windows
REM Run this script to deploy M-Pesa integration to Firebase

echo.
echo ===========================================================
echo  M-Pesa STK Push Integration Deployment
echo ===========================================================
echo.

REM Step 1: Install Node Dependencies
echo [1/5] Installing Node Dependencies...
cd functions
call npm install
if errorlevel 1 (
    echo.
    echo ERROR: Failed to install dependencies
    pause
    exit /b 1
)
cd ..
echo [OK] Dependencies installed
echo.

REM Step 2: Check Firebase login
echo [2/5] Checking Firebase authentication...
firebase projects:list >nul 2>&1
if errorlevel 1 (
    echo.
    echo WARNING: Firebase authentication required
    echo Run: firebase login
    pause
    exit /b 1
)
echo [OK] Firebase authenticated
echo.

REM Step 3: Deploy Cloud Functions
echo [3/5] Deploying Cloud Functions...
firebase deploy --only functions
if errorlevel 1 (
    echo.
    echo ERROR: Failed to deploy Cloud Functions
    pause
    exit /b 1
)
echo [OK] Cloud Functions deployed
echo.

REM Step 4: Get deployed function URLs
echo [4/5] Getting deployed function information...
echo.
echo ============================================================
echo Your deployed Cloud Functions are ready!
echo ============================================================
echo.
firebase functions:list
echo.
echo.

REM Step 5: Summary
echo ============================================================
echo [5/5] DEPLOYMENT COMPLETE!
echo ============================================================
echo.
echo NEXT STEPS:
echo -----------
echo.
echo 1. Copy your deployed function URL from above
echo    Example: https://us-central1-your-project.cloudfunctions.net
echo.
echo 2. Update the callback URL in your code:
echo    File: lib/providers/payment_provider.dart
echo    Line: 26 (approximately)
echo.
echo    Replace:
echo      callbackUrl: 'https://1d1d8ae8dadd.ngrok-free.app/user/mpesa/callback'
echo.
echo    With your deployed URL:
echo      callbackUrl: 'https://YOUR-REGION-YOUR-PROJECT.cloudfunctions.net/mpesaCallback'
echo.
echo 3. Run your Flutter app:
echo    flutter run
echo.
echo 4. Test the payment flow:
echo    - Add products to cart
echo    - Go to Checkout
echo    - Enter phone: 0712345678
echo    - Select M-Pesa payment
echo    - Click "Place Order" ^ "Complete Payment"
echo.
echo TROUBLESHOOTING:
echo ================
echo.
echo For local testing with ngrok:
echo   1. Open another Command Prompt
echo   2. Run: ngrok http 3000
echo   3. Copy the ngrok URL (https://xxxxx.ngrok-free.app)
echo   4. Use this URL as your callback URL for testing
echo.
echo To view deployed functions:
echo   firebase functions:list
echo.
echo To view Cloud Function logs:
echo   firebase functions:log
echo.
echo DOCUMENTATION:
echo ===============
echo.
echo - MPESA_INTEGRATION.md      (Complete technical guide)
echo - MPESA_QUICK_START.md      (Quick reference)
echo - MPESA_COMPLETE.md         (Implementation summary)
echo - MPESA_DEPLOYMENT_CHECKLIST.md (Deploy checklist)
echo.
echo ============================================================
echo.

pause
