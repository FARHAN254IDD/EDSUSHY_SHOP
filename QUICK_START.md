# 🚀 Quick Start Guide - Edsushy Shop

## 5-Minute Setup

### Prerequisites
- Flutter 3.x installed
- Dart 3.10+ installed
- Firebase account
- Code editor (VS Code/Android Studio)

---

## Step 1: Clone & Install (2 min)
```bash
cd your-project-directory
flutter pub get
```

---

## Step 2: Firebase Setup (2 min)

### Option A: Use Existing Firebase Project
1. Download `google-services.json` from Firebase Console
2. Place in `android/app/` directory
3. Configure iOS in Xcode (if needed)

### Option B: Create New Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create project → `edsushy-shop`
3. Add Flutter app
4. Download configuration files
5. Follow setup wizard

---

## Step 3: Enable Firebase Services (1 min)

In Firebase Console:
- ✅ Authentication (Email/Password + Google)
- ✅ Cloud Firestore
- ✅ Cloud Storage

---

## Step 4: Deploy Security Rules

```bash
firebase deploy --only firestore:rules
```

Or manually paste from `firestore.rules` in console.

---

## Step 5: Run the App (Even faster!)

```bash
flutter run
```

---

## 🎯 Testing the App

### Test User Account Setup

#### Customer Account
1. Click Register
2. Email: `customer@test.com`
3. Password: `Test@123456`
4. Role: customer (automatic)

#### Admin Account
1. Go to Firebase Console → Firestore
2. Create new user document:
   - Path: `users/{firebase-uid}`
   - Data:
     ```json
     {
       "email": "admin@test.com",
       "role": "admin",
       "createdAt": "2024-01-15T10:00:00Z"
     }
     ```
3. Use same email to register in app

---

## 🔍 Test Each Feature

### 1. Authentication
- [ ] Sign up with email
- [ ] Login with email
- [ ] Google Sign-In
- [ ] Password reset
- [ ] Logout

### 2. Products (Customer)
- [ ] Browse all products
- [ ] Search by name
- [ ] Filter by category
- [ ] View product details
- [ ] Check ratings

### 3. Shopping
- [ ] Add item to cart
- [ ] Update quantity
- [ ] Remove item
- [ ] View cart total
- [ ] Clear cart

### 4. Checkout
- [ ] Enter shipping details
- [ ] Select payment method
- [ ] Review order
- [ ] Place order

### 5. Admin Features
- [ ] Login as admin
- [ ] View admin dashboard
- [ ] Add new product
- [ ] Edit product
- [ ] Delete product

### 6. Settings
- [ ] Toggle dark mode
- [ ] View profile
- [ ] Read FAQs
- [ ] Contact form

---

## 📱 Add Sample Products

Go to Firebase Console → Firestore → Create collection → `products`

Click "Add document" and paste:

```json
{
  "category": "Electronics",
  "createdAt": "2024-01-15T10:00:00Z",
  "description": "Latest flagship smartphone with advanced features",
  "imageUrl": "https://via.placeholder.com/400x300?text=iPhone+15",
  "name": "iPhone 15 Pro",
  "price": 89999,
  "rating": 4.5,
  "reviewCount": 128,
  "stock": 50
}
```

Repeat for more products with different categories:
- Electronics
- Clothing
- Books
- Home & Kitchen

---

## 🔧 Configuration Files

### Main Configuration
- `pubspec.yaml` - Dependencies
- `lib/main.dart` - App entry point
- `lib/firebase_options.dart` - Firebase config

### Key Files to Update

**M-Pesa Integration** (Optional - Payment)
Edit: `lib/providers/payment_provider.dart`
```dart
// Update this URL with your Cloud Function
static const String mpesaApiUrl = 
  'https://your-project.cloudfunctions.net/initiateMpesaPayment';
```

---

## 🐛 Common Issues & Solutions

### Issue: "google-services.json not found"
**Solution:** Download from Firebase Console → Project Settings → google-services.json

