import 'package:flutter/foundation.dart';

enum UserRole { user, company, admin }

@immutable
class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final UserRole role;
  final String? phone;
  final String? bio;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.role = UserRole.user,
    this.phone,
    this.bio,
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  String get initials {
    if (displayName != null && displayName!.isNotEmpty) {
      final parts = displayName!.trim().split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return displayName![0].toUpperCase();
    }
    return email[0].toUpperCase();
  }

  String get firstName {
    if (displayName == null || displayName!.isEmpty) return '';
    return displayName!.trim().split(' ').first;
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String,
      displayName: map['display_name'] as String?,
      photoUrl: map['photo_url'] as String?,
      role: UserRole.values.firstWhere(
        (r) => r.name == (map['role'] as String? ?? 'user'),
        orElse: () => UserRole.user,
      ),
      phone: map['phone'] as String?,
      bio: map['bio'] as String?,
      isVerified: (map['is_verified'] as int? ?? 0) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
      'role': role.name,
      'phone': phone,
      'bio': bio,
      'is_verified': isVerified ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    UserRole? role,
    String? phone,
    String? bio,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
