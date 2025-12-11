class Sale {
  final String id;
  final String? businessId;
  final double amount;
  final String? description;
  final DateTime date;
  final String? productId;
  final int quantity;
  final String? paymentMethod;
  final String? comments;
  final DateTime createdAt;

  Sale({
    required this.id,
    this.businessId,
    required this.amount,
    this.description,
    required this.date,
    this.productId,
    this.quantity = 1,
    this.paymentMethod,
    this.comments,
    required this.createdAt,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'],
      businessId: json['business_id'],
      amount: (json['amount'] as num).toDouble(),
      description: json['description'],
      date: DateTime.parse(json['date']),
      productId: json['product_id'],
      quantity: json['quantity'] ?? 1,
      paymentMethod: json['payment_method'],
      comments: json['comments'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'product_id': productId,
      'quantity': quantity,
      'payment_method': paymentMethod,
      'comments': comments,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
