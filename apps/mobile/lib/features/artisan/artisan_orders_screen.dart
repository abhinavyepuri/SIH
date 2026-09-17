import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';
import '../../models/order.dart';

class ArtisanOrdersScreen extends StatefulWidget {
  const ArtisanOrdersScreen({super.key});

  @override
  State<ArtisanOrdersScreen> createState() => _ArtisanOrdersScreenState();
}

class _ArtisanOrdersScreenState extends State<ArtisanOrdersScreen> {
  bool _isLoading = true;
  List<Order> _orders = [];
  String _selectedFilter = 'All'; // 'All', 'In Production', 'Shipped', 'Delivered'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrders();
    });
  }

  Future<void> _loadOrders() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final res = await ApiClient.get('/orders/');
      List<Order> list = [];
      if (res is List) {
        list = res.map((j) => Order.fromJson(j)).toList();
      } else if (res is Map && res.containsKey('orders')) {
        list = (res['orders'] as List).map((j) => Order.fromJson(j)).toList();
      }
      if (mounted) {
        setState(() {
          _orders = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(String orderId, String newStatus) async {
    try {
      await ApiClient.put('/orders/$orderId/status', {'status': newStatus});
      _loadOrders();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order status updated to ${_formatStatus(newStatus)}'),
          backgroundColor: AppColors.terracotta,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: ${e.toString()}'), backgroundColor: AppColors.error),
      );
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
      case 'confirmed':
        return AppColors.successLight;
      case 'shipped':
        return AppColors.shippedBg;
      case 'in_production':
      case 'in production':
        return AppColors.inProdBg;
      case 'pending':
      case 'placed':
      default:
        return AppColors.placedBg;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
      case 'confirmed':
        return AppColors.success;
      case 'shipped':
        return AppColors.shippedText;
      case 'in_production':
      case 'in production':
        return AppColors.inProdText;
      case 'pending':
      case 'placed':
      default:
        return AppColors.placedText;
    }
  }

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'in_production':
      case 'in production':
        return 'IN PRODUCTION';
      case 'delivered':
      case 'confirmed':
        return 'DELIVERED';
      case 'shipped':
        return 'SHIPPED';
      default:
        return 'PLACED';
    }
  }

  int get _inProdCount => _orders.where((o) => o.status.toLowerCase() == 'in_production' || o.status.toLowerCase() == 'in production' || o.status.toLowerCase() == 'pending').length;
  int get _shippedCount => _orders.where((o) => o.status.toLowerCase() == 'shipped').length;
  int get _deliveredCount => _orders.where((o) => o.status.toLowerCase() == 'delivered' || o.status.toLowerCase() == 'confirmed').length;

  List<Order> get _filteredOrders {
    if (_selectedFilter == 'In Production') {
      return _orders.where((o) => o.status.toLowerCase() == 'in_production' || o.status.toLowerCase() == 'in production' || o.status.toLowerCase() == 'pending').toList();
    } else if (_selectedFilter == 'Shipped') {
      return _orders.where((o) => o.status.toLowerCase() == 'shipped').toList();
    } else if (_selectedFilter == 'Delivered') {
      return _orders.where((o) => o.status.toLowerCase() == 'delivered' || o.status.toLowerCase() == 'confirmed').toList();
    }
    return _orders;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredOrders;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Order Management',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Track fulfillment & shipments',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.warmGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.terracotta),
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  {'name': 'All', 'count': _orders.length},
                  {'name': 'In Production', 'count': _inProdCount},
                  {'name': 'Shipped', 'count': _shippedCount},
                  {'name': 'Delivered', 'count': _deliveredCount},
                ].map((f) {
                  final name = f['name'] as String;
                  final count = f['count'] as int;
                  final isSelected = _selectedFilter == name;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => setState(() => _selectedFilter = name),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.terracotta : AppColors.background,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? AppColors.terracotta : AppColors.border,
                          ),
                        ),
                        child: Text(
                          '$name ($count)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? Colors.white : AppColors.warmGray,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Orders List
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadOrders,
              color: AppColors.terracotta,
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(AppColors.terracotta),
                      ),
                    )
                  : filtered.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.55,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 76,
                                        height: 76,
                                        decoration: BoxDecoration(
                                          color: AppColors.roseLight,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.inventory_outlined, size: 36, color: AppColors.terracotta),
                                      ),
                                      const SizedBox(height: 18),
                                      const Text(
                                        'No Orders in this Status',
                                        style: TextStyle(
                                          fontFamily: 'serif',
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      const Text(
                                        'When customers purchase your handcrafted items, orders will appear here.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 12, color: AppColors.warmGray),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 14),
                          itemBuilder: (ctx, index) {
                            final o = filtered[index];
                            final statusBg = _getStatusBgColor(o.status);
                            final statusText = _getStatusTextColor(o.status);
                            final formattedStatus = _formatStatus(o.status);

                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: AppColors.border),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header Row: Customer & Status Pill
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color: AppColors.roseLight,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.person_outline, size: 16, color: AppColors.terracotta),
                                          ),
                                          const SizedBox(width: 8),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                o.customerName.isNotEmpty ? o.customerName : 'Connoisseur Buyer',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                              Text(
                                                '#${o.id.isNotEmpty ? o.id : "ORD-${1000 + index}"}',
                                                style: const TextStyle(fontSize: 10, color: AppColors.warmGray),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: statusBg,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          formattedStatus,
                                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: statusText),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 12),
                                  const Divider(height: 1, color: AppColors.borderLight),
                                  const SizedBox(height: 12),

                                  // Product Title & Pricing
                                  Text(
                                    o.productTitle,
                                    style: const TextStyle(
                                      fontFamily: 'serif',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Quantity: ${o.quantity} unit${o.quantity > 1 ? "s" : ""}',
                                        style: const TextStyle(fontSize: 12, color: AppColors.warmGray),
                                      ),
                                      Text(
                                        '₹${(o.price * o.quantity).toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.terracotta,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 14),

                                  // Fulfillment Actions
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Update Workflow:',
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.warmGray),
                                        ),
                                        Row(
                                          children: [
                                            if (o.status == 'pending' || o.status == 'placed')
                                              InkWell(
                                                onTap: () => _updateStatus(o.id, 'in_production'),
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.inProdBg,
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: const Text(
                                                    'Start Crafting',
                                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.inProdText),
                                                  ),
                                                ),
                                              ),
                                            if (o.status == 'in_production' || o.status == 'in production' || o.status == 'pending') ...[
                                              const SizedBox(width: 6),
                                              InkWell(
                                                onTap: () => _updateStatus(o.id, 'shipped'),
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.shippedBg,
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: const Text(
                                                    'Mark Shipped',
                                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.shippedText),
                                                  ),
                                                ),
                                              ),
                                            ],
                                            if (o.status == 'shipped')
                                              InkWell(
                                                onTap: () => _updateStatus(o.id, 'delivered'),
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.successLight,
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: const Text(
                                                    'Mark Delivered',
                                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success),
                                                  ),
                                                ),
                                              ),
                                            if (o.status == 'delivered' || o.status == 'confirmed')
                                              const Row(
                                                children: [
                                                  Icon(Icons.check_circle, size: 14, color: AppColors.success),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    'Completed',
                                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}

