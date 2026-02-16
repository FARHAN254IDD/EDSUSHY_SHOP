import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/product_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/product_model.dart';
import '../../models/notification_model.dart';
import 'edit_product_screen.dart';
import '../../widgets/product_image.dart';
import 'reports_screen.dart';
import '../customer/profile_edit_screen.dart';
import 'app_settings_screen.dart';
import 'security_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  final List<String> _titles = [
    'Products',
    'Orders',
    'Customers',
    'Reports',
    'App Content',
    'Payments',
    'Settings',
  ];

  final List<IconData> _icons = [
    Icons.inventory_2,
    Icons.receipt_long,
    Icons.people,
    Icons.analytics,
    Icons.campaign,
    Icons.payment,
    Icons.settings,
  ];

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const ProductsManagementScreen(),
      const OrdersManagementScreen(),
      const CustomersManagementScreen(),
      const ReportsScreen(),
      const AppContentManagementScreen(),
      const PaymentsManagementScreen(),
      const SettingsScreen(),
    ];
    Future.microtask(() async {
      await context.read<ProductProvider>().fetchProducts();
      await context.read<OrderProvider>().fetchAllOrders();
      await context.read<UserProvider>().fetchAllUsers();
      await context.read<AdminProvider>().fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        elevation: 1,
        centerTitle: false,
      ),
      drawer: _buildDrawer(),
      body: _screens[_selectedIndex],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade700, Colors.blue.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const DrawerHeader(
              decoration: BoxDecoration(color: Colors.transparent),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(Icons.admin_panel_settings, color: Colors.white, size: 40),
                  Text(
                    'Admin Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Manage your store',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ..._buildDrawerItems(),
        ],
      ),
    );
  }

  List<Widget> _buildDrawerItems() {
    return List.generate(
      _titles.length,
      (index) => ListTile(
        leading: Icon(
          _icons[index],
          color: _selectedIndex == index ? Colors.blue : Colors.grey[600],
        ),
        title: Text(
          _titles[index],
          style: TextStyle(
            fontWeight: _selectedIndex == index ? FontWeight.w600 : FontWeight.normal,
            color: _selectedIndex == index ? Colors.blue : Colors.black87,
          ),
        ),
        selected: _selectedIndex == index,
        selectedTileColor: Colors.blue.withOpacity(0.1),
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
          Navigator.pop(context);
        },
      ),
    );
  }
}

