import 'package:flutter/material.dart';
import '../../models/product.dart';

class WishlistProvider extends ChangeNotifier {
  final Set<String> _wishlistProductIds = {};
  final List<Product> _wishlistProducts = [];

  List<Product> get items => List.unmodifiable(_wishlistProducts);
  int get count => _wishlistProducts.length;

  bool isFavorite(String productId) => _wishlistProductIds.contains(productId);

  void toggleFavorite(Product product) {
    if (_wishlistProductIds.contains(product.id)) {
      _wishlistProductIds.remove(product.id);
      _wishlistProducts.removeWhere((p) => p.id == product.id);
    } else {
      _wishlistProductIds.add(product.id);
      _wishlistProducts.add(product);
    }
    notifyListeners();
  }
}
