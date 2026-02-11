class AppUser {
  final String uid;
  final String email;
  final String role;
  final bool isBlocked;
  final DateTime createdAt;
  final String? phoneNumber;
  final String? address;

  AppUser({
    required this.uid,
    required this.email,
    required this.role,
    this.isBlocked = false,
    required this.createdAt,
    this.phoneNumber,
    this.address,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      email: data['email'] ?? '',
      role: data['role'] ?? 'customer',
      isBlocked: data['isBlocked'] ?? false,
      createdAt: data['createdAt'] != null 
          ? DateTime.parse(data['createdAt']) 
          : DateTime.now(),
      phoneNumber: data['phoneNumber'],
      address: data['address'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': role,
      'isBlocked': isBlocked,
      'createdAt': createdAt.toIso8601String(),
      'phoneNumber': phoneNumber,
      'address': address,
    };
  }
}
