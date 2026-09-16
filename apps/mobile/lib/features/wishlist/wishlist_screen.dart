import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/state/app_state.dart';
import '../../shared/widgets/product_card.dart';
import '../products/product_detail_screen.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppState.of(context);
    final wishlist = appState.wishlist;

    return Scaffold(
      backgroundColor: AppColors.beige,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'SAVED CREATIONS',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: AppColors.navy,
          ),
        ),
      ),
      body: wishlist.items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: const BoxDecoration(
                        color: AppColors.cream,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite_border, size: 36, color: AppColors.warmGrayLight),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No Saved Creations Yet',
                      style: TextStyle(fontFamily: 'serif', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.navy),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Tap the heart icon on any handcrafted piece in the gallery to save it to your wishlist.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: AppColors.warmGray),
                    ),
                  ],
                ),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.68,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemCount: wishlist.items.length,
              itemBuilder: (ctx, index) {
                final p = wishlist.items[index];
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
    );
  }
}
