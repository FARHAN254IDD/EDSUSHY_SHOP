import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // EMAIL REGISTER
  Future<void> register(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _firestore.collection('users').doc(cred.user!.uid).set({
      'email': email,
      'role': 'customer',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // EMAIL LOGIN
  Future<User?> login(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }

  // GOOGLE SIGN-IN
  Future<User?> signInWithGoogle() async {
    try {
      // WEB: use Firebase popup/redirect flow (more reliable than platform JS popup)
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        try {
          final userCred = await _auth.signInWithPopup(provider);
          final user = userCred.user;

          if (user != null) {
            final doc = await _firestore.collection('users').doc(user.uid).get();
            if (!doc.exists) {
              await _firestore.collection('users').doc(user.uid).set({
                'email': user.email,
                'role': 'customer',
                'createdAt': FieldValue.serverTimestamp(),
              });
            }
          }

          return user;
        } on FirebaseAuthException catch (e) {
          // If popup blocked/closed, fall back to redirect flow (works around popup blockers)
          if (e.code.contains('popup') || (e.message?.toLowerCase().contains('popup') ?? false)) {
            await _auth.signInWithRedirect(provider);
            // Redirect will navigate away and complete the flow on return; return null for now
            return null;
          }
          rethrow;
        }
      }

      // MOBILE/OTHER: use google_sign_in plugin
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // User closed the sign-in popup or cancelled the flow
        throw FirebaseAuthException(
            code: 'popup-closed',
            message: 'Google sign-in was cancelled or the popup closed.');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCred = await _auth.signInWithCredential(credential);

      final doc = await _firestore
          .collection('users')
          .doc(userCred.user!.uid)
          .get();

      if (!doc.exists) {
        await _firestore.collection('users').doc(userCred.user!.uid).set({
          'email': userCred.user!.email,
          'role': 'customer',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return userCred.user;
    } catch (e) {
      // Re-throw so UI can display the exact error
      rethrow;
    }
  }

  // GUEST LOGIN
  Future<User?> signInAsGuest() async {
    final cred = await _auth.signInAnonymously();
    return cred.user;
  }

  // FORGOT PASSWORD
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }
}
