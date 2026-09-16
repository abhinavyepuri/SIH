class Order {
  final String id;
  final String customerName;
  final String? customerEmail;
  final String productId;
  final String productTitle;
  final String artisanId;
  final int quantity;
  final double price;
  final String status; // 'pending', 'confirmed', 'shipped', 'delivered', 'cancelled'
  final DateTime? createdAt;
  final bool isActive;

  Order({
    required this.id,
    required this.customerName,
    this.customerEmail,
    required this.productId,
    required this.productTitle,
    required this.artisanId,
    required this.quantity,
    required this.price,
    this.status = 'pending',
    this.createdAt,
    this.isActive = true,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? '',
      customerName: json['customer_name'] ?? '',
      customerEmail: json['customer_email'],
      productId: json['product_id'] ?? '',
      productTitle: json['product_title'] ?? '',
      artisanId: json['artisan_id'] ?? '',
      quantity: json['quantity'] ?? 1,
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_name': customerName,
      'customer_email': customerEmail,
      'product_id': productId,
      'product_title': productTitle,
      'artisan_id': artisanId,
      'quantity': quantity,
      'price': price,
      'status': status,
    };
  }
}
