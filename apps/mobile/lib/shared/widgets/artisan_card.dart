import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/artisan.dart';

class ArtisanCard extends StatelessWidget {
  final Artisan artisan;
  final VoidCallback onTap;

  const ArtisanCard({
    super.key,
    required this.artisan,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Profile Avatar with craft icon or image
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.beige,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.gold, width: 1.5),
              ),
              child: ClipOval(
                child: artisan.profileImage != null && artisan.profileImage!.isNotEmpty
                    ? Image.network(
                        artisan.profileImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _avatarFallback(),
                      )
                    : _avatarFallback(),
              ),
            ),

            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          artisan.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'serif',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.navy,
                          ),
                        ),
                      ),
                      if (artisan.verificationStatus == 'approved') ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.verified, size: 16, color: AppColors.gold),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.cream,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          artisan.craftCategory,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.navy,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.location_on_outlined, size: 12, color: AppColors.warmGrayLight),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          artisan.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.warmGray,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (artisan.languages.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Languages: ${artisan.languages.join(', ')}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.warmGrayLight,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const Icon(Icons.chevron_right, color: AppColors.warmGrayLight),
          ],
        ),
      ),
    );
  }

  Widget _avatarFallback() {
    return Center(
      child: Text(
        artisan.name.isNotEmpty ? artisan.name[0].toUpperCase() : 'A',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.navy,
        ),
      ),
    );
  }
}
