import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';
import '../../models/artisan.dart';
import '../../models/product.dart';
import '../../shared/widgets/product_card.dart';
import '../products/product_detail_screen.dart';

class ArtisanProfileScreen extends StatefulWidget {
  final String artisanId;

  const ArtisanProfileScreen({super.key, required this.artisanId});

  @override
  State<ArtisanProfileScreen> createState() => _ArtisanProfileScreenState();
}

class _ArtisanProfileScreenState extends State<ArtisanProfileScreen> {
  bool _isLoading = true;
  Artisan? _artisan;
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final artisanRes = await ApiClient.get('/artisans/${widget.artisanId}');
      final productsRes = await ApiClient.get('/artisans/${widget.artisanId}/products');

      Artisan? a;
      if (artisanRes is Map<String, dynamic>) {
        a = Artisan.fromJson(artisanRes);
      }

      List<Product> prods = [];
      if (productsRes is Map && productsRes.containsKey('products')) {
        prods = (productsRes['products'] as List).map((j) => Product.fromJson(j)).toList();
      } else if (productsRes is List) {
        prods = productsRes.map((j) => Product.fromJson(j)).toList();
      }

      setState(() {
        _artisan = a;
        _products = prods;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.beige,
        body: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.gold))),
      );
    }

    if (_artisan == null) {
      return Scaffold(
        backgroundColor: AppColors.beige,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(child: Text('Artisan not found', style: TextStyle(fontFamily: 'serif', fontSize: 16))),
      );
    }

    final a = _artisan!;

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
          a.craftCategory.toUpperCase(),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: AppColors.warmGray),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Profile Header Card
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.cream,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.gold, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        a.name.isNotEmpty ? a.name[0].toUpperCase() : 'A',
                        style: const TextStyle(
                          fontFamily: 'serif',
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: AppColors.navy,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        a.name,
                        style: const TextStyle(
                          fontFamily: 'serif',
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.navy,
                        ),
                      ),
                      if (a.verificationStatus == 'approved') ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.verified, size: 20, color: AppColors.gold),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: AppColors.warmGrayLight),
                      const SizedBox(width: 4),
                      Text(
                        a.location,
                        style: const TextStyle(fontSize: 12, color: AppColors.warmGray),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      _badge(a.craftCategory),
                      _badge(a.businessType.toUpperCase()),
                      if (a.languages.isNotEmpty) _badge(a.languages.join(' • ')),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Works Section Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'PORTFOLIO CREATIONS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: AppColors.navy,
                    ),
                  ),
                  Text(
                    '${_products.length} piece${_products.length != 1 ? 's' : ''}',
                    style: const TextStyle(fontSize: 12, color: AppColors.warmGray),
                  ),
                ],
              ),
            ),

            // Products Grid
            if (_products.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Text('No works published by this artisan yet.', style: TextStyle(color: AppColors.warmGray)),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemCount: _products.length,
                  itemBuilder: (ctx, index) {
                    final p = _products[index];
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

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.navy),
      ),
    );
  }
}
