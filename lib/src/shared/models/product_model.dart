class Product {
  final String id;
  final String? businessId;
  final String name;
  final int stock;
  final double price;
  final String? barcode;
  final String? categoryId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    this.businessId,
    required this.name,
    required this.stock,
    required this.price,
    this.barcode,
    this.categoryId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      businessId: json['business_id'],
      name: json['name'],
      stock: json['stock'],
      price: (json['price'] as num).toDouble(),
      barcode: json['barcode'],
      categoryId: json['category_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'name': name,
      'stock': stock,
      'price': price,
      'barcode': barcode,
      'category_id': categoryId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
