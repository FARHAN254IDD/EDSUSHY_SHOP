import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  AppUser? _currentUser;
  List<AppUser> _allUsers = [];
  List<AppUser> _blockedUsers = [];
  bool _isLoading = false;

  AppUser? get currentUser => _currentUser;
  List<AppUser> get allUsers => _allUsers;
  List<AppUser> get blockedUsers => _blockedUsers;
  bool get isLoading => _isLoading;

  Future<void> fetchUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _currentUser = AppUser.fromMap(uid, doc.data() ?? {});
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching user: $e');
    }
  }

  Future<void> fetchAllUsers() async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _firestore.collection('users').get();
      _allUsers = snapshot.docs
          .map((doc) => AppUser.fromMap(doc.id, doc.data()))
          .toList();
      _blockedUsers = _allUsers.where((user) => user.isBlocked).toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching users: $e');
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
}
