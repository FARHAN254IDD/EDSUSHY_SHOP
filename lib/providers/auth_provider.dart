import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? user;

  AuthProvider() {
    // Listen to auth state changes
    FirebaseAuth.instance.authStateChanges().listen((User? firebaseUser) {
      user = firebaseUser;
      print('AuthProvider - Auth state changed: ${firebaseUser?.uid}');
      notifyListeners();
    });
  }

  bool get isLoggedIn => user != null;

  Future<void> login(String email, String password) async {
    user = await _authService.login(email, password);
    notifyListeners();
  }

  Future<void> register(String email, String password) async {
    await _authService.register(email, password);
  }

  Future<void> googleLogin() async {
    user = await _authService.signInWithGoogle();
    notifyListeners();
  }

  Future<void> guestLogin() async {
    user = await _authService.signInAsGuest();
    notifyListeners();
  }

  Future<void> resetPassword(String email) async {
    await _authService.resetPassword(email);
  }

  Future<void> logout() async {
    await _authService.logout();
    user = null;
    notifyListeners();
  }
}

