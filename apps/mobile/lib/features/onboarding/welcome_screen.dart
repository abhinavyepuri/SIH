import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../auth/auth_screen.dart';
import '../home/customer_main_nav.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beige,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Luxury Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.stars, size: 14, color: AppColors.gold),
                    SizedBox(width: 6),
                    Text(
                      'AI-POWERED ARTISAN MARKETPLACE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Title & Subtitle
              const Text(
                'AESTHETE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3.0,
                  color: AppColors.navy,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Direct-to-Creator Indigenous Luxury',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.warmGray,
                  letterSpacing: 0.3,
                ),
              ),

              const SizedBox(height: 36),

              // Portal Card 1: Connoisseur / Buyer
              _buildPortalCard(
                context,
                title: 'Connoisseur & Collector',
                subtitle: 'Explore authentic handcrafted creations, direct from India’s master artisan guilds.',
                badge: 'CURATED COMMERCE',
                buttonText: 'Enter as Buyer →',
                isPrimary: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AuthScreen(initialRole: 'customer'),
                    ),
                  );
                },
                onQuickBrowse: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CustomerMainNav(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Portal Card 2: Master Artisan Atelier
              _buildPortalCard(
                context,
                title: 'Master Artisan Atelier',
                subtitle: 'List your handcrafted works, enhance catalog photos with AI, and manage orders.',
                badge: 'CREATOR ATELIER',
                buttonText: 'Enter as Artisan →',
                isPrimary: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AuthScreen(initialRole: 'artisan'),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              // Footer Note
              const Text(
                'Supporting Heritage Crafts Across India',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.warmGrayLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPortalCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String badge,
    required String buttonText,
    required bool isPrimary,
    required VoidCallback onTap,
    VoidCallback? onQuickBrowse,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPrimary ? AppColors.gold : AppColors.border,
          width: isPrimary ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: isPrimary ? 0.08 : 0.03),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isPrimary ? AppColors.navy : AppColors.cream,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: isPrimary ? AppColors.gold : AppColors.navy,
                  ),
                ),
              ),
              Icon(
                isPrimary ? Icons.diamond_outlined : Icons.brush_outlined,
                color: isPrimary ? AppColors.gold : AppColors.warmGrayLight,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.warmGray,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: isPrimary ? AppColors.navy : AppColors.cream,
                foregroundColor: isPrimary ? Colors.white : AppColors.navy,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: isPrimary ? BorderSide.none : const BorderSide(color: AppColors.border),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          if (onQuickBrowse != null) ...[
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: onQuickBrowse,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  foregroundColor: AppColors.warmGray,
                ),
                child: const Text(
                  'Quick Browse Without Login',
                  style: TextStyle(
                    fontSize: 11,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
