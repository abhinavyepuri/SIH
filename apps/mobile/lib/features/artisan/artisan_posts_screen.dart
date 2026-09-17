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
  String _searchQuery = '';
  String _selectedFilter = 'All'; // 'All', 'Published', 'Drafts', 'GI Tagged'
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final user = AppState.of(context).auth.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
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
      if (mounted) {
        setState(() {
          _products = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteProduct(String productId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Remove Creation?',
          style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
        content: const Text(
          'Are you sure you want to remove this piece from your atelier catalog?',
          style: TextStyle(fontSize: 13, color: AppColors.warmGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.warmGray)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
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
        const SnackBar(content: Text('Product removed from catalog')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete: ${e.toString()}'), backgroundColor: AppColors.error),
      );
    }
  }

  int get _publishedCount => _products.where((p) => p.status.toLowerCase() == 'published').length;
  int get _draftCount => _products.where((p) => p.status.toLowerCase() == 'draft').length;
  int get _giCount => _products.where((p) => p.isGiCertified).length;

  List<Product> get _filteredProducts {
    return _products.where((p) {
      final matchesSearch = _searchQuery.isEmpty ||
          p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.category.toLowerCase().contains(_searchQuery.toLowerCase());

      if (!matchesSearch) return false;

      if (_selectedFilter == 'Published') {
        return p.status.toLowerCase() == 'published';
      } else if (_selectedFilter == 'Drafts') {
        return p.status.toLowerCase() == 'draft';
      } else if (_selectedFilter == 'GI Tagged') {
        return p.isGiCertified;
      }
      return true;
    }).toList();
  }

  Widget _buildKpiCard(String label, String value, IconData icon, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.warmGray),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredProducts;

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
              'My Catalog Items',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Manage your authentic craft portfolio',
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
            onPressed: _loadProducts,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.terracotta,
        elevation: 4,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ListProductScreen()),
          ).then((_) => _loadProducts());
        },
        icon: const Icon(Icons.add_photo_alternate_outlined, color: Colors.white, size: 20),
        label: const Text(
          'Add Craft Item',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadProducts,
        color: AppColors.terracotta,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 4 Top KPI Cards
              Row(
                children: [
                  Expanded(
                    child: _buildKpiCard('Total Items', '${_products.length}', Icons.inventory_2_outlined, AppColors.terracotta, AppColors.roseLight),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildKpiCard('Live Market', '$_publishedCount', Icons.check_circle_outline, AppColors.success, AppColors.successLight),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildKpiCard('GI Certified', '$_giCount', Icons.verified_outlined, AppColors.gold, AppColors.goldMuted),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildKpiCard('Drafts', '$_draftCount', Icons.edit_note_outlined, AppColors.warning, AppColors.warningLight),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search catalog items...',
                    hintStyle: const TextStyle(fontSize: 13, color: AppColors.warmGrayLight),
                    prefixIcon: const Icon(Icons.search, color: AppColors.warmGray, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, size: 18, color: AppColors.warmGray),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    {'name': 'All', 'count': _products.length},
                    {'name': 'Published', 'count': _publishedCount},
                    {'name': 'Drafts', 'count': _draftCount},
                    {'name': 'GI Tagged', 'count': _giCount},
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
                            color: isSelected ? AppColors.terracotta : AppColors.surface,
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

              const SizedBox(height: 16),

              // Product Cards List or Empty State
              _isLoading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(AppColors.terracotta),
                        ),
                      ),
                    )
                  : filtered.isEmpty
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: AppColors.roseLight,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.inventory_2_outlined,
                                  size: 34,
                                  color: AppColors.terracotta,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No Items in this View',
                                style: TextStyle(
                                  fontFamily: 'serif',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'List your handcrafted creations to showcase them across India.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12, color: AppColors.warmGray),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filtered.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 14),
                          itemBuilder: (ctx, index) {
                            final p = filtered[index];
                            final isPublished = p.status.toLowerCase() == 'published';
                            final hasGi = p.isGiCertified;

                            return Container(
                              padding: const EdgeInsets.all(14),
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
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Image Thumbnail with Badge
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: p.primaryImage != null && p.primaryImage!.isNotEmpty
                                            ? Image.network(
                                                p.primaryImage!,
                                                width: 84,
                                                height: 84,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) => Container(
                                                  width: 84,
                                                  height: 84,
                                                  color: AppColors.beigeDark,
                                                  child: const Icon(Icons.image_outlined, color: AppColors.warmGrayLight),
                                                ),
                                              )
                                            : Container(
                                                width: 84,
                                                height: 84,
                                                color: AppColors.beigeDark,
                                                child: const Icon(Icons.image_outlined, color: AppColors.warmGrayLight),
                                              ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        left: 4,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isPublished ? AppColors.success : AppColors.warmGray,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            isPublished ? 'LIVE' : 'DRAFT',
                                            style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(width: 14),

                                  // Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            if (hasGi) ...[
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: AppColors.goldMuted,
                                                  borderRadius: BorderRadius.circular(4),
                                                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                                                ),
                                                child: const Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.verified, size: 9, color: AppColors.gold),
                                                    SizedBox(width: 3),
                                                    Text(
                                                      'GI CERTIFIED',
                                                      style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: AppColors.gold),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                            ],
                                            Expanded(
                                              child: Text(
                                                p.category.toUpperCase(),
                                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.warmGray),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          p.title,
                                          style: const TextStyle(
                                            fontFamily: 'serif',
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '₹${p.price.toInt()}',
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.terracotta,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                IconButton(
                                                  padding: EdgeInsets.zero,
                                                  constraints: const BoxConstraints(),
                                                  icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.warmGray),
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) => ListProductScreen(editProduct: p),
                                                      ),
                                                    ).then((_) => _loadProducts());
                                                  },
                                                ),
                                                const SizedBox(width: 8),
                                                IconButton(
                                                  padding: EdgeInsets.zero,
                                                  constraints: const BoxConstraints(),
                                                  icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.warmGrayLight),
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
              const SizedBox(height: 80), // Fab space
            ],
          ),
        ),
      ),
    );
  }
}
