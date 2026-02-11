# Deployment Checklist - Render

## Step 1: Prepare GitHub ✓ (Already Done)
- [x] Created `.gitignore` to protect sensitive files
- [x] Created `render.yaml` for automatic configuration
- [x] Files ready to push

---

## Step 2: Initialize Git (Do This First)

Open Command Prompt and run:
```bash
cd C:\Users\IDD FARHAN\Desktop\edsushy_shop
git init
git add .
git commit -m "Initial commit: M-Pesa backend with Render config"
```

---

## Step 3: Create GitHub Account (2 minutes)

1. Go to [github.com](https://github.com)
2. Click **"Sign up"**
3. Create account with email and password
4. Verify email
5. Done!

---

## Step 4: Create GitHub Repository (2 minutes)

1. Go to [github.com/new](https://github.com/new)
2. **Repository name**: `edsushy-shop`
3. **Description**: M-Pesa Payment Integration Backend
4. Select **"Public"** (free public repos)
5. Click **"Create repository"**
6. Copy the HTTPS URL (like `https://github.com/YOUR_USERNAME/edsushy-shop.git`)

---

## Step 5: Push Code to GitHub (2 minutes)

In Command Prompt, replace `YOUR_USERNAME` and run:

```bash
git remote add origin https://github.com/YOUR_USERNAME/edsushy-shop.git
git branch -M main
git push -u origin main
```

Then enter your GitHub username and password (or use personal access token).

---

## Step 6: Deploy to Render (5 minutes)

1. Go to [render.com](https://render.com)
2. Click **"Sign up"** → **"Continue with GitHub"**
3. Authorize GitHub
4. Dashboard will show your repositories
5. Click **"New +"** → **"Web Service"**
6. Select `edsushy-shop` repo
7. Render will auto-detect settings from `render.yaml`
8. Click **"Create Web Service"**
9. **Wait 3-5 minutes** for deployment

---

## Step 7: Get Your Deployment URL

Once deployed:
1. Go to Render dashboard
2. Click on `edsushy-mpesa-backend`
3. Copy the URL (like `https://edsushy-mpesa-backend.onrender.com`)
4. Save it!

---

## Step 8: Update Flutter App

Update these two files with your Render URL:

### File 1: `lib/providers/payment_provider.dart` (Line 14)
```dart
static const String _firebaseBaseUrl = 'https://YOUR_RENDER_URL.onrender.com';
```

### File 2: `.env`
```
MPESA_CALLBACK_URL=https://YOUR_RENDER_URL.onrender.com/user/mpesa/callback
```

---

## Step 9: Push Updates to GitHub

```bash
git add .
git commit -m "Update backend URL to Render"
git push
```

Render will automatically redeploy!

---

## Step 10: Test Payment Flow

1. Hot reload Flutter app
2. Add items to cart
3. Go to checkout
4. Complete payment
5. STK should reach your phone 🎉

---

## ✅ You're Done!

Your backend is now **permanently deployed** on Render!

For presentation:
- ✅ URL will never change
- ✅ Server runs 24/7
- ✅ No manual restarts needed
- ⚠️ Keep a browser tab open 15 mins before presentation (keeps server awake)

---

## Quick Reference

**Render Dashboard**: [https://dashboard.render.com](https://dashboard.render.com)

**Your Service**: `edsushy-mpesa-backend`

**Backend URL**: `https://edsushy-mpesa-backend.onrender.com` (or your custom name)

**GitHub Repo**: `https://github.com/YOUR_USERNAME/edsushy-shop`

---

**Questions?** Check the full guide in `RENDER_DEPLOYMENT_GUIDE.md`
