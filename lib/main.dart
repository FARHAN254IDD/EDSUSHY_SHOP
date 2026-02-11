import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/product_provider.dart';
import 'providers/order_provider.dart';
import 'providers/user_provider.dart';
import 'providers/payment_provider.dart';
import 'providers/admin_provider.dart';
import 'providers/review_provider.dart';
import 'providers/wishlist_provider.dart';
import 'features/auth/login_screen.dart';
import 'features/customer/checkout_screen.dart';
import 'features/customer/search_products_screen.dart';
import 'features/customer/cart_screen.dart';
import 'features/settings/profile_screen.dart';
import 'features/settings/help_screen.dart';
import 'features/settings/contact_support_screen.dart';
import 'core/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Edsushy Shop',
            theme: themeProvider.currentTheme,
            darkTheme: ThemeData.dark(),
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const AuthGate(),
            routes: {
              '/login': (context) => LoginScreen(),
              '/search': (context) => const SearchProductsScreen(),
              '/cart': (context) => const CartScreen(),
              '/checkout': (context) => const CheckoutScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/help': (context) => const HelpScreen(),
              '/contact': (context) => const ContactSupportScreen(),
            },
          );
        },
      ),
    );
  }
}
