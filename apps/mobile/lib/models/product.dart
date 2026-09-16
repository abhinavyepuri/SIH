class Product {
  final String id;
  final String artisanId;
  final String? artisanName;
  final String title;
  final String? description;
  final String category;
  final String? materials;
  final double price;
  final String currency;
  final int quantity;
  final String? tags;
  final String? images;
  final String status;
  final String? craftingProcess;
  final DateTime? createdAt;
  final bool isActive;

  Product({
    required this.id,
    required this.artisanId,
    this.artisanName,
    required this.title,
    this.description,
    required this.category,
    this.materials,
    required this.price,
    this.currency = 'INR',
    this.quantity = 1,
    this.tags,
    this.images,
    this.status = 'published',
    this.craftingProcess,
    this.createdAt,
    this.isActive = true,
  });

  List<String> get imageList {
    if (images == null || images!.isEmpty) return [];
    return images!.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  String? get primaryImage {
    final list = imageList;
    return list.isNotEmpty ? list.first : null;
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      artisanId: json['artisan_id'] ?? '',
      artisanName: json['artisan_name'],
      title: json['title'] ?? '',
      description: json['description'],
      category: json['category'] ?? 'Handicrafts',
      materials: json['materials'],
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      currency: json['currency'] ?? 'INR',
      quantity: json['quantity'] ?? 1,
      tags: json['tags'],
      images: json['images'],
      status: json['status'] ?? 'published',
      craftingProcess: json['crafting_process'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'artisan_id': artisanId,
      'title': title,
      'description': description,
      'category': category,
      'materials': materials,
      'price': price,
      'currency': currency,
      'quantity': quantity,
      'tags': tags,
      'images': images,
      'status': status,
      'crafting_process': craftingProcess,
    };
  }
}
