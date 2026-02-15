import 'package:flutter/material.dart';
import '../../services/report_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final ReportService _reportService = ReportService();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Sales Report'),
              Tab(text: 'Product Report'),
              Tab(text: 'Customer Report'),
            ],
            onTap: null,
          ),
          Expanded(
            child: TabBarView(
              children: [
                _SalesReportTab(reportService: _reportService),
                _ProductReportTab(reportService: _reportService),
                _CustomerReportTab(reportService: _reportService),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Sales Report Tab
class _SalesReportTab extends StatefulWidget {
  final ReportService reportService;

  const _SalesReportTab({required this.reportService});

  @override
  State<_SalesReportTab> createState() => _SalesReportTabState();
}

class _SalesReportTabState extends State<_SalesReportTab> {
  DateTime? _startDate;
  DateTime? _endDate;
  Map<String, dynamic>? _reportData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() => _isLoading = true);
    try {
      final data = await widget.reportService.generateSalesReport(
        startDate: _startDate,
        endDate: _endDate,
      );
      setState(() => _reportData = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading report: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _exportToCsv() async {
    if (_reportData == null) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generating CSV file...')),
    );

    final path = await widget.reportService.exportSalesReportToCsv(_reportData!);
    if (mounted) {
      if (path != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report saved: $path')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to export report')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date filters
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter by Date',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _startDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setState(() => _startDate = date);
                              _loadReport();
                            }
                          },
                          icon: const Icon(Icons.calendar_today, size: 16),
                          label: Text(_startDate == null
                              ? 'Start Date'
                              : '${_startDate!.month}/${_startDate!.day}/${_startDate!.year}'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _endDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setState(() => _endDate = date);
                              _loadReport();
                            }
                          },
                          icon: const Icon(Icons.calendar_today, size: 16),
                          label: Text(_endDate == null
                              ? 'End Date'
                              : '${_endDate!.month}/${_endDate!.day}/${_endDate!.year}'),
                        ),
                      ),
                    ],
                  ),
                  if (_startDate != null || _endDate != null) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _startDate = null;
                          _endDate = null;
                        });
                        _loadReport();
                      },
                      child: const Text('Clear filters'),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Summary cards
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_reportData != null) ...[
            _buildSummaryCards(_reportData!['summary']),
            const SizedBox(height: 16),
            
            // Export button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _exportToCsv,
                icon: const Icon(Icons.download),
                label: const Text('Download CSV Report'),
              ),
            ),
            const SizedBox(height: 16),

            // Orders list
            const Text(
              'Orders',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildOrdersList(_reportData!['orders']),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryCards(Map<String, dynamic> summary) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Total Orders',
                value: summary['totalOrders'].toString(),
                icon: Icons.shopping_bag,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Total Revenue',
                value: 'KSh ${summary['totalRevenue'].toStringAsFixed(2)}',
                icon: Icons.attach_money,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Avg Order Value',
                value: 'KSh ${summary['averageOrderValue'].toStringAsFixed(2)}',
                icon: Icons.trending_up,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Completed',
                value: summary['completedOrders'].toString(),
                icon: Icons.check_circle,
                color: Colors.teal,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrdersList(List<dynamic> orders) {
    if (orders.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('No orders found')),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(order['status']),
              child: const Icon(Icons.receipt, color: Colors.white, size: 20),
            ),
            title: Text('Order #${order['orderId'].substring(0, 8)}'),
            subtitle: Text('${order['items']} items • ${order['status']}'),
            trailing: Text(
              'KSh ${order['amount'].toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}

// Product Report Tab
class _ProductReportTab extends StatefulWidget {
  final ReportService reportService;

  const _ProductReportTab({required this.reportService});

  @override
  State<_ProductReportTab> createState() => _ProductReportTabState();
}

class _ProductReportTabState extends State<_ProductReportTab> {
  Map<String, dynamic>? _reportData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() => _isLoading = true);
    try {
      final data = await widget.reportService.generateProductReport();
      setState(() => _reportData = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading report: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _exportToCsv() async {
    if (_reportData == null) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generating CSV file...')),
    );

    final path = await widget.reportService.exportProductReportToCsv(_reportData!);
    if (mounted) {
      if (path != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report saved: $path')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to export report')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_reportData != null) ...[
            // Summary
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Total Products',
                    value: _reportData!['totalProducts'].toString(),
                    icon: Icons.inventory_2,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'In Stock',
                    value: _reportData!['productsInStock'].toString(),
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Export button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _exportToCsv,
                icon: const Icon(Icons.download),
                label: const Text('Download CSV Report'),
              ),
            ),
            const SizedBox(height: 16),

            // Products list
            const Text(
              'Product Performance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildProductsList(_reportData!['products']),
          ],
        ],
      ),
    );
  }

  Widget _buildProductsList(List<dynamic> products) {
    if (products.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('No products found')),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.purple.shade100,
              child: Text(
                '${index + 1}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(product['name']),
            subtitle: Text('Sold: ${product['quantitySold']} • Stock: ${product['stock']}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'KSh ${product['revenue'].toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'KSh ${product['price'].toStringAsFixed(2)}/unit',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Customer Report Tab
class _CustomerReportTab extends StatefulWidget {
  final ReportService reportService;

  const _CustomerReportTab({required this.reportService});

  @override
  State<_CustomerReportTab> createState() => _CustomerReportTabState();
}

class _CustomerReportTabState extends State<_CustomerReportTab> {
  Map<String, dynamic>? _reportData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() => _isLoading = true);
    try {
      final data = await widget.reportService.generateCustomerReport();
      setState(() => _reportData = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading report: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _exportToCsv() async {
    if (_reportData == null) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generating CSV file...')),
    );

    final path = await widget.reportService.exportCustomerReportToCsv(_reportData!);
    if (mounted) {
      if (path != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report saved: $path')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to export report')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_reportData != null) ...[
            // Summary
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Total Customers',
                    value: _reportData!['totalCustomers'].toString(),
                    icon: Icons.people,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Active Customers',
                    value: _reportData!['activeCustomers'].toString(),
                    icon: Icons.shopping_cart,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Export button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _exportToCsv,
                icon: const Icon(Icons.download),
                label: const Text('Download CSV Report'),
              ),
            ),
            const SizedBox(height: 16),

            // Customers list
            const Text(
              'Top Customers',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildCustomersList(_reportData!['customers']),
          ],
        ],
      ),
    );
  }

  Widget _buildCustomersList(List<dynamic> customers) {
    if (customers.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('No customers found')),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final customer = customers[index];
        final email = customer['email'] ?? 'No email';
        final initial = email.isNotEmpty ? email[0].toUpperCase() : '?';
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Text(initial, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            title: Text(email),
            subtitle: Text('Orders: ${customer['totalOrders']}'),
            trailing: Text(
              'KSh ${customer['totalSpent'].toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        );
      },
    );
  }
}

// Reusable Stat Card Widget
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
