class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String rollNumber;
  final String avatarUrl;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.rollNumber,
    required this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String,
        rollNumber: json['rollNumber'] as String,
        avatarUrl: json['avatarUrl'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'rollNumber': rollNumber,
        'avatarUrl': avatarUrl,
      };
}
