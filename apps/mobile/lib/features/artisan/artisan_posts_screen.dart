import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';
import '../../core/state/app_state.dart';
import '../../models/product.dart';
import 'list_product_screen.dart';

class ArtisanPostsScreen extends StatefulWidget {
  const ArtisanPostsScreen({super.key});

  @override
  State<ArtisanPostsScreen> createState() => _ArtisanPostsScreenState();
}

class _ArtisanPostsScreenState extends State<ArtisanPostsScreen> {
  bool _isLoading = true;
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    final user = AppState.of(context).auth.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final res = await ApiClient.get('/artisans/${user.id}/products');
      List<Product> list = [];
      if (res is Map && res.containsKey('products')) {
        list = (res['products'] as List).map((j) => Product.fromJson(j)).toList();
      } else if (res is List) {
        list = res.map((j) => Product.fromJson(j)).toList();
      }
      setState(() {
        _products = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteProduct(String productId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Creation?'),
        content: const Text('Are you sure you want to remove this piece from your inventory?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await ApiClient.delete('/products/$productId');
      _loadProducts();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product removed from inventory.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete: ${e.toString()}'), backgroundColor: AppColors.error),
      );
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'published':
        return AppColors.success;
      case 'sold':
        return AppColors.warning;
      case 'draft':
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
          'MY WORK INVENTORY',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: AppColors.navy,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.navy),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ListProductScreen()),
              ).then((_) => _loadProducts());
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProducts,
        color: AppColors.gold,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.gold)))
            : _products.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.warmGrayLight),
                          const SizedBox(height: 16),
                          const Text('No Works Listed Yet', style: TextStyle(fontFamily: 'serif', fontSize: 18, color: AppColors.navy)),
                          const SizedBox(height: 6),
                          const Text('List your first handcrafted piece to showcase it in the national gallery.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppColors.warmGray)),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ListProductScreen()),
                              ).then((_) => _loadProducts());
                            },
                            child: const Text('+ List First Work'),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _products.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, index) {
                      final p = _products[index];
                      final color = _statusColor(p.status);

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
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: AppColors.cream,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: p.primaryImage != null && p.primaryImage!.isNotEmpty
                                    ? Image.network(p.primaryImage!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.brush, color: AppColors.warmGrayLight))
                                    : const Icon(Icons.brush, color: AppColors.warmGrayLight),
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          p.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontFamily: 'serif', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.navy),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: color.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          p.status.toUpperCase(),
                                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${p.category} • Qty: ${p.quantity}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.warmGrayLight),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '₹${p.price.toInt()}',
                                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.navy),
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.navy),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => ListProductScreen(editProduct: p),
                                                ),
                                              ).then((_) => _loadProducts());
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                                            onPressed: () => _deleteProduct(p.id),
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
    );
  }
}
