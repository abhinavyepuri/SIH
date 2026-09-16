import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';
import '../../core/state/app_state.dart';
import '../../models/product.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/auth_guard_dialog.dart';
import '../cart/cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isLoading = true;
  Product? _product;
  int _selectedQuantity = 1;
  int _selectedImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiClient.get('/products/${widget.productId}');
      if (response is Map<String, dynamic>) {
        setState(() {
          _product = Product.fromJson(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState.of(context);

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.beige,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColors.gold),
          ),
        ),
      );
    }

    if (_product == null) {
      return Scaffold(
        backgroundColor: AppColors.beige,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Creation not found', style: TextStyle(fontFamily: 'serif', fontSize: 18, color: AppColors.navy)),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Back to Gallery')),
            ],
          ),
        ),
      );
    }

    final p = _product!;
    final images = p.imageList;
    final isFav = appState.wishlist.isFavorite(p.id);

    return Scaffold(
      backgroundColor: AppColors.beige,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.navy),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          p.category.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: AppColors.warmGray,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? AppColors.error : AppColors.navy,
            ),
            onPressed: () {
              if (!appState.auth.isAuthenticated) {
                showAuthRequiredDialog(context, action: 'save creations to your wishlist');
                return;
              }
              appState.wishlist.toggleFavorite(p);
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: AppColors.navy),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Carousel / Hero Image
            Container(
              color: AppColors.cream,
              child: AspectRatio(
                aspectRatio: 1.15,
                child: images.isNotEmpty
                    ? Image.network(
                        images[_selectedImageIndex < images.length ? _selectedImageIndex : 0],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildFallbackImage(),
                      )
                    : _buildFallbackImage(),
              ),
            ),

            // Thumbnail Selector (if multiple images)
            if (images.length > 1) ...[
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: images.asMap().entries.map((entry) {
                    final index = entry.key;
                    final url = entry.value;
                    final isSelected = _selectedImageIndex == index;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedImageIndex = index),
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? AppColors.gold : AppColors.border,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: Image.network(url, fit: BoxFit.cover),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],

            // Content Body
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Provenance & Category
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.cream,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          p.category.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.navy,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: AppColors.gold),
                          const SizedBox(width: 4),
                          const Text(
                            '4.8',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.navy),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '(24 verified collectors)',
                            style: TextStyle(fontSize: 11, color: AppColors.warmGrayLight),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Title
                  Text(
                    p.title,
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy,
                      height: 1.25,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Price & Stock
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${p.price.toInt()}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: AppColors.navy,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Text(
                          'INR (Incl. of all taxes)',
                          style: TextStyle(fontSize: 11, color: AppColors.warmGrayLight),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 16),

                  // Description
                  if (p.description != null && p.description!.isNotEmpty) ...[
                    const Text(
                      'THE STORY & INSPIRATION',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: AppColors.warmGray,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      p.description!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Materials
                  if (p.materials != null && p.materials!.isNotEmpty) ...[
                    _buildInfoTile(
                      icon: Icons.layers_outlined,
                      title: 'AUTHENTIC MATERIALS',
                      value: p.materials!,
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Crafting Process
                  if (p.craftingProcess != null && p.craftingProcess!.isNotEmpty) ...[
                    _buildInfoTile(
                      icon: Icons.handyman_outlined,
                      title: 'HERITAGE CRAFTING PROCESS',
                      value: p.craftingProcess!,
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Quantity Selector
                  Row(
                    children: [
                      const Text(
                        'QUANTITY:',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.warmGray),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.cream,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 16),
                              onPressed: _selectedQuantity > 1 ? () => setState(() => _selectedQuantity--) : null,
                            ),
                            Text(
                              '$_selectedQuantity',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 16),
                              onPressed: () => setState(() => _selectedQuantity++),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Action Buttons (Add to Bag & Direct Checkout)
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Add to Bag',
                          variant: ButtonVariant.secondary,
                          icon: Icons.shopping_bag_outlined,
                          onPressed: () {
                            if (!appState.auth.isAuthenticated) {
                              showAuthRequiredDialog(context, action: 'add handcrafted items to your bag');
                              return;
                            }
                            appState.cart.addToCart(p, quantity: _selectedQuantity);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Added $_selectedQuantity x "${p.title}" to Bag'),
                                backgroundColor: AppColors.navy,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(
                          text: 'Buy Now',
                          variant: ButtonVariant.primary,
                          onPressed: () {
                            if (!appState.auth.isAuthenticated) {
                              showAuthRequiredDialog(context, action: 'complete your craft order');
                              return;
                            }
                            appState.cart.addToCart(p, quantity: _selectedQuantity);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CartScreen()),
                            );
                          },
                        ),
                      ),
                    ],
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

  Widget _buildInfoTile({required IconData icon, required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.gold),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: AppColors.warmGray),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.navy),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackImage() {
    return const Center(
      child: Icon(Icons.brush_outlined, size: 48, color: AppColors.warmGrayLight),
    );
  }
}
