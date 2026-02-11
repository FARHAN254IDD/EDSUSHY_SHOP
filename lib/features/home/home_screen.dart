import 'package:flutter/material.dart';
import 'enhanced_home_screen.dart';
import '../customer/cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (_selectedIndex == 0) {
      return const EnhancedHomeScreen();
    } else {
      return const CartScreen();
    }
  }
}
