import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';
import '../../core/state/app_state.dart';
import '../../models/product.dart';
import '../../shared/widgets/stat_card.dart';
import '../../shared/widgets/custom_button.dart';
import 'list_product_screen.dart';
import 'artisan_posts_screen.dart';
import 'artisan_orders_screen.dart';

class ArtisanDashboardScreen extends StatefulWidget {
  const ArtisanDashboardScreen({super.key});

  @override
  State<ArtisanDashboardScreen> createState() => _ArtisanDashboardScreenState();
}

class _ArtisanDashboardScreenState extends State<ArtisanDashboardScreen> {
  bool _isLoading = true;
  List<Product> _products = [];
  double _totalRevenue = 0.0;
  int _publishedCount = 0;
  int _draftCount = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    final user = AppState.of(context).auth.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final res = await ApiClient.get('/artisans/${user.id}/products');
      List<Product> loaded = [];
      if (res is Map && res.containsKey('products')) {
        loaded = (res['products'] as List).map((j) => Product.fromJson(j)).toList();
      } else if (res is List) {
        loaded = res.map((j) => Product.fromJson(j)).toList();
      }

      double revenue = 0.0;
      int pub = 0;
      int draft = 0;
      for (final p in loaded) {
        if (p.status == 'sold') {
          revenue += p.price;
        } else if (p.status == 'published') {
          pub++;
        } else if (p.status == 'draft') {
          draft++;
        }
      }

      if (mounted) {
        setState(() {
          _products = loaded;
          _totalRevenue = revenue;
          _publishedCount = pub;
          _draftCount = draft;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AppState.of(context).auth.currentUser;

    return Scaffold(
      backgroundColor: AppColors.beige,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'ARTISAN ATELIER',
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
            icon: const Icon(Icons.refresh, color: AppColors.navy),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        color: AppColors.gold,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.luxuryNavy,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.navy.withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.gold),
                          ),
                          child: const Text(
                            'ATELIER DASHBOARD',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.goldLight, letterSpacing: 0.8),
                          ),
                        ),
                        const Icon(Icons.diamond_outlined, color: AppColors.gold, size: 20),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Welcome, ${user?.name ?? "Master Artisan"}',
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Manage your handcrafted listings, view sales performance, and fulfill orders.',
                      style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8), height: 1.4),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // KPI Metrics Grid
              const Text(
                'PERFORMANCE OVERVIEW',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.0, color: AppColors.warmGray),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Total Works',
                      value: '${_products.length}',
                      icon: Icons.inventory_2_outlined,
                      subtitle: '$_publishedCount active in gallery',
                      accentColor: AppColors.navy,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Sold Revenue',
                      value: '₹${_totalRevenue.toInt()}',
                      icon: Icons.currency_rupee,
                      subtitle: 'Direct artisan earnings',
                      accentColor: AppColors.gold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Published',
                      value: '$_publishedCount',
                      icon: Icons.public,
                      subtitle: 'Live for collectors',
                      accentColor: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Drafts',
                      value: '$_draftCount',
                      icon: Icons.edit_note,
                      subtitle: 'In preparation',
                      accentColor: AppColors.warning,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Quick Actions
              const Text(
                'QUICK ACTIONS',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.0, color: AppColors.warmGray),
              ),
              const SizedBox(height: 12),

              CustomButton(
                text: '+ List New Handcrafted Work',
                icon: Icons.add,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ListProductScreen()),
                  ).then((_) => _loadDashboardData());
                },
              ),
              const SizedBox(height: 10),
              CustomButton(
                text: 'Manage Work Inventory',
                variant: ButtonVariant.secondary,
                icon: Icons.inventory_outlined,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ArtisanPostsScreen()),
                  ).then((_) => _loadDashboardData());
                },
              ),
              const SizedBox(height: 10),
              CustomButton(
                text: 'View Received Orders',
                variant: ButtonVariant.outline,
                icon: Icons.receipt_long_outlined,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ArtisanOrdersScreen()),
                  );
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
