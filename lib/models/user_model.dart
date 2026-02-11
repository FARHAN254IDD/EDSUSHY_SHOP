import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String role;
  final bool isBlocked;
  final DateTime createdAt;
  final String? phoneNumber;
  final String? address;
  final String? fullName;
  final String? profilePhotoUrl;

  AppUser({
    required this.uid,
    required this.email,
    required this.role,
    this.isBlocked = false,
    required this.createdAt,
    this.phoneNumber,
    this.address,
    this.fullName,
    this.profilePhotoUrl,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    // Handle createdAt - can be String or Timestamp
    DateTime createdAt;
    final createdAtData = data['createdAt'];
    if (createdAtData is String) {
      createdAt = DateTime.parse(createdAtData);
    } else if (createdAtData is Timestamp) {
      createdAt = createdAtData.toDate();
    } else {
      createdAt = DateTime.now();
    }
    
    return AppUser(
      uid: uid,
      email: data['email'] ?? '',
      role: data['role'] ?? 'customer',
      isBlocked: data['isBlocked'] ?? false,
      createdAt: createdAt,
      phoneNumber: data['phoneNumber'],
      address: data['address'],
      fullName: data['fullName'],
      profilePhotoUrl: data['profilePhotoUrl'],
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
      'fullName': fullName,
      'profilePhotoUrl': profilePhotoUrl,
    };
  }
}