### Issue: "Firestore rules blocking access"
**Solution:** Deploy rules with `firebase deploy --only firestore:rules`

### Issue: "User role not found"
**Solution:** Create user document in Firestore with role field

### Issue: "Images not loading"
**Solution:** Use valid image URLs in product data

### Issue: "App not responding to taps"
**Solution:** Check hot reload - full restart with `flutter clean && flutter run`

---

## 📚 Documentation Map

| Document | Purpose |
|----------|---------|
| [README.md](README.md) | Project overview |
| [COMPLETION_SUMMARY.md](COMPLETION_SUMMARY.md) | What's included |
| [IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md) | Detailed features |
| [FIREBASE_SETUP.md](FIREBASE_SETUP.md) | Backend setup |
| [FEATURE_MAP.md](FEATURE_MAP.md) | User flows & architecture |
| [FILES_REFERENCE.md](FILES_REFERENCE.md) | File listing |

---

## 🎓 Learning Path

1. **Start Here:** [COMPLETION_SUMMARY.md](COMPLETION_SUMMARY.md)
2. **Understand Features:** [IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md)
3. **Setup Backend:** [FIREBASE_SETUP.md](FIREBASE_SETUP.md)
4. **Explore Code:** Review files in `lib/` directory
5. **Advanced:** Check [FEATURE_MAP.md](FEATURE_MAP.md) for architecture

---

## 💡 Pro Tips

### Development
```bash
# Clean build
flutter clean && flutter pub get

# Hot reload (during development)
flutter run -v

# Build APK for testing
flutter build apk --release
```

### Debugging
```bash
# Enable verbose logging
flutter run -v

# Check device logs
flutter logs

# Open DevTools
flutter pub global run devtools
```

### Performance
- Use `--split-per-abi` for faster APK builds
- Test on real device for accurate performance
- Monitor Firestore reads/writes in console

---

## 🚀 Next Steps After Setup

1. **Add Real Products**
   - Go to Firebase Firestore
   - Create product documents
   - Add product images to Cloud Storage

2. **Test Payment Flow** (Optional)
   - Get M-Pesa credentials
   - Setup Cloud Functions
   - Test STK Push

3. **Customize Branding**
   - Update app name in `pubspec.yaml`
   - Change app icon
   - Modify colors in theme providers

4. **Deploy to Production**
   - Switch Firestore to production rules
   - Update M-Pesa to live credentials
   - Build signed APK/IPA

---

## 📞 Quick Support

### Check These First
- [ ] Is Firebase initialized?
- [ ] Are security rules deployed?
- [ ] Is user role set in Firestore?
- [ ] Are sample products added?
- [ ] Does network connection work?

### Still Stuck?
1. Check relevant documentation file
2. Review error messages in console
3. Check Firestore rules syntax
4. Verify Firebase project setup

---

## ✅ Setup Verification Checklist

- [ ] Flutter installed & working
- [ ] Project cloned/created
- [ ] Firebase project created
- [ ] google-services.json downloaded
- [ ] `flutter pub get` completed
- [ ] Firestore database created
- [ ] Authentication enabled
- [ ] Firestore rules deployed
- [ ] Test users created
- [ ] Sample products added
- [ ] App runs without errors
- [ ] Can create account
- [ ] Can view products
- [ ] Can add to cart
- [ ] Dark mode toggles

---

## 🎉 You're Ready!

Your Edsushy Shop is now set up and ready to use!

### What You Have
✅ Complete e-commerce app  
✅ Admin dashboard  
✅ Product management  
✅ Shopping cart  
✅ Payment integration (ready)  
✅ Order tracking  
✅ User authentication  
✅ Dark/Light mode  
✅ Search & filter  
✅ Settings & support  

### Next: Customize & Deploy
- Update product data
- Configure M-Pesa (payment)
- Add your branding
- Deploy to app stores

---

**Happy Coding! 🎉**

For detailed help, see the [IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md)