class ProductsManagementScreen extends StatelessWidget {
  const ProductsManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        return SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditProductScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add New Product'),
                  ),
                ),
              ),
              if (productProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (productProvider.allProducts.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No products yet. Add one to get started.'),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: productProvider.allProducts.length,
                  itemBuilder: (context, index) {
                    final product = productProvider.allProducts[index];
                    return ProductManagementCard(
                      product: product,
                      onEdit: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditProductScreen(product: product),
                          ),
                        );
                      },
                      onDelete: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Product'),
                            content: const Text(
                                'Are you sure you want to delete this product?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  productProvider.deleteProduct(product.id);
                                  Navigator.pop(context);
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class ProductManagementCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductManagementCard({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              color: Colors.grey[200],
                child: productImageWidget(product, BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'KSh ${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (product.getDiscount() != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${product.getDiscount()}% OFF',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (product.originalPrice != null)
                    Text(
                      'Original: KSh ${product.originalPrice!.toStringAsFixed(2)}',
                      style: const TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    'Stock: ${product.stock}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  onTap: onEdit,
                  child: const Text('Edit'),
                ),
                PopupMenuItem(
                  onTap: onDelete,
                  child: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class OrdersManagementScreen extends StatefulWidget {
  const OrdersManagementScreen({super.key});

  @override
  State<OrdersManagementScreen> createState() => _OrdersManagementScreenState();
}

class _OrdersManagementScreenState extends State<OrdersManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (orderProvider.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (orderProvider.allOrders.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No orders yet.'),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: orderProvider.allOrders.length,
                    itemBuilder: (context, index) {
                      final order = orderProvider.allOrders[index];
                      return OrderCard(order: order);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class OrderCard extends StatelessWidget {
  final dynamic order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.id.substring(0, 8)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(order.userId)
                            .get(),
                        builder: (context, snapshot) {
                          final userEmail = snapshot.data?.get('email') ?? 'User ${order.userId.substring(0, 6)}';
                          return Text(
                            '👤 $userEmail',
                            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    order.status.toString().split('.').last.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Total: KSh ${order.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12)),
            Text('Items: ${order.items.length}', style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showStatusDialog(context),
                  icon: const Icon(Icons.edit, size: 14),
                  label: const Text('Update Status'),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
                ),
                if (order.status.toString().split('.').last != 'cancelled')
                  ElevatedButton.icon(
                    onPressed: () => _cancelOrder(context),
                    icon: const Icon(Icons.cancel, size: 14),
                    label: const Text('Cancel'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      backgroundColor: Colors.red,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(dynamic status) {
    final statusStr = status.toString().split('.').last;
    switch (statusStr) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'processing':
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showStatusDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Order Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            'Pending',
            'Confirmed',
            'Processing',
            'Shipped',
            'Delivered',
            'Cancelled',
          ]
              .map((status) => ListTile(
                    title: Text(status),
                    onTap: () {
                      final ordStatus = _parseOrderStatusString(status);
                      context.read<OrderProvider>().updateOrderStatus(order.id, ordStatus);
                      Navigator.pop(context);
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  dynamic _parseOrderStatusString(String status) {
    final statusStr = status.toLowerCase();
    switch (statusStr) {
      case 'pending':
        return 'pending';
      case 'confirmed':
        return 'confirmed';
      case 'processing':
        return 'processing';
      case 'shipped':
        return 'shipped';
      case 'delivered':
        return 'delivered';
      case 'cancelled':
        return 'cancelled';
      default:
        return 'pending';
    }
  }

  void _cancelOrder(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              context.read<OrderProvider>().cancelOrder(order.id);
              Navigator.pop(context);
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}

class CustomersManagementScreen extends StatefulWidget {
  const CustomersManagementScreen({super.key});

  @override
  State<CustomersManagementScreen> createState() => _CustomersManagementScreenState();
}

class _CustomersManagementScreenState extends State<CustomersManagementScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch users when this screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().fetchAllUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        // Show both 'customer' and 'user' role (for backwards compatibility)
        final customers = userProvider.allUsers.where((u) => u.role == 'customer' || u.role == 'user').toList();
        
        print('===== CUSTOMERS DEBUG =====');
        print('Total users: ${userProvider.allUsers.length}');
        print('Total customers: ${customers.length}');
        print('Is loading: ${userProvider.isLoading}');
        print('==========================');
        
        return RefreshIndicator(
          onRefresh: () async {
            await context.read<UserProvider>().fetchAllUsers();
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                customers.length.toString(),
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              const Text('Total Customers'),
                            ],
                          ),
                        ),
                        const Icon(Icons.people, size: 40, color: Colors.blue),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (userProvider.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (customers.isEmpty)
                  const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('No customers yet.')))
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: customers.length,
                    itemBuilder: (context, index) {
                      final customer = customers[index];
                      return CustomerCard(customer: customer);
                    },
                  ),
              ],
            ),
          ),
        ),
      );
      },
    );
  }
}

class CustomerCard extends StatelessWidget {
  final dynamic customer;

  const CustomerCard({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    // Safe email handling
    final email = customer.email ?? 'No email';
    final displayEmail = email.isEmpty || email == 'null' ? 'No email' : email;
    final initial = displayEmail.isNotEmpty ? displayEmail[0].toUpperCase() : '?';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: Colors.blue[100], shape: BoxShape.circle),
          child: Center(child: Text(initial)),
        ),
        title: Text(displayEmail),
        subtitle: Text(customer.isBlocked ? '🔒 Blocked' : '✓ Active'),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              onTap: () => _viewOrderHistory(context, customer.uid),
              child: const Text('View Orders'),
            ),
            if (customer.role != 'admin')
              PopupMenuItem(
                onTap: () => Future.microtask(() => _promoteToAdmin(context, customer)),
                child: const Text('Promote to Admin'),
              ),
            PopupMenuItem(
              onTap: () => _toggleBlockStatus(context, customer),
              child: Text(customer.isBlocked ? 'Unblock' : 'Block'),
            ),
          ],
        ),
      ),
    );
  }

  void _viewOrderHistory(BuildContext context, String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderHistoryScreen(userId: userId),
      ),
    );
  }

  void _toggleBlockStatus(BuildContext context, dynamic customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(customer.isBlocked ? 'Unblock Customer' : 'Block Customer'),
        content: Text(customer.isBlocked ? 'Unblock this customer?' : 'Block this customer from purchasing?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (customer.isBlocked) {
                context.read<UserProvider>().unblockUser(customer.uid);
              } else {
                context.read<UserProvider>().blockUser(customer.uid);
              }
              Navigator.pop(context);
            },
            child: Text(customer.isBlocked ? 'Unblock' : 'Block'),
          ),
        ],
      ),
    );
  }

  void _promoteToAdmin(BuildContext context, dynamic customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Promote to Admin'),
        content: Text('Give admin access to ${customer.email}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await context.read<UserProvider>().updateUserRole(customer.uid, 'admin');
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Promote'),
          ),
        ],
      ),
    );
  }
}

