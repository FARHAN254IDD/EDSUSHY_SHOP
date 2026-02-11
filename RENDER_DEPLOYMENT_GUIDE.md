# Render Deployment Guide

## Step 1: Initialize Git Repository

```bash
cd C:\Users\IDD FARHAN\Desktop\edsushy_shop
git init
git add .
git commit -m "Initial commit with M-Pesa backend"
```

## Step 2: Create GitHub Repository

1. Go to [github.com](https://github.com)
2. Sign up (if not already)
3. Click **"New"** to create new repository
4. Name it: `edsushy-shop`
5. Click **"Create repository"**

## Step 3: Push Code to GitHub

```bash
git remote add origin https://github.com/YOUR_USERNAME/edsushy-shop.git
git branch -M main
git push -u origin main
```

Replace `YOUR_USERNAME` with your actual GitHub username.

## Step 4: Deploy to Render

1. Go to [render.com](https://render.com)
2. Click **"Sign up"** and select **"GitHub"**
3. Authorize GitHub
4. Click **"New +"** → **"Web Service"**
5. Select your `edsushy-shop` repository
6. Fill in the form:
   - **Name**: `edsushy-mpesa-backend`
   - **Runtime**: Node
   - **Build Command**: `cd functions && npm install`
   - **Start Command**: `cd functions && node server.js`
   - **Plan**: Free
7. Click **"Create Web Service"**

## Step 5: Wait for Deployment

Render will:
- Build your app (2-3 minutes)
- Deploy it (1-2 minutes)
- Give you a URL like: `https://edsushy-mpesa-backend.onrender.com`

## Step 6: Update Flutter App

Once you have the Render URL, update your Flutter app:

In `lib/providers/payment_provider.dart`, change line 14:

```dart
// OLD:
static const String _firebaseBaseUrl = 'https://77f5-129-222-187-201.ngrok-free.app';

// NEW (replace with your Render URL):
static const String _firebaseBaseUrl = 'https://edsushy-mpesa-backend.onrender.com';
```

## Step 7: Update Callback URL in .env

In `.env` file, update the callback URL:

```bash
# OLD:
MPESA_CALLBACK_URL=https://77f5-129-222-187-201.ngrok-free.app/user/mpesa/callback

# NEW:
MPESA_CALLBACK_URL=https://edsushy-mpesa-backend.onrender.com/user/mpesa/callback
```

Then push to GitHub:
```bash
git add .
git commit -m "Update backend URL to Render"
git push
```

Render will automatically redeploy.

## Step 8: Test on Render

1. Hot reload your Flutter app
2. Go through checkout flow
3. Complete payment
4. STK prompt should appear on your phone
5. No more ngrok needed!

---

## Important Notes

- ✅ Render URL is **permanent** (won't change)
- ✅ Server runs **24/7** (great for presentation)
- ✅ Free tier is **good enough** for testing
- ⚠️ Server will **sleep after 30 minutes** of inactivity (wakes up automatically on first request, takes 30 seconds)
  - Solution: Keep a tab open before presentation to keep it awake

## Troubleshooting

### URL not working?
- Wait 5 minutes for full deployment
- Check Render dashboard for build errors
- Restart the service on Render

### Getting 500 errors?
- Check the `.env` file has correct M-Pesa credentials
- View logs on Render dashboard
- Make sure code was pushed correctly

### payment failing?
- Verify `.env` callback URL matches Render URL
- Check M-Pesa credentials are correct in `.env`
- Test with sandbox credentials first

---

## Your Render URL (Once Deployed)
```
https://edsushy-mpesa-backend.onrender.com
```

Save this URL for your presentation!
