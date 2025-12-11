class Category {
  final String id;
  final String businessId;
  final String name;
  final DateTime createdAt;

  Category({
    required this.id,
    required this.businessId,
    required this.name,
    required this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      businessId: json['business_id'],
      name: json['name'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