class OrderHistoryScreen extends StatelessWidget {
  final String userId;

  const OrderHistoryScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer Order History')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: context.read<UserProvider>().getUserOrderHistory(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No orders found.'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final order = snapshot.data![index];
              return ListTile(
                title: Text('Order #${order['id'].substring(0, 8)}'),
                subtitle: Text('Total: KSh ${order['totalAmount']}'),
                trailing: Text(order['status']),
              );
            },
          );
        },
      ),
    );
  }
}

class AppContentManagementScreen extends StatefulWidget {
  const AppContentManagementScreen({super.key});

  @override
  State<AppContentManagementScreen> createState() => _AppContentManagementScreenState();
}

class _AppContentManagementScreenState extends State<AppContentManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        return DefaultTabController(
          length: 3,
          child: Column(
            children: [
              const TabBar(
                tabs: [
                  Tab(text: 'Categories'),
                  Tab(text: 'Banners'),
                  Tab(text: 'Notifications'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildCategoriesTab(context, adminProvider),
                    _buildBannersTab(context, adminProvider),
                    _buildNotificationsTab(context, adminProvider),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoriesTab(BuildContext context, AdminProvider provider) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: () => _showAddCategoryDialog(context, provider),
              icon: const Icon(Icons.add),
              label: const Text('Add Category'),
            ),
            const SizedBox(height: 16),
            if (provider.categories.isEmpty)
              const Text('No categories yet.')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.categories.length,
                itemBuilder: (context, index) {
                  final category = provider.categories[index];
                  return ListTile(
                    title: Text(category.name),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => provider.deleteCategory(category.id),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannersTab(BuildContext context, AdminProvider provider) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: () => _showAddBannerDialog(context, provider),
              icon: const Icon(Icons.add),
              label: const Text('Add Banner'),
            ),
            const SizedBox(height: 16),
            if (provider.banners.isEmpty)
              const Text('No banners yet.')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.banners.length,
                itemBuilder: (context, index) {
                  final banner = provider.banners[index];
                  return ListTile(
                    title: Text(banner.title),
                    subtitle: Text(banner.isActive ? 'Active' : 'Inactive'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => provider.deleteBanner(banner.id),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsTab(BuildContext context, AdminProvider provider) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: () => _showSendNotificationDialog(context, provider),
              icon: const Icon(Icons.send),
              label: const Text('Send Notification'),
            ),
            const SizedBox(height: 16),
            if (provider.notifications.isEmpty)
              const Text('No notifications sent yet.')
              else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.notifications.length,
                itemBuilder: (context, index) {
                  final notif = provider.notifications[index];
                  return ListTile(
                    title: Text(notif.title),
                    subtitle: Text(notif.isSent ? '✓ Sent' : '⏱ Scheduled'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => provider.deleteNotification(notif.id),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, AdminProvider provider) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Category'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Category name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                provider.addCategory(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddBannerDialog(BuildContext context, AdminProvider provider) {
    final titleController = TextEditingController();
    final urlController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Banner'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: 'Banner title'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(hintText: 'Image URL'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (titleController.text.isNotEmpty && urlController.text.isNotEmpty) {
                provider.addBanner(titleController.text, urlController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showSendNotificationDialog(BuildContext context, AdminProvider provider) {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Notification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: 'Title'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(hintText: 'Message'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (titleController.text.isNotEmpty && messageController.text.isNotEmpty) {
                provider.sendNotification(titleController.text, messageController.text, NotificationType.announcement);
                Navigator.pop(context);
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}

class PaymentsManagementScreen extends StatelessWidget {
  const PaymentsManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: context.read<AdminProvider>().getRevenueStats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final stats = snapshot.data!;
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                StatCard(
                  title: 'Total Revenue',
                  value: 'KSh ${stats['totalRevenue'].toStringAsFixed(2)}',
                  icon: Icons.trending_up,
                  color: Colors.green,
                ),
                const SizedBox(height: 12),
                StatCard(
                  title: 'Total Orders',
                  value: stats['totalOrders'].toString(),
                  icon: Icons.shopping_bag,
                  color: Colors.blue,
                ),
                const SizedBox(height: 12),
                StatCard(
                  title: 'Avg Order Value',
                  value: 'KSh ${stats['averageOrderValue'].toStringAsFixed(2)}',
                  icon: Icons.analytics,
                  color: Colors.orange,
                ),
                const SizedBox(height: 24),
                const Text('Pending Payments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Consumer<OrderProvider>(
                  builder: (context, orderProvider, child) {
                    final pendingOrders = orderProvider.allOrders
                        .where((o) => o.paymentStatus == 'pending')
                        .toList();
                    if (pendingOrders.isEmpty) {
                      return const Text('All payments confirmed');
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: pendingOrders.length,
                      itemBuilder: (context, index) {
                        final order = pendingOrders[index];
                        return ListTile(
                          title: Text('Order #${order.id.substring(0, 8)}'),
                          subtitle: Text('KSh ${order.totalAmount}'),
                          trailing: ElevatedButton(
                            onPressed: () {
                              orderProvider.confirmPayment(order.id);
                            },
                            child: const Text('Confirm'),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final auth = context.read<AuthProvider>();
      final userProvider = context.read<UserProvider>();
      if (auth.user != null && userProvider.currentUser == null) {
        userProvider.fetchUser(auth.user!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserProvider, AuthProvider>(
      builder: (context, userProvider, authProvider, _) {
        final user = userProvider.currentUser;
        final authUser = authProvider.user;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Profile Photo
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                          color: Colors.grey[200],
                        ),
                        child: user?.profilePhotoUrl != null
                            ? ClipOval(
                                child: Image.network(
                                  user!.profilePhotoUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.person, size: 30);
                                  },
                                ),
                              )
                            : const Icon(Icons.person, size: 30),
                      ),
                      const SizedBox(width: 16),
                      // Profile Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.fullName ?? authUser?.email ?? 'Admin User',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.email ?? authUser?.email ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Admin',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Settings Options
              const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                title: const Text('Edit Admin Profile'),
                subtitle: const Text('Update your profile information'),
                leading: const Icon(Icons.person),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfileEditScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text('App Settings'),
                subtitle: const Text('Manage app preferences'),
                leading: const Icon(Icons.settings),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AppSettingsScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text('Security'),
                subtitle: const Text('Password and security settings'),
                leading: const Icon(Icons.security),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SecurityScreen(),
                    ),
                  );
                },
              ),
              const Divider(height: 32),
              ListTile(
                title: const Text('Logout'),
                subtitle: const Text('Sign out from admin account'),
                leading: const Icon(Icons.logout, color: Colors.red),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            context.read<AuthProvider>().logout();
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Logout',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
