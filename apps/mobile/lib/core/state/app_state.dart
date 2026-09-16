import 'package:flutter/material.dart';
import 'auth_provider.dart';
import 'cart_provider.dart';
import 'wishlist_provider.dart';

class AppState extends InheritedWidget {
  final AuthProvider auth;
  final CartProvider cart;
  final WishlistProvider wishlist;

  const AppState({
    super.key,
    required this.auth,
    required this.cart,
    required this.wishlist,
    required super.child,
  });

  static AppState of(BuildContext context) {
    final state = context.dependOnInheritedWidgetOfExactType<AppState>();
    assert(state != null, 'No AppState found in context');
    return state!;
  }

  @override
  bool updateShouldNotify(AppState oldWidget) => true;
}
