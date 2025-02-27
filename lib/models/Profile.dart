class Profile {
  final int id;
  final String email;
  
  Profile({
    required this.id,
    required this.email,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    
    return Profile(
      id: json['id'],
      email: json['email']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email
    };
  }

  factory Profile.placeholder() => Profile(
    id: 0,
    email: 'Unknown Email',
  );

}