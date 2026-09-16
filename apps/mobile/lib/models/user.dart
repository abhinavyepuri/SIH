class User {
  final String id;
  final String name;
  final String email;
  final String role; // 'customer', 'artisan', 'admin'
  final String? phone;
  final String? token;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json, {String? token}) {
    return User(
      id: json['id'] ?? json['user_id'] ?? '',
      name: json['name'] ?? json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'customer',
      phone: json['phone'],
      token: token ?? json['token'] ?? json['access_token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'token': token,
    };
  }
}
