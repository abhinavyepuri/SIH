import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../explore/explore_screen.dart';

class CollectionItem {
  final String title;
  final String category;
  final String description;
  final String badge;
  final List<String> tags;
  final List<Color> gradientColors;

  const CollectionItem({
    required this.title,
    required this.category,
    required this.description,
    required this.badge,
    required this.tags,
    required this.gradientColors,
  });
}

class CollectionsScreen extends StatelessWidget {
  const CollectionsScreen({super.key});

  static const List<CollectionItem> collections = [
    CollectionItem(
      title: 'The Kiln & The Wheel',
      category: 'Ceramics',
      description: 'Embracing imperfection through wood-fired glazes, raw terracotta, and quartz Jaipur pottery.',
      badge: 'MASTER CERAMICS',
      tags: ['Jaipur Blue Glaze', 'Khurja Terracotta', 'Stoneware'],
      gradientColors: [Color(0xFF2C241E), Color(0xFF1E1A17)],
    ),
    CollectionItem(
      title: 'Heirloom Looms & Natural Dyes',
      category: 'Textiles',
      description: 'Centuries-old pit loom traditions weaving pure mulberry silks, Pashmina wool, and herbal indigo.',
      badge: 'HERITAGE TEXTILES',
      tags: ['Chanderi Silk', 'Kashmiri Pashmina', 'Bagru Block Print'],
      gradientColors: [Color(0xFF2B181C), Color(0xFF18151E)],
    ),
    CollectionItem(
      title: 'Solid Hardwood & Inlay Joinery',
      category: 'Woodworking',
      description: 'Seasoned Indian rosewood and teak crafted with geometric brass inlays and traditional lattice screens.',
      badge: 'MASTER WOODCRAFT',
      tags: ['Saharanpur Teak', 'Sheet Brass Inlay', 'Jali Carving'],
      gradientColors: [Color(0xFF2A1F16), Color(0xFF1A1716)],
    ),
    CollectionItem(
      title: 'The Lost-Wax Metal Foundry',
      category: 'Metalwork',
      description: '4,000-year tribal Dhokra casting and hand-beaten bell metal crafted into timeless sculptural heirlooms.',
      badge: 'ANCIENT METALWORK',
      tags: ['Bastar Dhokra', 'Beaten Brass', 'Moradabad Inlay'],
      gradientColors: [Color(0xFF22262B), Color(0xFF16181B)],
    ),
    CollectionItem(
      title: 'Sacred Folk Arts & Handicrafts',
      category: 'Handicrafts',
      description: 'Preserving generational folklore, Madhubani brush paintings, and royal Bidriware silver inlays.',
      badge: 'GI REGIONAL CRAFT',
      tags: ['Madhubani Art', 'Bidriware', 'Tarkashi'],
      gradientColors: [Color(0xFF2B1B22), Color(0xFF1A161E)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
        title: const Text(
          'HERITAGE COLLECTIONS',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: AppColors.navy,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: collections.length,
        itemBuilder: (ctx, index) {
          final item = collections[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: item.gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(22),
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
                          border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          item.badge,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                            color: AppColors.goldLight,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_forward, color: AppColors.goldLight, size: 18),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.8),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: item.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExploreScreen(initialCategory: item.category),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.navy,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        'Explore ${item.category} →',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
