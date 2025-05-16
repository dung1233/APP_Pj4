class Student {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String profileImage;
  final String level;
  final double overallRating;

  Student({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.profileImage,
    required this.level,
    required this.overallRating,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      profileImage: json['profileImage'] ?? '',
      level: json['level'] ?? 'Beginner',
      overallRating: (json['overallRating'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'level': level,
      'overallRating': overallRating,
    };
  }
}
