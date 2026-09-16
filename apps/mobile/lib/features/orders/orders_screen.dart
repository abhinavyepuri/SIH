import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';
import '../../models/order.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
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
      final response = await ApiClient.get('/orders/');
      List<Order> list = [];
      if (response is List) {
        list = response.map((j) => Order.fromJson(j)).toList();
      } else if (response is Map && response.containsKey('orders')) {
        list = (response['orders'] as List).map((j) => Order.fromJson(j)).toList();
      }
      setState(() {
        _orders = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'delivered':
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
          'ORDER HISTORY',
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
                          Icon(Icons.receipt_long_outlined, size: 48, color: AppColors.warmGrayLight),
                          SizedBox(height: 16),
                          Text('No Orders Found', style: TextStyle(fontFamily: 'serif', fontSize: 18, color: AppColors.navy)),
                          SizedBox(height: 6),
                          Text('Your placed orders and tracking updates will appear here.', style: TextStyle(fontSize: 12, color: AppColors.warmGray)),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, index) {
                      final order = _orders[index];
                      final color = _statusColor(order.status);
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
                                  'ORDER #${order.id.isNotEmpty ? order.id : "ORD-$index"}',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.warmGrayLight),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    order.status.toUpperCase(),
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              order.productTitle,
                              style: const TextStyle(fontFamily: 'serif', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.navy),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Quantity: ${order.quantity}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.warmGray),
                                ),
                                Text(
                                  '₹${order.price.toInt()}',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.navy),
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
