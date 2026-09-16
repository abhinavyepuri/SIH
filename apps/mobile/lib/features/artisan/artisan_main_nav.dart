import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/state/app_state.dart';
import 'artisan_dashboard_screen.dart';
import 'artisan_posts_screen.dart';
import 'list_product_screen.dart';
import 'artisan_orders_screen.dart';
import '../onboarding/welcome_screen.dart';

class ArtisanMainNav extends StatefulWidget {
  const ArtisanMainNav({super.key});

  @override
  State<ArtisanMainNav> createState() => _ArtisanMainNavState();
}

class _ArtisanMainNavState extends State<ArtisanMainNav> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    ArtisanDashboardScreen(),
    ArtisanPostsScreen(),
    ListProductScreen(),
    ArtisanOrdersScreen(),
  ];

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave Atelier?'),
        content: const Text('Are you sure you want to sign out of your artisan account?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.navy),
            onPressed: () {
              Navigator.pop(ctx);
              AppState.of(context).auth.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                (route) => false,
              );
            },
            child: const Text('Sign Out'),
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
              color: AppColors.navy.withValues(alpha: 0.05),
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
          selectedItemColor: AppColors.navy,
          unselectedItemColor: AppColors.warmGrayLight,
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
              label: 'My Works',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              activeIcon: Icon(Icons.add_circle),
              label: 'List Work',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Orders',
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
