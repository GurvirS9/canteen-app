class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? rollNumber;
  final String avatarUrl;
  final String role;
  final String? fcmToken;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.rollNumber,
    this.avatarUrl = '',
    this.role = 'student',
    this.fcmToken,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: (json['_id'] ?? json['id'] ?? '').toString(),
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String?,
        rollNumber: json['rollNumber'] as String?,
        avatarUrl: json['avatarUrl'] as String? ?? '',
        role: json['role'] as String? ?? 'student',
        fcmToken: json['fcmToken'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        if (phone != null) 'phone': phone,
        if (rollNumber != null) 'rollNumber': rollNumber,
        'avatarUrl': avatarUrl,
        'role': role,
        if (fcmToken != null) 'fcmToken': fcmToken,
      };
}
