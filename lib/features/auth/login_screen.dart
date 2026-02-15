import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final auth = AuthService();

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isWide = MediaQuery.of(context).size.width >= 900;

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: colorScheme.outlineVariant),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isWide ? 440 : 520),
            child: Card(
              elevation: 6,
              color: Colors.white,
              shadowColor: Colors.black.withOpacity(0.12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: EdgeInsets.all(isWide ? 32 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Welcome Back',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isWide ? 30 : 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        filled: true,
                        fillColor: Colors.white,
                        border: inputBorder,
                        enabledBorder: inputBorder,
                        focusedBorder: inputBorder.copyWith(
                          borderSide: BorderSide(
                            color: colorScheme.primary,
                            width: 1.6,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: passCtrl,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        filled: true,
                        fillColor: Colors.white,
                        border: inputBorder,
                        enabledBorder: inputBorder,
                        focusedBorder: inputBorder.copyWith(
                          borderSide: BorderSide(
                            color: colorScheme.primary,
                            width: 1.6,
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: const Text('Forgot password?'),
                      ),
                    ),
                    const SizedBox(height: 6),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          final user = await auth.login(
                            emailCtrl.text.trim(),
                            passCtrl.text.trim(),
                          );
                          if (user != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Welcome ${user.email}')),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Login failed: ${e.toString()}'),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Login'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () async {
                        try {
                          final user = await auth.signInWithGoogle();
                          if (user != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Welcome ${user.email}')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Google sign-in was cancelled or redirecting. If nothing happens, check your popup blocker and try again.',
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Google sign-in failed: ${e.toString()}'),
                            ),
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        side: BorderSide(color: colorScheme.outlineVariant),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Continue with Google'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => RegisterScreen()),
                        );
                      },
                      child: const Text('Create an account'),
                    ),
                    TextButton(
                      onPressed: () async {
                        try {
                          final user = await auth.signInAsGuest();
                          if (user != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Continuing as guest'),
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Guest sign-in failed: ${e.toString()}'),
                            ),
                          );
                        }
                      },
                      child: const Text('Continue as guest'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
