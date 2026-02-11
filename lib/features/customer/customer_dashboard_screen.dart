import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/cart_provider.dart';
import 'product_list_screen.dart';
import 'my_orders_screen.dart';
import 'wishlist_screen.dart';
import 'profile_screen.dart';
import 'cart_screen.dart';

class CustomerDashboardScreen extends StatefulWidget {
  const CustomerDashboardScreen({super.key});

  @override
  State<CustomerDashboardScreen> createState() => _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  int _selectedIndex = 0;

  final List<String> _labels = ['Home', 'Orders', 'Wishlist', 'Profile'];
  final List<IconData> _icons = [Icons.home, Icons.receipt_long, Icons.favorite, Icons.person];

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const ProductListScreen(),
      MyOrdersScreen(onStartShopping: () {
        setState(() {
          _selectedIndex = 0; // Navigate to Home tab
        });
      }),
      WishlistScreen(onBrowseProducts: () {
        setState(() {
          _selectedIndex = 0; // Navigate to Home tab
        });
      }),
      const ProfileScreen(),
    ];

    Future.microtask(() async {
      final auth = context.read<AuthProvider>();
      if (auth.user != null) {
        await context.read<UserProvider>().fetchUser(auth.user!.uid);
        await context.read<OrderProvider>().fetchUserOrders(auth.user!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edsushy Shop'),
        elevation: 0,
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              return Stack(
                alignment: Alignment.topRight,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CartScreen()),
                      );
                    },
                  ),
                  if (cartProvider.cartItems.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      child: Text(
                        '${cartProvider.cartItems.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        items: List.generate(
          _labels.length,
          (index) => BottomNavigationBarItem(
            icon: Icon(_icons[index]),
            label: _labels[index],
          ),
        ),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
