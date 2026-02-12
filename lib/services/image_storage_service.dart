import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class ImageStorageService {
  static final ImageStorageService _instance = ImageStorageService._internal();

  factory ImageStorageService() {
    return _instance;
  }

  ImageStorageService._internal();

  static const uuid = Uuid();

  /// Upload an image file to Supabase storage (Mobile)
  /// Returns the public URL of the uploaded image
  Future<String> uploadProductImage({
    required File imageFile,
    required String productId,
    String fileName = '',
  }) async {
    try {
      // Generate unique filename if not provided
      final String uniqueFileName = fileName.isEmpty
          ? '${productId}_${uuid.v4()}.jpg'
          : fileName;

      final String path = 'product_images/$productId/$uniqueFileName';

      // Read file as bytes
      final bytes = await imageFile.readAsBytes();

      // Upload bytes to Supabase Storage
      await SupabaseService.client.storage
          .from(SupabaseService.productBucket)
          .uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      // Get public URL
      final publicUrl = SupabaseService.client.storage
          .from(SupabaseService.productBucket)
          .getPublicUrl(path);

      print('✅ Image uploaded successfully: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('❌ Image upload failed: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Upload an image from XFile (Web compatible)
  /// Returns the public URL of the uploaded image
  Future<String> uploadProductImageWeb({
    required XFile imageFile,
    required String productId,
    String fileName = '',
  }) async {
    try {
      // Generate unique filename if not provided
      final String uniqueFileName = fileName.isEmpty
          ? '${productId}_${uuid.v4()}.jpg'
          : fileName;

      final String path = 'product_images/$productId/$uniqueFileName';

      // Read file as bytes
      final bytes = await imageFile.readAsBytes();

      print('Uploading ${bytes.length} bytes to Supabase Storage...');

      // Upload bytes to Supabase Storage
      await SupabaseService.client.storage
          .from(SupabaseService.productBucket)
          .uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      // Get public URL
      final publicUrl = SupabaseService.client.storage
          .from(SupabaseService.productBucket)
          .getPublicUrl(path);

      print('✅ Image uploaded successfully: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('❌ Image upload failed: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Upload image from bytes directly
  Future<String> uploadProductImageBytes({
    required Uint8List bytes,
    required String productId,
    String fileName = '',
  }) async {
    try {
      // Generate unique filename if not provided
      final String uniqueFileName = fileName.isEmpty
          ? '${productId}_${uuid.v4()}.jpg'
          : fileName;

      final String path = 'product_images/$productId/$uniqueFileName';

      print('Uploading ${bytes.length} bytes to Supabase Storage...');

      // Upload bytes to Supabase Storage
      await SupabaseService.client.storage
          .from(SupabaseService.productBucket)
          .uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      // Get public URL
      final publicUrl = SupabaseService.client.storage
          .from(SupabaseService.productBucket)
          .getPublicUrl(path);

      print('✅ Image uploaded successfully: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('❌ Image upload failed: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Upload multiple images for a product
  Future<List<String>> uploadMultipleProductImages({
    required List<File> imageFiles,
    required String productId,
  }) async {
    try {
      List<String> uploadedUrls = [];

      for (int i = 0; i < imageFiles.length; i++) {
        final url = await uploadProductImage(
          imageFile: imageFiles[i],
          productId: productId,
          fileName: 'image_${i + 1}.jpg',
        );
        uploadedUrls.add(url);
      }

      return uploadedUrls;
    } catch (e) {
      print('❌ Multiple upload failed: $e');
      throw Exception('Failed to upload multiple images: $e');
    }
  }

  /// Delete an image from Supabase storage
  Future<void> deleteProductImage({
    required String imagePath,
  }) async {
    try {
      // Extract relative path from full URL if needed
      String pathToDelete = imagePath;
      if (imagePath.contains('product_images/')) {
        pathToDelete = imagePath.split('product_images/')[1];
        pathToDelete = 'product_images/$pathToDelete';
      }

      await SupabaseService.client.storage
          .from(SupabaseService.productBucket)
          .remove([pathToDelete]);

      print('✅ Image deleted successfully');
    } catch (e) {
      print('❌ Image deletion failed: $e');
      throw Exception('Failed to delete image: $e');
    }
  }

  /// Delete multiple images for a product
  Future<void> deleteProductImages({
    required List<String> imagePaths,
  }) async {
    try {
      final pathsToDelete = imagePaths.map((path) {
        if (path.contains('product_images/')) {
          return path.split('product_images/')[1];
        }
        return path;
      }).map((p) => 'product_images/$p').toList();

      if (pathsToDelete.isNotEmpty) {
        await SupabaseService.client.storage
            .from(SupabaseService.productBucket)
            .remove(pathsToDelete);
      }

      print('✅ Images deleted successfully');
    } catch (e) {
      print('❌ Image deletion failed: $e');
      throw Exception('Failed to delete images: $e');
    }
  }

  /// Get public URL for an image path
  String getPublicUrl(String imagePath) {
    try {
      return SupabaseService.client.storage
          .from(SupabaseService.productBucket)
          .getPublicUrl(imagePath);
    } catch (e) {
      print('❌ Failed to get public URL: $e');
      throw Exception('Failed to get public URL: $e');
    }
  }

  /// List all images in a product directory
  Future<List<String>> listProductImages(String productId) async {
    try {
      final files = await SupabaseService.client.storage
          .from(SupabaseService.productBucket)
          .list(path: 'product_images/$productId');

      return files.map((file) {
        return SupabaseService.client.storage
            .from(SupabaseService.productBucket)
            .getPublicUrl('product_images/$productId/${file.name}');
      }).toList();
    } catch (e) {
      print('❌ Failed to list images: $e');
      return [];
    }
  }

  /// Download/retrieve image as bytes
  Future<List<int>> downloadImage(String imagePath) async {
    try {
      final data = await SupabaseService.client.storage
          .from(SupabaseService.productBucket)
          .download(imagePath);

      return data;
    } catch (e) {
      print('❌ Image download failed: $e');
      throw Exception('Failed to download image: $e');
    }
  }
}
