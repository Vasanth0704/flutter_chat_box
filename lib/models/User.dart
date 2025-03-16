class User {
  final String id; // ✅ Changed to String (matches Supabase user ID)
  final String name;
  final String email;
  final String phone;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String? ?? '', // ✅ Handle missing ID
      name: json['name'] as String? ?? 'Unknown',
      email: json['email'] as String? ?? 'Unknown Email',
      phone: json['phone'] as String? ?? 'Unknown Phone',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
    };
  }

  factory User.placeholder() => User(
    id: '',
    name: 'Unknown',
    email: 'Unknown Email',
    phone: 'Unknown Phone',
  );
}
