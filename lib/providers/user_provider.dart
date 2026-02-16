import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import '../models/user_model.dart';
import '../services/supabase_service.dart';

class UserProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  AppUser? _currentUser;
  List<AppUser> _allUsers = [];
  List<AppUser> _blockedUsers = [];
  bool _isLoading = false;
  bool _isUpdatingProfile = false;
  String? _profileUpdateError;

  AppUser? get currentUser => _currentUser;
  List<AppUser> get allUsers => _allUsers;
  List<AppUser> get blockedUsers => _blockedUsers;
  bool get isLoading => _isLoading;
  bool get isUpdatingProfile => _isUpdatingProfile;
  String? get profileUpdateError => _profileUpdateError;

  Future<void> fetchUser(String uid) async {
    try {
      _isLoading = true;
      _profileUpdateError = null;
      notifyListeners();
      
      print('=== FETCHING USER: $uid ===');
      print('Auth user: ${FirebaseAuth.instance.currentUser?.uid}');
      print('Auth email: ${FirebaseAuth.instance.currentUser?.email}');
      
      final doc = await _firestore.collection('users').doc(uid).get();
      print('Document exists: ${doc.exists}');
      
      if (doc.exists) {
        print('Document data: ${doc.data()}');
        _currentUser = AppUser.fromMap(uid, doc.data() ?? {});
        print('✅ User loaded successfully: ${_currentUser?.email}, Role: ${_currentUser?.role}');
      } else {
        print('⚠️ User document does not exist for uid: $uid');
        print('📝 Creating user document with customer role...');
        
        // Get email from Firebase Auth
        final authUser = FirebaseAuth.instance.currentUser;
        if (authUser == null) {
          throw Exception('No authenticated user found');
        }
        
        final email = authUser.email ?? 'user@example.com';
        print('Using email: $email');
        
        // Create the user document
        final userData = {
          'email': email,
          'role': 'customer',
          'isBlocked': false,
          'createdAt': FieldValue.serverTimestamp(),
        };
        
        print('Writing to Firestore: $userData');
        await _firestore.collection('users').doc(uid).set(userData);
        
        print('✅ User document created, fetching again...');
        
        // Fetch again
        await Future.delayed(const Duration(milliseconds: 500)); // Small delay for Firestore
        final newDoc = await _firestore.collection('users').doc(uid).get();
        if (newDoc.exists) {
          _currentUser = AppUser.fromMap(uid, newDoc.data() ?? {});
          print('✅ User loaded after creation: ${_currentUser?.email}');
        } else {
          throw Exception('Failed to create user document');
        }
      }
    } catch (e, stackTrace) {
      print('❌ ERROR fetching user: $e');
      _profileUpdateError = e.toString();
      
      if (e.toString().contains('permission-denied')) {
        print('❌ FIRESTORE PERMISSION DENIED!');
        print('Please check your firestore.rules file');
        _profileUpdateError = 'Permission denied. Please check Firestore rules.';
      } else if (e.toString().contains('network')) {
        _profileUpdateError = 'Network error. Check your internet connection.';
      }
      
      print('Stack trace: $stackTrace');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllUsers() async {
    _isLoading = true;
    notifyListeners();
    try {
      print('🔍 Fetching all users from Firestore...');
      final snapshot = await _firestore.collection('users').get();
      print('📊 Found ${snapshot.docs.length} user documents');
      
      _allUsers = snapshot.docs
          .map((doc) {
            final data = doc.data();
            final email = data['email']?.toString() ?? 'No email';
            final displayEmail = (email.isEmpty || email == 'null') ? 'No email' : email;
            print('👤 User ${doc.id}: role="${data['role']}", email="$displayEmail"');
            return AppUser.fromMap(doc.id, data);
          })
          .toList();
      
      _blockedUsers = _allUsers.where((user) => user.isBlocked).toList();
      
      print('✅ Loaded ${_allUsers.length} users total');
      print('👥 Customers (role=customer): ${_allUsers.where((u) => u.role == 'customer').length}');
      print('👥 Users (role=user): ${_allUsers.where((u) => u.role == 'user').length}');
      print('👮 Admins: ${_allUsers.where((u) => u.role == 'admin').length}');
      print('❓ Unknown roles: ${_allUsers.where((u) => u.role != 'customer' && u.role != 'admin').map((u) => '${u.email}:${u.role}').join(', ')}');
      
      notifyListeners();
    } catch (e) {
      print('❌ Error fetching users: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createUser(String uid, String email, String role) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'email': email,
        'role': role,
        'isBlocked': false,
        'createdAt': DateTime.now().toIso8601String(),
      });
      _currentUser = AppUser(
        uid: uid,
        email: email,
        role: role,
        createdAt: DateTime.now(),
      );
      notifyListeners();
    } catch (e) {
      print('Error creating user: $e');
    }
  }

  Future<void> updateUserRole(String uid, String role) async {
    try {
      await _firestore.collection('users').doc(uid).update({'role': role});
      if (_currentUser?.uid == uid) {
        _currentUser = AppUser(
          uid: uid,
          email: _currentUser!.email,
          role: role,
          createdAt: _currentUser!.createdAt,
        );
        notifyListeners();
      }
      await fetchAllUsers();
    } catch (e) {
      print('Error updating user role: $e');
    }
  }

  Future<void> blockUser(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({'isBlocked': true});
      await fetchAllUsers();
    } catch (e) {
      print('Error blocking user: $e');
      rethrow;
    }
  }

  Future<void> unblockUser(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({'isBlocked': false});
      await fetchAllUsers();
    } catch (e) {
      print('Error unblocking user: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getUserOrderHistory(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      print('Error fetching user order history: $e');
      return [];
    }
  }

  String get userRole => _currentUser?.role ?? 'customer';
  bool get isAdmin => userRole == 'admin';

  /// Upload profile photo to Firebase Storage
  Future<String?> uploadProfilePhoto(File photoFile, String uid) async {
    try {
      print('📸 Starting mobile photo upload...');
      _isUpdatingProfile = true;
      _profileUpdateError = null;
      notifyListeners();

      final fileName = '$uid/${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      print('Reading photo bytes...');
      final bytes = await photoFile.readAsBytes();
      print('Photo size: ${bytes.length} bytes');
      
      print('Uploading to Supabase Storage...');
      await SupabaseService.client.storage
          .from(SupabaseService.profilePhotosBucket)
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );
      
      print('Getting public URL...');
      final photoUrl = SupabaseService.client.storage
          .from(SupabaseService.profilePhotosBucket)
          .getPublicUrl(fileName);
      print('✅ Photo uploaded successfully: $photoUrl');

      _isUpdatingProfile = false;
      notifyListeners();
      return photoUrl;
    } catch (e, stackTrace) {
      print('❌ ERROR uploading photo: $e');
      print('Stack trace: $stackTrace');
      _isUpdatingProfile = false;
      _profileUpdateError = 'Error uploading photo: $e';
      notifyListeners();
      return null;
    }
  }

  /// Upload profile photo to Supabase Storage (Web version)
  Future<String?> uploadProfilePhotoWeb(XFile photoFile, String uid) async {
    try {
      print('📸 Starting web photo upload...');
      _isUpdatingProfile = true;
      _profileUpdateError = null;
      notifyListeners();

      final fileName = '$uid/${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      print('Reading photo bytes...');
      final bytes = await photoFile.readAsBytes();
      print('Photo size: ${bytes.length} bytes');
      
      print('Uploading to Supabase Storage...');
      await SupabaseService.client.storage
          .from(SupabaseService.profilePhotosBucket)
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );
      
      print('Getting public URL...');
      final photoUrl = SupabaseService.client.storage
          .from(SupabaseService.profilePhotosBucket)
          .getPublicUrl(fileName);
      print('✅ Photo uploaded successfully: $photoUrl');

      _isUpdatingProfile = false;
      notifyListeners();
      return photoUrl;
    } catch (e, stackTrace) {
      print('❌ ERROR uploading web photo: $e');
      print('Stack trace: $stackTrace');
      _isUpdatingProfile = false;
      _profileUpdateError = 'Error uploading photo: $e';
      notifyListeners();
      return null;
    }
  }

  /// Update user profile information
  Future<bool> updateUserProfile({
    required String uid,
    String? fullName,
    String? phoneNumber,
    String? address,
    String? profilePhotoUrl,
  }) async {
    try {
      _isUpdatingProfile = true;
      _profileUpdateError = null;
      notifyListeners();

      print('=== UPDATING PROFILE: $uid ===');
      
      final updateData = <String, dynamic>{};
      if (fullName != null) updateData['fullName'] = fullName;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
      if (address != null) updateData['address'] = address;
      if (profilePhotoUrl != null) updateData['profilePhotoUrl'] = profilePhotoUrl;

      print('Update data: $updateData');
      
      // Use set with merge to ensure fields are created if they don't exist
      await _firestore.collection('users').doc(uid).set(updateData, SetOptions(merge: true));
      
      print('✅ Profile updated in Firestore');

      // Fetch the updated user data
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _currentUser = AppUser.fromMap(uid, doc.data() ?? {});
        print('✅ User data refreshed: ${_currentUser?.fullName}');
      }

      _isUpdatingProfile = false;
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      print('❌ ERROR updating profile: $e');
      print('Stack trace: $stackTrace');
      _isUpdatingProfile = false;
      _profileUpdateError = 'Error updating profile: $e';
      notifyListeners();
      return false;
    }
  }

  /// Clear profile update error message
  void clearProfileError() {
    _profileUpdateError = null;
    notifyListeners();
  }
}
