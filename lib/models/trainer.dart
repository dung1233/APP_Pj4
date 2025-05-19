class Trainer {
  final String id;
  final String name;
  final String specialty;
  final String experience;
  final List<String> certifications;
  final String image;
  final String description;

  Trainer({
    required this.id,
    required this.name,
    required this.specialty,
    required this.experience,
    required this.certifications,
    required this.image,
    required this.description,
  });

  factory Trainer.fromJson(Map<String, dynamic> json) {
    return Trainer(
      id: json['id'] as String,
      name: json['name'] as String,
      specialty: json['specialty'] as String,
      experience: json['experience'] as String,
      certifications: List<String>.from(json['certifications'] as List),
      image: json['image'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'experience': experience,
      'certifications': certifications,
      'image': image,
      'description': description,
    };
  }
}
