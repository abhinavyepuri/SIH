class Artisan {
  final String id;
  final String name;
  final String location;
  final String craftCategory;
  final List<String> languages;
  final String businessType;
  final String verificationStatus;
  final String? phone;
  final String? email;
  final String? profileImage;
  final DateTime? createdAt;
  final bool isActive;

  Artisan({
    required this.id,
    required this.name,
    required this.location,
    required this.craftCategory,
    this.languages = const [],
    this.businessType = 'individual',
    this.verificationStatus = 'pending',
    this.phone,
    this.email,
    this.profileImage,
    this.createdAt,
    this.isActive = true,
  });

  factory Artisan.fromJson(Map<String, dynamic> json) {
    List<String> langs = [];
    if (json['languages'] != null) {
      if (json['languages'] is List) {
        langs = List<String>.from(json['languages']);
      } else if (json['languages'] is String) {
        langs = (json['languages'] as String).split(',').map((e) => e.trim()).toList();
      }
    }

    return Artisan(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      craftCategory: json['craft_category'] ?? '',
      languages: langs,
      businessType: json['business_type'] ?? 'individual',
      verificationStatus: json['verification_status'] ?? 'pending',
      phone: json['phone'],
      email: json['email'],
      profileImage: json['profile_image'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'craft_category': craftCategory,
      'languages': languages,
      'business_type': businessType,
      'verification_status': verificationStatus,
      'phone': phone,
      'email': email,
      'profile_image': profileImage,
      'is_active': isActive,
    };
  }
}
