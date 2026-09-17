import 'package:flutter/material.dart';
import 'core/state/auth_provider.dart';
import 'core/state/cart_provider.dart';
import 'core/state/wishlist_provider.dart';
import 'core/state/app_state.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/welcome_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ArohaApp());
}

class ArohaApp extends StatefulWidget {
  const ArohaApp({super.key});

  @override
  State<ArohaApp> createState() => _ArohaAppState();
}

class _ArohaAppState extends State<ArohaApp> {
  final _authProvider = AuthProvider();
  final _cartProvider = CartProvider();
  final _wishlistProvider = WishlistProvider();

  @override
  void initState() {
    super.initState();
    _authProvider.addListener(_onStateChanged);
    _cartProvider.addListener(_onStateChanged);
    _wishlistProvider.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _authProvider.removeListener(_onStateChanged);
    _cartProvider.removeListener(_onStateChanged);
    _wishlistProvider.removeListener(_onStateChanged);
    _authProvider.dispose();
    _cartProvider.dispose();
    _wishlistProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppState(
      auth: _authProvider,
      cart: _cartProvider,
      wishlist: _wishlistProvider,
      child: MaterialApp(
        title: 'Aroha — Where Artists Meet the Market',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const WelcomeScreen(),
      ),
    );
  }
}
