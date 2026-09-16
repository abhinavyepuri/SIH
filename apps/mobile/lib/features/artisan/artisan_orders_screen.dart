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

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiClient.get('/orders/');
      List<Order> list = [];
      if (res is List) {
        list = res.map((j) => Order.fromJson(j)).toList();
      } else if (res is Map && res.containsKey('orders')) {
        list = (res['orders'] as List).map((j) => Order.fromJson(j)).toList();
      }
      setState(() {
        _orders = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(String orderId, String newStatus) async {
    try {
      await ApiClient.put('/orders/$orderId/status', {'status': newStatus});
      _loadOrders();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order marked as $newStatus')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: ${e.toString()}'), backgroundColor: AppColors.error),
      );
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
      case 'confirmed':
        return AppColors.success;
      case 'shipped':
        return AppColors.navy;
      case 'pending':
        return AppColors.warning;
      default:
        return AppColors.warmGray;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beige,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'ATELIER ORDERS',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: AppColors.navy,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadOrders,
        color: AppColors.gold,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.gold)))
            : _orders.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_outlined, size: 48, color: AppColors.warmGrayLight),
                          SizedBox(height: 16),
                          Text('No Orders Yet', style: TextStyle(fontFamily: 'serif', fontSize: 18, color: AppColors.navy)),
                          SizedBox(height: 6),
                          Text('When connoisseurs purchase your creations, their orders will appear here.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppColors.warmGray)),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, index) {
                      final o = _orders[index];
                      final color = _statusColor(o.status);

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'CUSTOMER: ${o.customerName.toUpperCase()}',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.warmGray),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    o.status.toUpperCase(),
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              o.productTitle,
                              style: const TextStyle(fontFamily: 'serif', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.navy),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Qty: ${o.quantity}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.warmGray),
                                ),
                                Text(
                                  '₹${o.price.toInt()}',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.navy),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Divider(color: AppColors.border),
                            const SizedBox(height: 8),

                            // Fulfillment status stepper actions
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Update Status:',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.warmGray),
                                ),
                                Row(
                                  children: [
                                    if (o.status == 'pending') ...[
                                      TextButton(
                                        onPressed: () => _updateStatus(o.id, 'confirmed'),
                                        child: const Text('Confirm', style: TextStyle(fontSize: 11, color: AppColors.success)),
                                      ),
                                    ],
                                    if (o.status == 'confirmed') ...[
                                      TextButton(
                                        onPressed: () => _updateStatus(o.id, 'shipped'),
                                        child: const Text('Mark Shipped', style: TextStyle(fontSize: 11, color: AppColors.navy)),
                                      ),
                                    ],
                                    if (o.status == 'shipped') ...[
                                      TextButton(
                                        onPressed: () => _updateStatus(o.id, 'delivered'),
                                        child: const Text('Mark Delivered', style: TextStyle(fontSize: 11, color: AppColors.goldDark)),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
