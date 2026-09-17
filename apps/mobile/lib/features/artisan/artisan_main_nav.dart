import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/state/app_state.dart';
import 'artisan_dashboard_screen.dart';
import 'artisan_posts_screen.dart';
import 'artisan_orders_screen.dart';
import 'artisan_earnings_screen.dart';
import 'list_product_screen.dart';
import '../onboarding/welcome_screen.dart';

class ArtisanMainNav extends StatefulWidget {
  const ArtisanMainNav({super.key});

  @override
  State<ArtisanMainNav> createState() => _ArtisanMainNavState();
}

class _ArtisanMainNavState extends State<ArtisanMainNav> {
  int _currentIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      ArtisanDashboardScreen(
        onNavigateToList: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ListProductScreen()),
        ),
        onNavigateToPosts: () => _switchTab(1),
        onNavigateToOrders: () => _switchTab(2),
        onNavigateToEarnings: () => _switchTab(3),
      ),
      const ArtisanPostsScreen(),
      const ArtisanOrdersScreen(),
      const ArtisanEarningsScreen(),
    ];
  }

  void _switchTab(int index) {
    setState(() => _currentIndex = index);
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Leave Atelier?',
          style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
        content: const Text(
          'Are you sure you want to sign out of your master artisan account?',
          style: TextStyle(fontSize: 13, color: AppColors.warmGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.warmGray)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.terracotta,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              AppState.of(context).auth.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                (route) => false,
              );
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: const Border(top: BorderSide(color: AppColors.border, width: 1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index == 4) {
              _handleLogout();
            } else {
              setState(() => _currentIndex = index);
            }
          },
          selectedItemColor: AppColors.terracotta,
          unselectedItemColor: AppColors.warmGrayLight,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surface,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              activeIcon: Icon(Icons.inventory_2),
              label: 'Catalog',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_shipping_outlined),
              activeIcon: Icon(Icons.local_shipping),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              activeIcon: Icon(Icons.account_balance_wallet),
              label: 'Earnings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.logout_outlined),
              label: 'Exit',
            ),
          ],
        ),
      ),
    );
  }
}
