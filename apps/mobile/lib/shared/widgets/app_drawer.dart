import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/state/app_state.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/wishlist/wishlist_screen.dart';
import '../../features/orders/orders_screen.dart';
import '../../features/cart/cart_screen.dart';
import '../../features/artisan/artisan_main_nav.dart';
import '../../features/onboarding/welcome_screen.dart';

class AppDrawer extends StatelessWidget {
  final void Function(int index)? onNavigateTab;

  const AppDrawer({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final appState = AppState.of(context);
    final user = appState.auth.currentUser;
    final isAuthenticated = appState.auth.isAuthenticated;
    final wishlistCount = appState.wishlist.count;
    final cartCount = appState.cart.itemCount;

    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            // Luxury User Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: AppColors.luxuryNavy,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.cream,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.gold, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            isAuthenticated ? (user!.name.isNotEmpty ? user.name[0].toUpperCase() : 'U') : 'G',
                            style: const TextStyle(
                              fontFamily: 'serif',
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.navy,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.gold),
                        ),
                        child: Text(
                          isAuthenticated ? user!.role.toUpperCase() : 'GUEST COLLECTOR',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: AppColors.goldLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    isAuthenticated ? user!.name : 'Welcome to AESTHETE',
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isAuthenticated ? user!.email : 'Sign in to save favorites & place orders',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  if (!isAuthenticated) ...[
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AuthScreen(initialRole: 'customer')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.navy,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Sign In / Register →', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ],
              ),
            ),

            // Navigation Links
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _drawerItem(
                    icon: Icons.explore_outlined,
                    title: 'Curated Gallery',
                    subtitle: 'Explore handcrafted creations',
                    onTap: () {
                      Navigator.pop(context);
                      onNavigateTab?.call(0);
                    },
                  ),
                  _drawerItem(
                    icon: Icons.auto_awesome_outlined,
                    title: 'Heritage Collections',
                    subtitle: 'Ceramics, Textiles, Woodwork...',
                    onTap: () {
                      Navigator.pop(context);
                      onNavigateTab?.call(1);
                    },
                  ),
                  _drawerItem(
                    icon: Icons.people_outline,
                    title: 'Master Artisans',
                    subtitle: 'Guilds & regional creators',
                    onTap: () {
                      Navigator.pop(context);
                      onNavigateTab?.call(2);
                    },
                  ),
                  const Divider(color: AppColors.border, indent: 16, endIndent: 16),
                  _drawerItem(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Shopping Bag',
                    badge: cartCount > 0 ? '$cartCount' : null,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
                    },
                  ),
                  _drawerItem(
                    icon: Icons.favorite_border,
                    title: 'Saved Creations',
                    badge: wishlistCount > 0 ? '$wishlistCount' : null,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const WishlistScreen()));
                    },
                  ),
                  _drawerItem(
                    icon: Icons.receipt_long_outlined,
                    title: 'Order History',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen()));
                    },
                  ),
                  const Divider(color: AppColors.border, indent: 16, endIndent: 16),
                  _drawerItem(
                    icon: Icons.storefront_outlined,
                    title: 'Artisan Atelier Mode',
                    subtitle: 'List works & manage studio',
                    onTap: () {
                      Navigator.pop(context);
                      if (isAuthenticated && user!.role == 'artisan') {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ArtisanMainNav()));
                      } else {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen(initialRole: 'artisan')));
                      }
                    },
                  ),
                ],
              ),
            ),

            // Footer / Sign Out
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      icon: Icon(
                        isAuthenticated ? Icons.logout : Icons.exit_to_app,
                        size: 18,
                        color: AppColors.warmGray,
                      ),
                      label: Text(
                        isAuthenticated ? 'Sign Out' : 'Back to Portals',
                        style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.w600),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        if (isAuthenticated) {
                          appState.auth.logout();
                        }
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                          (route) => false,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    String? subtitle,
    String? badge,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.navy, size: 22),
      title: Text(
        title,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.navy),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.warmGrayLight))
          : null,
      trailing: badge != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badge,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.navy),
              ),
            )
          : const Icon(Icons.chevron_right, size: 16, color: AppColors.warmGrayLight),
      onTap: onTap,
    );
  }
}
