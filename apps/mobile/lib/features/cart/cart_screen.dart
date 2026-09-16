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
      // Create orders for each product in cart via FastAPI
      for (final item in items) {
        await ApiClient.post('/orders/', {
          'customer_name': _nameController.text.trim(),
          'customer_email': _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
          'product_id': item.product.id,
          'product_title': item.product.title,
          'artisan_id': item.product.artisanId,
          'quantity': item.quantity,
          'price': item.totalPrice,
          'status': 'confirmed',
        });
      }

      appState.cart.clearCart();

      if (!mounted) return;
      setState(() => _isPlacingOrder = false);

      // Show luxury confirmation dialog
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
              const Text(
                'Thank you for supporting indigenous master artisans. Your order has been dispatched to the atelier.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.warmGray, height: 1.4),
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
    } catch (e) {
      setState(() => _isPlacingOrder = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order failed: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
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
        title: const Text(
          'SHOPPING BAG',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: AppColors.navy,
          ),
        ),
      ),
      body: cart.items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: AppColors.cream,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shopping_bag_outlined, size: 40, color: AppColors.warmGrayLight),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Your Bag is Empty',
                      style: TextStyle(fontFamily: 'serif', fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.navy),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Explore our curated gallery to discover rare handcrafted treasures from master artisans.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: AppColors.warmGray),
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Explore Collections →',
                      width: 200,
                      onPressed: () => Navigator.pop(context),
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
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
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
                                ],
                              ),
                            ),

                            // Delete Button
                            IconButton(
                              icon: const Icon(Icons.close, size: 16, color: AppColors.warmGrayLight),
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
}
