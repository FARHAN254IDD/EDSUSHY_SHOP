# Customer Profile Update Feature

## ✅ What's Been Added

### 1. **Enhanced User Model** (`lib/models/user_model.dart`)
Added two new fields:
- `fullName` - Customer's full name
- `profilePhotoUrl` - URL to profile photo stored in Firebase Storage

### 2. **Enhanced User Provider** (`lib/providers/user_provider.dart`)
Added three new features:
- `uploadProfilePhoto()` - Upload profile photo to Firebase Storage
- `updateUserProfile()` - Update user profile information
- `clearProfileError()` - Clear error messages

### 3. **Profile Display Screen** (`lib/features/customer/profile_screen.dart`)
Shows customer's complete profile:
- Profile photo (circle avatar)
- Full name
- Email
- Phone number
- Address
- Account type (customer/admin)
- Member since date
- **Edit Profile** button
- Sign out button (placeholder for future)

### 4. **Profile Edit Screen** (`lib/features/customer/profile_edit_screen.dart`)
Allows customers to:
- **Upload/Change Profile Photo** - Click camera icon
- **Update Full Name** - Text field
- **Update Phone Number** - Text field with phone keyboard
- **Update Address** - Multi-line text field
- **View Email** - Read-only (cannot be changed from here)

---

## 🚀 How to Use

### For Customer Users:

1. **Navigate to Profile Screen**
   ```dart
   Navigator.push(
     context,
     MaterialPageRoute(builder: (context) => const ProfileScreen()),
   );
   ```

2. **View Current Profile**
   - See all profile information
   - View profile photo

3. **Edit Profile**
   - Click "Edit Profile" button
   - Update any field (optional, can leave blank)
   - Click camera icon to change photo
   - Select image from gallery
   - Click "Save Profile"

### For Developers:

**Access Current User:**
```dart
final userProvider = context.read<UserProvider>();
final user = userProvider.currentUser;
print(user?.fullName);
print(user?.profilePhotoUrl);
```

**Update User Profile Programmatically:**
```dart
await userProvider.updateUserProfile(
  uid: userId,
  fullName: 'John Doe',
  phoneNumber: '0712345678',
  address: '123 Main St, City',
);
```

**Upload Photo Only:**
```dart
final photoUrl = await userProvider.uploadProfilePhoto(imageFile, userId);
```

---

## 🎨 UI Features

### Profile Screen:
- Beautiful card layout with profile information
- Large circular profile photo
- Color-coded buttons (purple for edit, red for signout)
- Organized information sections

### Profile Edit Screen:
- Photo upload with camera button overlay
- Input fields with icons
- Loading indicator during save
- Error messages on failure
- Success notification after save

---

## 🔒 Security & Storage

**Storage Structure:**
```
Firebase Storage:
└── profile_photos/
    └── {userId}/
        └── {timestamp}.jpg
```

**Firestore Structure:**
```
users collection:
├── email
├── role
├── phoneNumber
├── address
├── fullName
└── profilePhotoUrl
```

---

## 📱 Requirements

These features require:
- ✅ `image_picker` package - For selecting photos
- ✅ `firebase_storage` package - For storing photos
- ✅ `firebase_firestore` package - For profile data

All are already in your `pubspec.yaml`!

---

## 🔗 Integration Points

### Add Profile to Customer Dashboard:

In your customer dashboard/settings, add:
```dart
ListTile(
  title: const Text('My Profile'),
  leading: const Icon(Icons.person),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  },
)
```

### Navigation Example:

```dart
// In any customer screen
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  },
  child: const Text('View My Profile'),
)
```

---

## ✨ Features Summary

| Feature | Status | Details |
|---------|--------|---------|
| View Profile | ✅ Complete | Read-only display with formatted info |
| Edit Name | ✅ Complete | Text field with validation |
| Edit Phone | ✅ Complete | Phone keyboard input |
| Edit Address | ✅ Complete | Multi-line text input |
| Upload Photo | ✅ Complete | Gallery picker with image compression |
| Save to Firestore | ✅ Complete | All data persists |
| Save to Firebase Storage | ✅ Complete | Photos stored securely |
| Error Handling | ✅ Complete | User-friendly error messages |
| Loading States | ✅ Complete | Progress indicator during save |

---

## 🎯 Next Steps (Optional Enhancements)

Future features you could add:
1. **Delete Account** - With confirmation dialog
2. **Change Email** - With verification
3. **Change Password** - Separate flow
4. **Photo Gallery** - Show previous photos
5. **Account Preferences** - Newsletter, notifications, etc.
6. **Social Links** - Instagram, Twitter, etc.

---

## 🐛 Troubleshooting

### Profile photo not showing?
- Check Firebase Storage permissions
- Verify image URL is accessible
- Check internet connection

### Save not working?
- Check Firestore rules allow writes
- Verify user is authenticated
- Check console for error messages

### Image picker not working?
- Ensure `image_picker` is installed
- Check app permissions (Android/iOS)
- Try restarting the app

---

## 📝 Code Example

```dart
// Complete example: Navigate to profile and make changes
class CustomerDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfileScreen(),
              ),
            );
          },
          child: const Text('Go to My Profile'),
        ),
      ),
    );
  }
}
```

---

**All features are production-ready and fully integrated with your Firebase backend!** ✅
