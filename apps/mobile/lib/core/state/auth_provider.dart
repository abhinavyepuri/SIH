import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../network/api_client.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isArtisan => _currentUser?.role == 'artisan';
  bool get isCustomer => _currentUser?.role == 'customer';
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setUser(User? user) {
    _currentUser = user;
    ApiClient.authToken = user?.token;
    notifyListeners();
  }

  Future<bool> login({
    required String email,
    required String password,
    required String role, // 'customer', 'artisan', 'admin'
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.post('/auth/login', {
        'email': email.trim(),
        'password': password,
        'role': role,
      });

      final token = response['token'] ?? response['access_token'];
      final userData = response['user'] ?? response;

      final user = User(
        id: userData['id'] ?? userData['user_id'] ?? 'USR_${DateTime.now().millisecondsSinceEpoch}',
        name: userData['name'] ?? email.split('@')[0],
        email: email,
        role: role,
        phone: userData['phone'],
        token: token,
      );

      setUser(user);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerCustomer({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.post('/auth/register/customer', {
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
        if (phone != null && phone.isNotEmpty) 'phone': phone.trim(),
      });

      final token = response['token'] ?? response['access_token'];
      final userData = response['user'] ?? response;

      final user = User(
        id: userData['id'] ?? 'CST_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
        role: 'customer',
        phone: phone,
        token: token,
      );

      setUser(user);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerArtisan({
    required String name,
    required String email,
    required String password,
    required String craftCategory,
    required String location,
    String? phone,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.post('/auth/register/artisan', {
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
        'craft_category': craftCategory,
        'location': location,
        if (phone != null && phone.isNotEmpty) 'phone': phone.trim(),
      });

      final token = response['token'] ?? response['access_token'];
      final userData = response['user'] ?? response;

      final user = User(
        id: userData['id'] ?? 'ART_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
        role: 'artisan',
        phone: phone,
        token: token,
      );

      setUser(user);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    setUser(null);
  }
}
