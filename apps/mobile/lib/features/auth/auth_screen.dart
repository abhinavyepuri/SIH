import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/state/app_state.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../home/customer_main_nav.dart';
import '../artisan/artisan_main_nav.dart';

class AuthScreen extends StatefulWidget {
  final String initialRole; // 'customer' or 'artisan'

  const AuthScreen({
    super.key,
    this.initialRole = 'customer',
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late String _selectedRole;
  bool _isLoginMode = true;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  String _selectedCraft = 'Ceramics';

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final appState = AppState.of(context);
    bool success = false;

    if (_isLoginMode) {
      success = await appState.auth.login(
        email: _emailController.text,
        password: _passwordController.text,
        role: _selectedRole,
      );
    } else {
      if (_selectedRole == 'artisan') {
        success = await appState.auth.registerArtisan(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          craftCategory: _selectedCraft,
          location: _locationController.text.isNotEmpty ? _locationController.text : 'Jaipur, Rajasthan',
          phone: _phoneController.text,
        );
      } else {
        success = await appState.auth.registerCustomer(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          phone: _phoneController.text,
        );
      }
    }

    if (!mounted) return;

    if (success) {
      if (_selectedRole == 'artisan') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const ArtisanMainNav()),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const CustomerMainNav()),
          (route) => false,
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appState.auth.errorMessage ?? 'Authentication failed. Please check credentials.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState.of(context);

    return Scaffold(
      backgroundColor: AppColors.beige,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.navy),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  _selectedRole == 'artisan'
                      ? (_isLoginMode ? 'Artisan Atelier Login' : 'Join as Master Artisan')
                      : (_isLoginMode ? 'Connoisseur Sign In' : 'Create Collector Account'),
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _isLoginMode
                      ? 'Welcome back to the direct-to-creator craft portal.'
                      : 'Join the premier digital community supporting Indian craft heritage.',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.warmGray,
                  ),
                ),

                const SizedBox(height: 24),

                // Role Selector Tabs (Buyer / Artisan)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.cream,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedRole = 'customer'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _selectedRole == 'customer' ? AppColors.navy : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                'Connoisseur (Buyer)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _selectedRole == 'customer' ? Colors.white : AppColors.warmGray,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedRole = 'artisan'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _selectedRole == 'artisan' ? AppColors.navy : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                'Master Artisan',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _selectedRole == 'artisan' ? Colors.white : AppColors.warmGray,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Card with Fields
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.navy.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name field (if registering)
                      if (!_isLoginMode) ...[
                        CustomTextField(
                          label: 'Full Name / Studio Name',
                          hint: 'e.g., Ram Narayan Sharma',
                          controller: _nameController,
                          prefixIcon: const Icon(Icons.person_outline, size: 18, color: AppColors.warmGrayLight),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Email field
                      CustomTextField(
                        label: 'Email Address',
                        hint: 'artisan@aesthete.in',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email_outlined, size: 18, color: AppColors.warmGrayLight),
                        validator: (v) => (v == null || !v.contains('@')) ? 'Please enter a valid email' : null,
                      ),

                      const SizedBox(height: 16),

                      // Password field
                      CustomTextField(
                        label: 'Password',
                        hint: '••••••••',
                        controller: _passwordController,
                        obscureText: true,
                        prefixIcon: const Icon(Icons.lock_outline, size: 18, color: AppColors.warmGrayLight),
                        validator: (v) => (v == null || v.length < 4) ? 'Password must be at least 4 characters' : null,
                      ),

                      // Additional fields for Artisan Registration
                      if (!_isLoginMode && _selectedRole == 'artisan') ...[
                        const SizedBox(height: 16),
                        const Text(
                          'PRIMARY CRAFT CATEGORY',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                            color: AppColors.warmGray,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedCraft,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.navy),
                              items: ['Ceramics', 'Textiles', 'Woodworking', 'Metalwork', 'Handicrafts']
                                  .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 14))))
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) setState(() => _selectedCraft = v);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Studio Location / City',
                          hint: 'e.g., Jaipur, Rajasthan',
                          controller: _locationController,
                          prefixIcon: const Icon(Icons.location_on_outlined, size: 18, color: AppColors.warmGrayLight),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Submit Button
                      CustomButton(
                        text: _isLoginMode ? 'Sign In →' : 'Create Account →',
                        isLoading: appState.auth.isLoading,
                        onPressed: _handleSubmit,
                      ),

                      const SizedBox(height: 16),

                      // Toggle Login/Register
                      Center(
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _isLoginMode = !_isLoginMode;
                            });
                          },
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(fontSize: 12, color: AppColors.warmGray),
                              children: [
                                TextSpan(text: _isLoginMode ? "Don't have an account? " : "Already registered? "),
                                TextSpan(
                                  text: _isLoginMode ? 'Sign Up' : 'Sign In',
                                  style: const TextStyle(
                                    color: AppColors.navy,
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
