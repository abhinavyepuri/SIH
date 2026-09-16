import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/state/app_state.dart';
import '../../models/product.dart';
import '../../shared/widgets/product_card.dart';
import '../../shared/widgets/category_pill.dart';
import '../products/product_detail_screen.dart';
import '../wishlist/wishlist_screen.dart';
import '../cart/cart_screen.dart';
import '../auth/auth_screen.dart';

class ExploreScreen extends StatefulWidget {
  final String? initialCategory;

  const ExploreScreen({super.key, this.initialCategory});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _selectedCategory = 'All Works';
  String _searchQuery = '';
  String _priceFilter = 'all'; // 'all', 'under-2000', '2000-5000', 'above-5000'
  bool _inStockOnly = false;
  String _sortBy = 'featured'; // 'featured', 'price-asc', 'price-desc', 'newest'
  bool _isGridView = true;

  bool _isLoading = true;
  List<Product> _products = [];
  List<String> _categories = AppConstants.categories;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      _selectedCategory = widget.initialCategory!;
    }
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final queryParams = <String, String>{};
      if (_selectedCategory != 'All Works') {
        queryParams['category'] = _selectedCategory;
      }
      if (_searchQuery.trim().isNotEmpty) {
        queryParams['search'] = _searchQuery.trim();
      }

      final response = await ApiClient.get('/products/marketplace', queryParams: queryParams);
      List<Product> loaded = [];
      if (response is Map && response.containsKey('products')) {
        loaded = (response['products'] as List).map((j) => Product.fromJson(j)).toList();
      } else if (response is List) {
        loaded = response.map((j) => Product.fromJson(j)).toList();
      }

      // Dynamically extract categories if available
      final uniqueCategories = loaded.map((p) => p.category).toSet().toList();
      if (uniqueCategories.isNotEmpty) {
        _categories = ['All Works', ...uniqueCategories];
      }

      if (mounted) {
        setState(() {
          _products = loaded;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _products = [];
          _isLoading = false;
        });
      }
    }
  }

  List<Product> get _filteredAndSortedProducts {
    var list = List<Product>.from(_products);

    // Price Filter
    if (_priceFilter == 'under-2000') {
      list = list.where((p) => p.price < 2000).toList();
    } else if (_priceFilter == '2000-5000') {
      list = list.where((p) => p.price >= 2000 && p.price <= 5000).toList();
    } else if (_priceFilter == 'above-5000') {
      list = list.where((p) => p.price > 5000).toList();
    }

    // In Stock Only
    if (_inStockOnly) {
      list = list.where((p) => p.quantity > 0).toList();
    }

    // Sorting
    if (_sortBy == 'price-asc') {
      list.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortBy == 'price-desc') {
      list.sort((a, b) => b.price.compareTo(a.price));
    } else if (_sortBy == 'newest') {
      list.sort((a, b) {
        if (a.createdAt == null || b.createdAt == null) return 0;
        return b.createdAt!.compareTo(a.createdAt!);
      });
    }

    return list;
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter & Sort Creations',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navy,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 12),

                  // Price Range
                  const Text('PRICE RANGE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.warmGray)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _filterChip('All Prices', _priceFilter == 'all', () {
                        setSheetState(() => _priceFilter = 'all');
                        setState(() {});
                      }),
                      _filterChip('Under ₹2,000', _priceFilter == 'under-2000', () {
                        setSheetState(() => _priceFilter = 'under-2000');
                        setState(() {});
                      }),
                      _filterChip('₹2,000 - ₹5,000', _priceFilter == '2000-5000', () {
                        setSheetState(() => _priceFilter = '2000-5000');
                        setState(() {});
                      }),
                      _filterChip('Above ₹5,000', _priceFilter == 'above-5000', () {
                        setSheetState(() => _priceFilter = 'above-5000');
                        setState(() {});
                      }),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Availability
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('In Stock Only', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.navy)),
                    value: _inStockOnly,
                    activeColor: AppColors.navy,
                    onChanged: (v) {
                      setSheetState(() => _inStockOnly = v);
                      setState(() {});
                    },
                  ),

                  const SizedBox(height: 16),

                  // Apply Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.navy,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _filterChip(String label, bool isSelected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : AppColors.warmGray)),
      selected: isSelected,
      selectedColor: AppColors.navy,
      backgroundColor: AppColors.cream,
      onSelected: (_) => onTap(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isSelected ? AppColors.navy : AppColors.border),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayProducts = _filteredAndSortedProducts;
    final appState = AppState.of(context);
    final wishlistCount = appState.wishlist.count;

    return Scaffold(
      backgroundColor: AppColors.beige,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu, color: AppColors.navy),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
            tooltip: 'Navigation Menu',
          ),
        ),
        title: const Column(
          children: [
            Text(
              'AESTHETE',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
                color: AppColors.navy,
              ),
            ),
            Text(
              'CURATED GALLERY',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                color: AppColors.gold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: wishlistCount > 0,
              label: Text('$wishlistCount'),
              backgroundColor: AppColors.gold,
              textColor: AppColors.navy,
              child: const Icon(Icons.favorite_border, color: AppColors.navy),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WishlistScreen()),
              );
            },
            tooltip: 'Wishlist',
          ),
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list_outlined : Icons.grid_view_outlined, color: AppColors.navy),
            onPressed: () => setState(() => _isGridView = !_isGridView),
            tooltip: 'Toggle View',
          ),
          IconButton(
            icon: const Icon(Icons.tune_outlined, color: AppColors.navy),
            onPressed: _showFilterSheet,
            tooltip: 'Filters',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProducts,
        color: AppColors.gold,
        child: Column(
          children: [
            // Search Input Bar
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: _searchController,
                  onSubmitted: (v) {
                    _searchQuery = v;
                    _loadProducts();
                  },
                  decoration: InputDecoration(
                    hintText: 'Search handcrafted pottery, silks, woodwork...',
                    hintStyle: const TextStyle(fontSize: 12, color: AppColors.warmGrayLight),
                    prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.warmGray),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 16),
                            onPressed: () {
                              _searchController.clear();
                              _searchQuery = '';
                              _loadProducts();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),

            // Horizontal Category Pills
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.only(bottom: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: _categories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: CategoryPill(
                        label: cat,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() => _selectedCategory = cat);
                          _loadProducts();
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Results Counter & Active Filter summary
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Showing ${displayProducts.length} handcrafted creation${displayProducts.length != 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.warmGray,
                    ),
                  ),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _sortBy,
                      icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.navy),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.navy),
                      items: const [
                        DropdownMenuItem(value: 'featured', child: Text('Featured')),
                        DropdownMenuItem(value: 'price-asc', child: Text('Price: Low to High')),
                        DropdownMenuItem(value: 'price-desc', child: Text('Price: High to Low')),
                        DropdownMenuItem(value: 'newest', child: Text('Newest Additions')),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _sortBy = v);
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Product Grid or Empty State
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
                      ),
                    )
                  : displayProducts.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: const BoxDecoration(
                                    color: AppColors.cream,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.search_off_outlined, size: 32, color: AppColors.warmGrayLight),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No Handcrafted Pieces Found',
                                  style: TextStyle(
                                    fontFamily: 'serif',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.navy,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Try adjusting your search terms or filter selection.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 12, color: AppColors.warmGray),
                                ),
                                const SizedBox(height: 16),
                                OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedCategory = 'All Works';
                                      _searchQuery = '';
                                      _priceFilter = 'all';
                                      _inStockOnly = false;
                                      _searchController.clear();
                                    });
                                    _loadProducts();
                                  },
                                  child: const Text('Clear All Filters'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: _isGridView ? 2 : 1,
                            childAspectRatio: _isGridView ? 0.68 : 1.3,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                          ),
                          itemCount: displayProducts.length,
                          itemBuilder: (ctx, index) {
                            final p = displayProducts[index];
                            return ProductCard(
                              product: p,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProductDetailScreen(productId: p.id),
                                  ),
                                );
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
