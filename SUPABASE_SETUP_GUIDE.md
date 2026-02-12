# Supabase Storage Setup Guide

## Complete Step-by-Step Setup Instructions

### 1. Create a Supabase Account & Project

1. **Go to [supabase.com](https://supabase.com)**
2. **Click "Start your project"** (Sign up if needed with email or GitHub)
3. **Create a new organization** (optional - or use default)
4. **Create a new project:**
   - Project name: `edsushy_shop` (or your preferred name)
   - Database password: Create a **strong password** (save it!)
   - Region: Choose the region closest to you (e.g., Europe, North America, Asia)
   - Click **"Create new project"**
5. **Wait for project initialization** (2-3 minutes)

---

### 2. Get Your Supabase Credentials

Once your project is ready:

1. **Go to Project Settings** (gear icon in bottom left)
2. **Click "API"** in the sidebar
3. **Copy these values:**
   - **Project URL** (looks like: `https://xxxxx.supabase.co`)
   - **anon key** (your public key)
   - **service_role key** (keep secret - only for backend)

---

### 3. Configure Supabase in Your Flutter App

**Update `lib/services/supabase_service.dart`:**

```dart
static const String supabaseUrl = 'https://xxxxx.supabase.co'; // Your URL
static const String supabaseAnonKey = 'your_anon_key_here'; // Your Key
```

Replace `xxxxx` with your actual Supabase project URL and key.

---

### 4. Create Storage Bucket

1. **In Supabase Dashboard**, click **"Storage"** (left sidebar)
2. **Click "Create a new bucket"**
3. **Bucket name:** `products` (must match `SupabaseService.productBucket`)
4. **Privacy:** Choose "Private" initially (we'll set RLS policies)
5. **Click "Create bucket"**

---

### 5. Set Up Row Level Security (RLS) Policies

Storage policies control who can upload/download images.

#### **Step 1: Enable RLS for Storage**

1. Go to **Storage** → **Buckets** → Click **"products"** bucket
2. Click **"Policies"** tab
3. If not enabled, click **"Enable RLS"**

#### **Step 2: Create Upload Policy (Admin Only)**

```sql
CREATE POLICY "Admins can upload product images"
ON storage.objects
FOR INSERT
WITH CHECK (
  auth.role() = 'authenticated' 
  AND EXISTS (
    SELECT 1 FROM public.users 
    WHERE id = auth.uid() AND role = 'admin'
  )
);
```

#### **Step 3: Create Download Policy (Public)**

```sql
CREATE POLICY "Public can view product images"
ON storage.objects
FOR SELECT
USING (bucket_id = 'products');
```

#### **Step 4: Create Delete Policy (Admin Only)**

```sql
CREATE POLICY "Admins can delete product images"
ON storage.objects
FOR DELETE
USING (
  bucket_id = 'products' 
  AND auth.role() = 'authenticated'
  AND EXISTS (
    SELECT 1 FROM public.users 
    WHERE id = auth.uid() AND role = 'admin'
  )
);
```

**Via Dashboard:**
1. Click **"New Policy"** or **"Edit Policy"**
2. Select Template: **"Custom"**
3. Paste the SQL above
4. Click **"Review"** → **"Save"**

---

### 6. Database Setup (Optional but Recommended)

Add a `products` table with image URL storage:

```sql
CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  admin_id UUID NOT NULL REFERENCES auth.users(id),
  name VARCHAR(255) NOT NULL,
  description TEXT,
  price DECIMAL(10, 2) NOT NULL,
  discount_percentage DECIMAL(5, 2) DEFAULT 0,
  stock INT NOT NULL DEFAULT 0,
  category VARCHAR(100),
  image_urls TEXT[] DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Enable RLS
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- Admins can insert
CREATE POLICY "Admins can insert products" ON products
FOR INSERT
WITH CHECK (
  auth.uid() = admin_id 
  AND EXISTS (
    SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'admin'
  )
);

-- Everyone can view
CREATE POLICY "Everyone can view products" ON products
FOR SELECT
USING (true);

-- Admins can update their products
CREATE POLICY "Admins can update their products" ON products
FOR UPDATE
USING (auth.uid() = admin_id);

-- Admins can delete their products
CREATE POLICY "Admins can delete their products" ON products
FOR DELETE
USING (auth.uid() = admin_id);
```

---

## How to Use in Your App

### **Upload Product Image**

```dart
import 'package:image_picker/image_picker.dart';
import 'services/image_storage_service.dart';

// Pick image
final picker = ImagePicker();
final pickedFile = await picker.pickImage(source: ImageSource.gallery);

if (pickedFile != null) {
  final File imageFile = File(pickedFile.path);
  
  // Upload to Supabase
  final imageUrl = await ImageStorageService().uploadProductImage(
    imageFile: imageFile,
    productId: productId,
  );
  
  print('Image uploaded: $imageUrl');
}
```

### **Upload Multiple Images**

```dart
final imageUrls = await ImageStorageService().uploadMultipleProductImages(
  imageFiles: [file1, file2, file3],
  productId: productId,
);

print('All images uploaded: $imageUrls');
```

### **Display Image**

```dart
Image.network(
  imageUrl,
  fit: BoxFit.cover,
  errorBuilder: (context, error, stackTrace) {
    return const Icon(Icons.image_not_supported);
  },
)
```

### **Delete Image**

```dart
await ImageStorageService().deleteProductImage(
  imagePath: imageUrl,
);
```

### **Delete Multiple Images**

```dart
await ImageStorageService().deleteProductImages(
  imagePaths: productImageUrls,
);
```

---

## Integration with Admin Provider

Update your `AdminProvider` to handle image uploads:

```dart
class AdminProvider extends ChangeNotifier {
  final ImageStorageService _storageService = ImageStorageService();
  List<String> _productImageUrls = [];

  List<String> get productImageUrls => _productImageUrls;

  Future<void> addProduct({
    required String name,
    required String description,
    required double price,
    required int stock,
    required List<File> imageFiles,
  }) async {
    try {
      // Upload images first
      final imageUrls = await _storageService.uploadMultipleProductImages(
        imageFiles: imageFiles,
        productId: DateTime.now().millisecondsSinceEpoch.toString(),
      );

      _productImageUrls = imageUrls;

      // Save product to Firestore with image URLs
      await FirebaseFirestore.instance.collection('products').add({
        'name': name,
        'description': description,
        'price': price,
        'stock': stock,
        'imageUrls': imageUrls,
        'createdAt': DateTime.now(),
      });

      notifyListeners();
    } catch (e) {
      print('Error adding product: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct({
    required String productId,
    required List<String> imageUrls,
  }) async {
    try {
      // Delete images from Supabase
      await _storageService.deleteProductImages(imagePaths: imageUrls);

      // Delete product from Firestore
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .delete();

      notifyListeners();
    } catch (e) {
      print('Error deleting product: $e');
      rethrow;
    }
  }
}
```

---

## Troubleshooting

### **Issue: "Invalid API Key" error**
- ✅ Verify you copied the correct `anon key` (not `service_role key`)
- ✅ Make sure URL and key match your project

### **Issue: "Bucket not found"**
- ✅ Verify bucket name is exactly `products`
- ✅ Check if bucket was created in your project

### **Issue: "Permission denied" on upload**
- ✅ Check RLS policies are set correctly
- ✅ Verify user has admin role in database
- ✅ Use authenticated user's token

### **Issue: Images not showing**
- ✅ Check RLS policies allow public download
- ✅ Verify image URL is correct (starts with `https://`)
- ✅ Check image file exists in storage bucket

---

## Best Practices

1. **Security:**
   - Use `anon key` in Flutter (public)
   - Keep `service_role key` secret (backend only)
   - Always enable RLS on storage buckets

2. **Organization:**
   - Use folders like `product_images/{product_id}/`
   - Generate unique filenames with UUID
   - Delete old images when updating products

3. **Performance:**
   - Compress images before upload
   - Use CDN URLs for faster loading
   - Cache images locally in your app

4. **Cost:**
   - Supabase offers 1GB free storage/month
   - Monitor usage in Project Settings → Storage

---

## Useful Links

- 📚 [Supabase Docs](https://supabase.com/docs)
- 🎥 [Supabase Storage Tutorial](https://supabase.com/docs/guides/storage)
- 📖 [Flutter Supabase Package](https://pub.dev/packages/supabase_flutter)
- 🔐 [RLS Policies Guide](https://supabase.com/docs/guides/auth/row-level-security)

---

## Next Steps

1. ✅ Complete the setup above
2. ✅ Test uploads with the admin dashboard
3. ✅ Monitor storage usage
4. ✅ For production: Set up backups & monitoring

Need help? Check [supabase.com/docs](https://supabase.com/docs) or contact Supabase support!
