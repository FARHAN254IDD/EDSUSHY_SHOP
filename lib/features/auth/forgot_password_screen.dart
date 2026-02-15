import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailCtrl = TextEditingController();
  final auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool _isSending = false;

  @override
  void dispose() {
    emailCtrl.dispose();
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
                      'Reset Password',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isWide ? 28 : 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Enter your email and we will send you a reset link.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: isWide ? 14 : 13,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
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
                            validator: (value) {
                              final email = value?.trim() ?? '';
                              if (email.isEmpty) {
                                return 'Please enter your email.';
                              }
                              final emailRegex = RegExp(
                                r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                              );
                              if (!emailRegex.hasMatch(email)) {
                                return 'Enter a valid email address.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                          ElevatedButton(
                            onPressed: _isSending
                                ? null
                                : () async {
                                    if (!(_formKey.currentState?.validate() ??
                                        false)) {
                                      return;
                                    }
                                    setState(() => _isSending = true);
                                    try {
                                      await auth.resetPassword(
                                        emailCtrl.text.trim(),
                                      );
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Reset link sent. Check your email.',
                                          ),
                                        ),
                                      );
                                      Navigator.pop(context);
                                    } catch (e) {
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Reset failed: ${e.toString()}',
                                          ),
                                        ),
                                      );
                                    } finally {
                                      if (mounted) {
                                        setState(() => _isSending = false);
                                      }
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
                            child: Text(
                              _isSending ? 'Sending...' : 'Send reset link',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Back to login'),
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
