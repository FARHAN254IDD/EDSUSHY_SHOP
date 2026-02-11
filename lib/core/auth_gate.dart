import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../features/auth/login_screen.dart';
import '../features/home/home_screen.dart';
import '../features/admin/admin_home_screen.dart';
import '../providers/user_provider.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (!authSnapshot.hasData) {
          return LoginScreen();
        }

        final user = authSnapshot.data!;

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get(),
          builder: (context, snapshot) {
            // Loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // Firestore error
            if (snapshot.hasError) {
              final err = snapshot.error.toString();
              final isPerm = err.contains('permission-denied');

              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(isPerm
                          ? 'Permission denied when accessing your user data. Please check Firestore rules.'
                          : 'Error loading user: ${snapshot.error}'),
                      const SizedBox(height: 12),
                      if (isPerm) ...[
                        ElevatedButton(
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                          },
                          child: const Text('Sign out'),
                        ),
                        const SizedBox(height: 8),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text(
                            'Tip: In the Firebase console update your Firestore rules to allow authenticated users to read their own user document (see README for details).',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            // Request a rebuild to retry
                            (context as Element).markNeedsBuild();
                          },
                          child: const Text('Retry'),
                        ),
                    ],
                  ),
                ),
              );
            }

            // No data (unexpected) — show loader briefly
            if (!snapshot.hasData || snapshot.data == null) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final doc = snapshot.data!;
            final userData = doc.data() as Map<String, dynamic>?;

            // If user doc does not exist in Firestore, create a minimal one then proceed
            if (!doc.exists || userData == null) {
              FirebaseFirestore.instance.collection('users').doc(user.uid).set({
                'email': user.email,
                'role': 'user',
                'createdAt': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));

              Future.microtask(() {
                context.read<UserProvider>().fetchUser(user.uid);
              });

              return const HomeScreen();
            }

            final role = userData['role'] ?? 'customer';

            // Update user provider
            Future.microtask(
              () {
                context.read<UserProvider>().fetchUser(user.uid);
              },
            );

            // Route based on role
            if (role == 'admin') {
              return const AdminHomeScreen();
            } else {
              return const HomeScreen();
            }
          },
        );
      },
    );
  }
}
