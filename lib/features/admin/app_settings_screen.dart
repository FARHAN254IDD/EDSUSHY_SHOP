import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/theme_provider.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _appNameController;
  late TextEditingController _taxRateController;
  late TextEditingController _shippingFeeController;
  late TextEditingController _currencyController;
  
  bool _autoConfirmOrders = false;
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _orderNotifications = true;
  bool _lowStockAlerts = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _appNameController = TextEditingController();
    _taxRateController = TextEditingController();
    _shippingFeeController = TextEditingController();
    _currencyController = TextEditingController(text: 'KSh');
    _loadSettings();
  }

  @override
  void dispose() {
    _appNameController.dispose();
    _taxRateController.dispose();
    _shippingFeeController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _appNameController.text = prefs.getString('app_name') ?? 'Edsushy Shop';
      _taxRateController.text = prefs.getDouble('tax_rate')?.toString() ?? '16.0';
      _shippingFeeController.text = prefs.getDouble('shipping_fee')?.toString() ?? '200.0';
      _currencyController.text = prefs.getString('currency') ?? 'KSh';
      _autoConfirmOrders = prefs.getBool('auto_confirm_orders') ?? false;
      _emailNotifications = prefs.getBool('email_notifications') ?? true;
      _pushNotifications = prefs.getBool('push_notifications') ?? true;
      _orderNotifications = prefs.getBool('order_notifications') ?? true;
      _lowStockAlerts = prefs.getBool('low_stock_alerts') ?? true;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString('app_name', _appNameController.text);
    await prefs.setDouble('tax_rate', double.tryParse(_taxRateController.text) ?? 16.0);
    await prefs.setDouble('shipping_fee', double.tryParse(_shippingFeeController.text) ?? 200.0);
    await prefs.setString('currency', _currencyController.text);
    await prefs.setBool('auto_confirm_orders', _autoConfirmOrders);
    await prefs.setBool('email_notifications', _emailNotifications);
    await prefs.setBool('push_notifications', _pushNotifications);
    await prefs.setBool('order_notifications', _orderNotifications);
    await prefs.setBool('low_stock_alerts', _lowStockAlerts);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _resetToDefaults() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset to Defaults'),
        content: const Text('Are you sure you want to reset all settings to default values?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _appNameController.text = 'Edsushy Shop';
        _taxRateController.text = '16.0';
        _shippingFeeController.text = '200.0';
        _currencyController.text = 'KSh';
        _autoConfirmOrders = false;
        _emailNotifications = true;
        _pushNotifications = true;
        _orderNotifications = true;
        _lowStockAlerts = true;
      });
      await _saveSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('App Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset to Defaults',
            onPressed: _resetToDefaults,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // General Settings Section
              _buildSectionHeader('General Settings', Icons.settings),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _appNameController,
                        decoration: const InputDecoration(
                          labelText: 'App Name',
                          hintText: 'Enter app name',
                          prefixIcon: Icon(Icons.apps),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter app name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _currencyController,
                        decoration: const InputDecoration(
                          labelText: 'Currency Symbol',
                          hintText: r'e.g., KSh, $, €',
                          prefixIcon: Icon(Icons.money),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Appearance Settings Section
              _buildSectionHeader('Appearance', Icons.palette),
              const SizedBox(height: 12),
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: const Text('Dark Mode'),
                            subtitle: Text(
                              themeProvider.isDarkMode
                                  ? 'Dark theme enabled'
                                  : 'Light theme enabled',
                            ),
                            value: themeProvider.isDarkMode,
                            onChanged: (value) {
                              themeProvider.setDarkMode(value);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    value
                                        ? 'Dark mode enabled'
                                        : 'Light mode enabled',
                                  ),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            secondary: Icon(
                              themeProvider.isDarkMode
                                  ? Icons.dark_mode
                                  : Icons.light_mode,
                              color: themeProvider.isDarkMode
                                  ? Colors.amber
                                  : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Financial Settings Section
              _buildSectionHeader('Financial Settings', Icons.attach_money),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _taxRateController,
                        decoration: const InputDecoration(
                          labelText: 'Tax Rate (%)',
                          hintText: 'Enter tax percentage',
                          prefixIcon: Icon(Icons.percent),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter tax rate';
                          }
                          final num = double.tryParse(value);
                          if (num == null || num < 0 || num > 100) {
                            return 'Enter a valid percentage (0-100)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _shippingFeeController,
                        decoration: InputDecoration(
                          labelText: 'Default Shipping Fee',
                          hintText: 'Enter shipping fee',
                          prefixIcon: const Icon(Icons.local_shipping),
                          border: const OutlineInputBorder(),
                          suffix: Text(_currencyController.text),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter shipping fee';
                          }
                          final num = double.tryParse(value);
                          if (num == null || num < 0) {
                            return 'Enter a valid amount';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Order Settings Section
              _buildSectionHeader('Order Settings', Icons.shopping_cart),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Auto-Confirm Orders'),
                        subtitle: const Text('Automatically confirm orders on payment'),
                        value: _autoConfirmOrders,
                        onChanged: (value) {
                          setState(() => _autoConfirmOrders = value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Notification Settings Section
              _buildSectionHeader('Notifications', Icons.notifications),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Email Notifications'),
                        subtitle: const Text('Receive email updates'),
                        value: _emailNotifications,
                        onChanged: (value) {
                          setState(() => _emailNotifications = value);
                        },
                      ),
                      const Divider(),
                      SwitchListTile(
                        title: const Text('Push Notifications'),
                        subtitle: const Text('Receive push notifications'),
                        value: _pushNotifications,
                        onChanged: (value) {
                          setState(() => _pushNotifications = value);
                        },
                      ),
                      const Divider(),
                      SwitchListTile(
                        title: const Text('Order Notifications'),
                        subtitle: const Text('Get notified of new orders'),
                        value: _orderNotifications,
                        onChanged: (value) {
                          setState(() => _orderNotifications = value);
                        },
                      ),
                      const Divider(),
                      SwitchListTile(
                        title: const Text('Low Stock Alerts'),
                        subtitle: const Text('Alert when products are low in stock'),
                        value: _lowStockAlerts,
                        onChanged: (value) {
                          setState(() => _lowStockAlerts = value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _saveSettings,
                  icon: const Icon(Icons.save),
                  label: const Text(
                    'Save Settings',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
