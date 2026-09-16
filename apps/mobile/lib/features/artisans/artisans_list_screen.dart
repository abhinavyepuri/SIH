import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';
import '../../models/artisan.dart';
import '../../shared/widgets/artisan_card.dart';
import 'artisan_profile_screen.dart';

class ArtisansListScreen extends StatefulWidget {
  const ArtisansListScreen({super.key});

  @override
  State<ArtisansListScreen> createState() => _ArtisansListScreenState();
}

class _ArtisansListScreenState extends State<ArtisansListScreen> {
  bool _isLoading = true;
  List<Artisan> _artisans = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadArtisans();
  }

  Future<void> _loadArtisans() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiClient.get('/artisans/');
      List<Artisan> list = [];
      if (response is List) {
        list = response.map((j) => Artisan.fromJson(j)).toList();
      } else if (response is Map && response.containsKey('artisans')) {
        list = (response['artisans'] as List).map((j) => Artisan.fromJson(j)).toList();
      }
      setState(() {
        _artisans = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _artisans.where((a) {
      final q = _searchQuery.toLowerCase();
      return a.name.toLowerCase().contains(q) ||
          a.craftCategory.toLowerCase().contains(q) ||
          a.location.toLowerCase().contains(q);
    }).toList();

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
          'MASTER ARTISANS',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: AppColors.navy,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadArtisans,
        color: AppColors.gold,
        child: Column(
          children: [
            // Search header
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.all(16),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: const InputDecoration(
                    hintText: 'Search master creators, guilds, regions...',
                    hintStyle: TextStyle(fontSize: 12, color: AppColors.warmGrayLight),
                    prefixIcon: Icon(Icons.search, size: 18, color: AppColors.warmGray),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),

            // List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.gold)))
                  : filtered.isEmpty
                      ? const Center(
                          child: Text(
                            'No artisans found.',
                            style: TextStyle(color: AppColors.warmGray),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          itemBuilder: (ctx, index) {
                            final a = filtered[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: ArtisanCard(
                                artisan: a,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ArtisanProfileScreen(artisanId: a.id),
                                    ),
                                  );
                                },
                              ),
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
