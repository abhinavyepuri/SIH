import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';
import '../../core/state/app_state.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../orders/orders_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isPlacingOrder = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = AppState.of(context).auth.currentUser;
      if (user != null) {
        _nameController.text = user.name;
        _emailController.text = user.email;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String _selectedPaymentMethod = 'stripe'; // 'stripe', 'phonepe', 'paytm', 'cod'

  Future<void> _handleSingleItemCheckout(dynamic item) async {
    final appState = AppState.of(context);
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your full name for delivery in the shipping section')),
      );
      return;
    }

    setState(() => _isPlacingOrder = true);

    try {
      final res = await ApiClient.post('/orders/', {
        'customer_name': _nameController.text.trim(),
        'customer_email': _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
        'product_id': item.product.id,
        'product_title': item.product.title,
        'artisan_id': item.product.artisanId,
        'quantity': item.quantity,
        'price': item.product.price,
        'status': _selectedPaymentMethod == 'cod' ? 'confirmed' : 'pending',
      });

      String? lastOrderId;
      if (res is Map && res.containsKey('id')) {
        lastOrderId = res['id'];
      }

      if (_selectedPaymentMethod == 'stripe') {
        await ApiClient.post('/payment/create-checkout-session', {
          'items': [
            {
              'name': item.product.title,
              'price': item.product.price,
              'quantity': item.quantity,
            }
          ],
          'order_id': lastOrderId,
          'customer_email': _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : 'buyer@aesthete.in',
          'success_url': 'http://localhost:3000/payment-success',
          'cancel_url': 'http://localhost:3000/payment-cancelled',
        });
      }

      // Remove only this single item from the cart
      appState.cart.removeFromCart(item.product.id);

      if (!mounted) return;
      setState(() => _isPlacingOrder = false);

      _showOrderConfirmationDialog(item.product.title);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isPlacingOrder = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order failed: ${e.toString()}'), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _handleCheckout() async {
    final appState = AppState.of(context);
    final items = appState.cart.items;
    if (items.isEmpty) return;

    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your full name for delivery')),
      );
      return;
    }

    setState(() => _isPlacingOrder = true);

    try {
      // Create orders for each product in cart via FastAPI with unit price
      String? lastOrderId;
      for (final item in items) {
        final res = await ApiClient.post('/orders/', {
          'customer_name': _nameController.text.trim(),
          'customer_email': _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
          'product_id': item.product.id,
          'product_title': item.product.title,
          'artisan_id': item.product.artisanId,
          'quantity': item.quantity,
          'price': item.product.price,
          'status': _selectedPaymentMethod == 'cod' ? 'confirmed' : 'pending',
        });
        if (res is Map && res.containsKey('id')) {
          lastOrderId = res['id'];
        }
      }

      if (_selectedPaymentMethod == 'stripe') {
        final stripeItems = items.map((i) => {
          'name': i.product.title,
          'price': i.product.price,
          'quantity': i.quantity,
        }).toList();

        await ApiClient.post('/payment/create-checkout-session', {
          'items': stripeItems,
          'order_id': lastOrderId,
          'customer_email': _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : 'buyer@aesthete.in',
          'success_url': 'http://localhost:3000/payment-success',
          'cancel_url': 'http://localhost:3000/payment-cancelled',
        });
      }

      appState.cart.clearCart();

      if (!mounted) return;
      setState(() => _isPlacingOrder = false);

      _showOrderConfirmationDialog('All ${items.length} items');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isPlacingOrder = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order failed: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showOrderConfirmationDialog(String itemSummary) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: AppColors.successLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_outline, color: AppColors.success, size: 36),
            ),
            const SizedBox(height: 16),
            const Text(
              'Order Placed Successfully!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your order for $itemSummary has been dispatched to the master atelier for authentic crafting.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppColors.warmGray, height: 1.4),
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'View My Orders →',
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const OrdersScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState.of(context);
    final cart = appState.cart;

    return Scaffold(
      backgroundColor: AppColors.beige,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Shopping Cart',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Direct from certified master ateliers',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.warmGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: cart.items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: AppColors.roseLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shopping_bag_outlined,
                        size: 42,
                        color: AppColors.terracotta,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Your Cart is Clean & Empty',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Explore verified Geographical Indication crafts from master artisans across India.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.warmGray,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.terracotta,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.explore_outlined, size: 18),
                        label: const Text(
                          'Browse Marketplace',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Items List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cart.items.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (ctx, index) {
                      final item = cart.items[index];
                      final p = item.product;
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Thumbnail
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: AppColors.cream,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: p.primaryImage != null && p.primaryImage!.isNotEmpty
                                    ? Image.network(p.primaryImage!, fit: BoxFit.cover)
                                    : const Icon(Icons.brush_outlined, color: AppColors.warmGrayLight),
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontFamily: 'serif', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.navy),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    p.category,
                                    style: const TextStyle(fontSize: 11, color: AppColors.warmGrayLight),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '₹${item.totalPrice.toInt()}',
                                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.navy),
                                      ),
                                      // Quantity Stepper
                                      Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.cream,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: AppColors.border),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            InkWell(
                                              onTap: () => cart.updateQuantity(p.id, item.quantity - 1),
                                              child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.remove, size: 14)),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 6),
                                              child: Text('${item.quantity}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                            ),
                                            InkWell(
                                              onTap: () => cart.updateQuantity(p.id, item.quantity + 1),
                                              child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.add, size: 14)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 34,
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.roseLight,
                                        foregroundColor: AppColors.terracotta,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          side: const BorderSide(color: AppColors.terracottaLight),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                      ),
                                      icon: const Icon(Icons.bolt, size: 15),
                                      label: Text(
                                        'Order This Piece (₹${item.totalPrice.toInt()})',
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                                      ),
                                      onPressed: _isPlacingOrder ? null : () => _handleSingleItemCheckout(item),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Delete Button
                            IconButton(
                              icon: const Icon(Icons.close, size: 18, color: AppColors.warmGrayLight),
                              tooltip: 'Remove from Bag',
                              onPressed: () => cart.removeFromCart(p.id),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Delivery Address / Contact
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SHIPPING & CONTACT DETAILS',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: AppColors.warmGray),
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: 'Full Name',
                          hint: 'e.g., Jane Doe',
                          controller: _nameController,
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: 'Email (For Order Updates)',
                          hint: 'jane@example.com',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Payment Method Selector
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CHOOSE PAYMENT METHOD',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: AppColors.warmGray),
                        ),
                        const SizedBox(height: 12),
                        _buildPaymentOption(
                          id: 'stripe',
                          icon: Icons.credit_card_outlined,
                          title: 'Card / International',
                          subtitle: 'Visa, Mastercard, Amex via Stripe',
                          badge: 'RECOMMENDED',
                        ),
                        const SizedBox(height: 8),
                        _buildPaymentOption(
                          id: 'phonepe',
                          icon: Icons.phone_android,
                          title: 'PhonePe',
                          subtitle: 'UPI, Wallet & Bank Transfer',
                          badge: 'INDIA',
                        ),
                        const SizedBox(height: 8),
                        _buildPaymentOption(
                          id: 'paytm',
                          icon: Icons.account_balance_wallet_outlined,
                          title: 'Paytm',
                          subtitle: 'Paytm Wallet, UPI & NetBanking',
                          badge: 'INDIA',
                        ),
                        const SizedBox(height: 8),
                        _buildPaymentOption(
                          id: 'cod',
                          icon: Icons.local_shipping_outlined,
                          title: 'Cash on Delivery',
                          subtitle: 'Pay when your handcrafted piece arrives',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Order Summary Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        _summaryRow('Subtotal', '₹${cart.subtotal.toInt()}'),
                        const SizedBox(height: 8),
                        _summaryRow(
                          'Insured Craft Delivery',
                          cart.shippingFee == 0 ? 'FREE' : '₹${cart.shippingFee.toInt()}',
                          isFree: cart.shippingFee == 0,
                        ),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: AppColors.border)),
                        _summaryRow(
                          'Total (INR)',
                          '₹${cart.total.toInt()}',
                          isTotal: true,
                        ),
                        const SizedBox(height: 20),
                        CustomButton(
                          text: 'Place Order (${cart.itemCount} Items) →',
                          isLoading: _isPlacingOrder,
                          onPressed: _handleCheckout,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isFree = false, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 15 : 13,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
            color: isTotal ? AppColors.navy : AppColors.warmGray,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 13,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
            color: isFree ? AppColors.success : AppColors.navy,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOption({
    required String id,
    required IconData icon,
    required String title,
    required String subtitle,
    String? badge,
  }) {
    final isSelected = _selectedPaymentMethod == id;

    return InkWell(
      onTap: () => setState(() => _selectedPaymentMethod = id),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.navy.withValues(alpha: 0.04) : AppColors.cream,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.navy : AppColors.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.navy : AppColors.warmGray, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.navy),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badge,
                            style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: AppColors.goldDark, letterSpacing: 0.5),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: AppColors.warmGray),
                  ),
                ],
              ),
            ),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.navy : AppColors.border,
                  width: isSelected ? 5 : 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
