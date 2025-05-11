// lib/models/post.dart
class Post {
  final int id;
  final String title;
  final List<String> imgUrl;
  final List<String> videoUrl;
  final List<String> content;
  final String createdAt;

  Post({
    required this.id,
    required this.title,
    required this.imgUrl,
    required this.videoUrl,
    required this.content,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'],
      imgUrl: List<String>.from(json['imgUrl']),
      videoUrl: List<String>.from(json['videoUrl']),
      content: List<String>.from(json['content']),
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imgUrl': imgUrl,
      'videoUrl': videoUrl,
      'content': content,
      'createdAt': createdAt,
    };
  }
}
