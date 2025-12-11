class Profile {
  final String id;
  final String role; // 'owner', 'employee', 'superadmin'
  final String businessId;
  final String? fullName;
  final String? phone;
  final DateTime createdAt;

  Profile({
    required this.id,
    required this.role,
    required this.businessId,
    this.fullName,
    this.phone,
    required this.createdAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      role: json['role'],
      businessId: json['business_id'],
      fullName: json['full_name'],
      phone: json['phone'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'business_id': businessId,
      'full_name': fullName,
      'phone': phone,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
