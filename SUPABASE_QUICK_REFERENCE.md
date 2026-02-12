# Supabase Storage Quick Reference

## Setup Checklist

- [ ] Create Supabase account at [supabase.com](https://supabase.com)
- [ ] Create new project and copy credentials
- [ ] Create `products` storage bucket
- [ ] Enable RLS on storage bucket
- [ ] Update `lib/services/supabase_service.dart` with your credentials
- [ ] Run `flutter pub get` to install dependencies
- [ ] Test image upload in admin dashboard

---

## File Structure

```
lib/
├── services/
│   ├── supabase_service.dart          # Supabase initialization
│   └── image_storage_service.dart     # Image upload/download logic
├── providers/
│   └── admin_product_provider.dart    # Admin product management
└── features/
    └── admin/
        └── admin_product_form_screen.dart  # Product form UI
```

---

## Code Snippets

### 1. Upload Single Image

```dart
final imageUrl = await ImageStorageService().uploadProductImage(
  imageFile: File(imagePath),
  productId: 'product_123',
);
```

### 2. Upload Multiple Images

```dart
final imageUrls = await ImageStorageService().uploadMultipleProductImages(
  imageFiles: [file1, file2, file3],
  productId: 'product_123',
);
```

### 3. Display Image from URL

```dart
Image.network(
  imageUrl,
  fit: BoxFit.cover,
  loadingBuilder: (context, child, progress) {
    if (progress == null) return child;
    return const Center(child: CircularProgressIndicator());
  },
  errorBuilder: (context, error, stackTrace) {
    return Container(
      color: Colors.grey[300],
      child: const Icon(Icons.image_not_supported),
    );
  },
)
```

### 4. Delete Image

```dart
await ImageStorageService().deleteProductImage(
  imagePath: imageUrl,
);
```

### 5. List All Product Images

```dart
final imageUrls = await ImageStorageService()
    .listProductImages('product_123');
```

### 6. Add Product (w/ images)

```dart
await Provider.of<AdminProductProvider>(context, listen: false)
    .addProduct(
  name: 'Product Name',
  description: 'Product Description',
  price: 99.99,
  discount: 10.0,
  stock: 50,
  category: 'Electronics',
  imageFiles: [file1, file2],
  adminId: 'admin_user_id',
);
```

### 7. Update Product

```dart
await Provider.of<AdminProductProvider>(context, listen: false)
    .updateProduct(
  productId: 'product_123',
  name: 'Updated Name',
  description: 'Updated Description',
  price: 149.99,
  discount: 15.0,
  stock: 100,
  category: 'Electronics',
  newImageFiles: [newFile1, newFile2],
  imageUrlsToDelete: [oldImageUrl1],
);
```

### 8. Delete Product (w/ images)

```dart
await Provider.of<AdminProductProvider>(context, listen: false)
    .deleteProduct(productId: 'product_123');
```

---

## Integrating with Your Admin Provider

Add to your existing `AdminProvider`:

```dart
import '../services/image_storage_service.dart';

class AdminProvider extends ChangeNotifier {
  final ImageStorageService _storageService = ImageStorageService();
  
  // Upload product images
  Future<List<String>> uploadProductImages(List<File> files, String productId) async {
    return await _storageService.uploadMultipleProductImages(
      imageFiles: files,
      productId: productId,
    );
  }
}
```

---

## Common Issues & Solutions

### **"Invalid credentials" error**
```dart
// ❌ WRONG - Make sure you're using anon key, not service_role key
static const String supabaseAnonKey = 'service_role_...' // ❌

// ✅ CORRECT
static const String supabaseAnonKey = 'eyJhbGc...' // Public key starting with 'ey'
```

### **"Bucket not found" error**
```dart
// ❌ WRONG - Bucket name must be lowercase
static const String productBucket = 'ProductImages'; // ❌

// ✅ CORRECT
static const String productBucket = 'products'; // lowercase
```

### **Images not loading**
```dart
// ✅ Make sure RLS policy allows public SELECT on storage.objects
// ✅ Check image URL starts with https://

// If URL is broken, regenerate it:
String publicUrl = SupabaseService.client.storage
    .from(SupabaseService.productBucket)
    .getPublicUrl(imagePath);
```

### **Upload fails with "Permission denied"**
```dart
// ✅ Ensure user has admin role in database
// ✅ Check RLS policy for INSERT on storage.objects
// ✅ Verify user is authenticated before uploading
```

---

## Performance Tips

### 1. **Compress images before upload**
```dart
import 'package:image/image.dart' as img;

Future<File> compressImage(File imageFile) async {
  final bytes = await imageFile.readAsBytes();
  final image = img.decodeImage(bytes);
  final compressed = img.encodeJpg(image!, quality: 70);
  
  return File(imageFile.path)..writeAsBytesSync(compressed);
}

// Usage
final compressedFile = await compressImage(originalFile);
final url = await ImageStorageService().uploadProductImage(
  imageFile: compressedFile,
  productId: productId,
);
```

### 2. **Cache images locally**
```dart
Image.network(
  imageUrl,
  cacheWidth: 400,
  cacheHeight: 400,
)
```

### 3. **Use CDN for faster delivery**
Supabase automatically uses a CDN for storage files. No extra setup needed!

---

## Monitoring

### Check storage usage
1. Go to Supabase Dashboard → Project Settings
2. Click **Storage** tab
3. View current usage and storage quota

### Monitor upload bandwidth
- Free tier: 50 GB/month outbound
- Upgrade if needed in Project Settings

---

## Support & Resources

- 📚 **Docs**: https://supabase.com/docs
- 🔧 **Storage Guide**: https://supabase.com/docs/guides/storage
- 💬 **Discord**: https://discord.supabase.com
- 🐛 **Issues**: https://github.com/supabase/supabase/issues

---

## Next Steps

1. ✅ Complete [SUPABASE_SETUP_GUIDE.md](SUPABASE_SETUP_GUIDE.md)
2. ✅ Update credentials in `supabase_service.dart`
3. ✅ Test upload with sample images
4. ✅ Integrate with admin dashboard
5. ✅ Monitor storage usage regularly

---

**Questions?** Check the full setup guide or Supabase docs!
