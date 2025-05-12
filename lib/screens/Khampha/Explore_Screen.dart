import 'package:cached_network_image/cached_network_image.dart';
import 'package:training_souls/models/post.dart';
import 'package:training_souls/screens/Khampha/Eat_Screen.dart';
import 'package:training_souls/screens/Khampha/teacher_screen.dart';
import 'package:training_souls/screens/ol.dart';
import 'package:flutter/material.dart';
import 'package:training_souls/api/api_service.dart';
import 'package:dio/dio.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});
  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final ApiService _apiService = ApiService(Dio());

  // Sử dụng caching để lưu dữ liệu bài viết
  late Future<List<Post>> _postsFuture;

  @override
  void initState() {
    super.initState();
    // Tải dữ liệu bài viết một lần khi màn hình được khởi tạo
    _postsFuture = _apiService.getAllPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Discover',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: ListView(
        // Sử dụng cacheExtent để tăng hiệu suất cuộn
        cacheExtent: 500,
        children: [
          _buildSleepSection(context),
          const Padding(
            padding: EdgeInsets.all(15.0),
            child: Text(
              'Videos Nổi Bật',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ),
          _buildHotNewSection(context),
          const SizedBox(height: 15),
          const Padding(
            padding: EdgeInsets.all(15.0),
            child: Text(
              'Xây dựng Sức Mạnh',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ),
          _buildStrongSection(context),
          const Padding(
            padding: EdgeInsets.all(15.0),
            child: Text(
              'Huấn Luyện Viên Hướng Dẫn',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ),
          _buildCoachSection(context),
          // const Padding(
          //   padding: EdgeInsets.all(15.0),
          //   child: Text(
          //     'Khởi Động & Warm Up',
          //     style: TextStyle(
          //         color: Colors.black,
          //         fontSize: 20,
          //         fontWeight: FontWeight.bold),
          //   ),
          // ),
          // SizedBox(
          //   height: 200,
          //   child: ListView(
          //     scrollDirection: Axis.horizontal,
          //     children: const [
          //       WarmupCard(
          //         imagePath: 'assets/img/warmup.jpg',
          //         title: 'Làm nóng cơ thể',
          //         subtitle: 'warmup',
          //       ),
          //       WarmupCard(
          //         imagePath: 'assets/img/warmupa.jpg',
          //         title: 'Kéo giãn cơ',
          //         subtitle: 'warmup',
          //       ),
          //     ],
          //   ),
          // )
        ],
      ),
    );
  }

  Widget _buildCoachSection(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: const [
          CoachCard(
            imagePath: 'assets/img/coach.jpg',
            title: 'Huấn luyện Viên Sức Mạnh',
            subtitle: 'Satima Training',
          ),
          CoachCard(
            imagePath: 'assets/img/coachrun.jpg',
            title: 'Huấn luyện Viên Tốc Độ',
            subtitle: 'Speed Training',
          ),
          CoachCard(
            imagePath: 'assets/img/coachpush.jpg',
            title: 'Huấn luyện Viên Sức Mạnh',
            subtitle: 'Strength Training',
          ),
        ],
      ),
    );
  }

  Widget _buildStrongSection(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: const [
          StrongCard(
            imagePath: 'assets/img/strong.jpg',
            title: 'Phòng tập 1-1 sức mạnh',
            subtitle: 'Lớp bắt đầu',
          ),
          StrongCard(
            imagePath: 'assets/img/runhard.jpg',
            title: 'Phòng tập 1-1 tốc độ',
            subtitle: 'Lớp bắt đầu',
          ),
        ],
      ),
    );
  }

  Widget _buildHotNewSection(BuildContext context) {
    return SizedBox(
      height: 200,
      child: FutureBuilder<List<Post>>(
        future: _postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
                child: Text('Không thể tải bài viết: ${snapshot.error}'));
          }

          final posts = snapshot.data ?? [];

          if (posts.isEmpty) {
            return const Center(child: Text('Không có bài viết'));
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return BlogCard(
                imagePath: _getSafeImageUrl(post),
                title: post.title,
                subtitle: _getSafeContent(post),
                videoUrls: post.videoUrl,
              );
            },
          );
        },
      ),
    );
  }

  // Helper method để lấy URL ảnh an toàn
  String _getSafeImageUrl(Post post) {
    return post.imgUrl.isNotEmpty && post.imgUrl[0].isNotEmpty
        ? post.imgUrl[0]
        : 'assets/img/placeholder.jpg';
  }

  // Helper method để lấy nội dung an toàn
  String _getSafeContent(Post post) {
    return post.content.isNotEmpty ? post.content[0] : 'Không có mô tả';
  }

  Widget _buildSleepSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: SizedBox(
        height: 150,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            CategoryCard(
              imagePath: 'assets/img/veg.jpg',
              title: 'Nutrition',
              subtitle: 'Suggestion for you',
              right: 20,
              top: 50,
              titleStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
              subtitleStyle: const TextStyle(color: Colors.white, fontSize: 14),
              destination: () => EatScreen(),
            ),
            CategoryCard(
              imagePath: 'assets/img/sleepa.jpg',
              title: 'Workout',
              subtitle: 'Stay Healthy',
              right: 180,
              top: 50,
              titleStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
              subtitleStyle: const TextStyle(color: Colors.white, fontSize: 14),
              destination: () => const Ol(),
            ),
          ],
        ),
      ),
    );
  }
}

// Tối ưu với StatelessWidget thay cho các hàm widget riêng lẻ
class WarmupCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;

  const WarmupCard({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 10),
      child: GestureDetector(
        onTap: () {},
        child: Column(
          children: [
            Container(
              width: 220,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  height: 130,
                ),
              ),
            ),
            Container(
              width: 220,
              height: 70,
              padding: const EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CoachCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;

  const CoachCard({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  void _showTrainerInfoDialog(BuildContext context) {
    // Thông tin chi tiết của từng giáo viên
    Map<String, dynamic> trainerInfo = {
      'assets/img/coach.jpg': {
        'name': 'Nguyễn Văn An',
        'specialty': 'Huấn luyện viên Thể lực',
        'experience': '5 năm kinh nghiệm',
        'certifications': [
          'Chứng chỉ huấn luyện viên quốc tế',
          'Chứng chỉ dinh dưỡng thể thao',
        ],
        'achievements': [
          'Huấn luyện viên xuất sắc 2023',
          'Top 10 HLV thể lực hàng đầu',
        ],
        'description':
            'Chuyên gia về cải thiện thể lực và sức bền, có kinh nghiệm làm việc với vận động viên chuyên nghiệp.',
      },
      'assets/img/coachrun.jpg': {
        'name': 'Trần Thị Bích',
        'specialty': 'Huấn luyện viên Tốc độ',
        'experience': '4 năm kinh nghiệm',
        'certifications': [
          'Chứng chỉ huấn luyện tốc độ',
          'Chứng chỉ phục hồi chấn thương',
        ],
        'achievements': [
          'Đào tạo nhiều vận động viên chạy bộ',
          'Chuyên gia về kỹ thuật chạy',
        ],
        'description':
            'Chuyên gia về cải thiện tốc độ và kỹ thuật chạy, giúp học viên đạt được mục tiêu cá nhân.',
      },
      'assets/img/coachpush.jpg': {
        'name': 'Lê Văn Cường',
        'specialty': 'Huấn luyện viên Sức mạnh',
        'experience': '6 năm kinh nghiệm',
        'certifications': [
          'Chứng chỉ huấn luyện sức mạnh',
          'Chứng chỉ CrossFit Level 2',
        ],
        'achievements': [
          'Huấn luyện viên sức mạnh xuất sắc',
          'Top 5 HLV CrossFit',
        ],
        'description':
            'Chuyên gia về phát triển sức mạnh và cơ bắp, có kinh nghiệm với nhiều môn thể thao khác nhau.',
      },
    };

    final info = trainerInfo[imagePath] ?? {};

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      imagePath,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    info['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    info['specialty'] ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.work_history, color: Colors.orange),
                        const SizedBox(width: 10),
                        Text(
                          info['experience'] ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Chứng chỉ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...(info['certifications'] as List<String>? ?? [])
                      .map((cert) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle,
                                    color: Colors.green, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    cert,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          )),
                  const SizedBox(height: 15),
                  const Text(
                    'Thành tích',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...(info['achievements'] as List<String>? ?? [])
                      .map((achievement) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                              children: [
                                const Icon(Icons.emoji_events,
                                    color: Colors.amber, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    achievement,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          )),
                  const SizedBox(height: 15),
                  Text(
                    info['description'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VideoCallScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.video_call, color: Colors.white),
                        label: const Text('Bắt đầu học'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B00),
                          foregroundColor: Colors.white,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Đóng'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 10),
      child: GestureDetector(
        onTap: () => _showTrainerInfoDialog(context),
        child: Column(
          children: [
            Container(
              width: 220,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      height: 130,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.transparent,
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(5),
                          bottomRight: Radius.circular(5),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 220,
              height: 70,
              padding: const EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Huấn luyện viên chuyên nghiệp",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF6B00),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Nhấn để xem thông tin chi tiết",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StrongCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;

  const StrongCard({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 10),
      child: GestureDetector(
        onTap: () {
          _showTrainerCallDialog(context);
        },
        child: Column(
          children: [
            Container(
              width: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      height: 130,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.transparent,
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(5),
                          bottomRight: Radius.circular(5),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  subtitle,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.video_call,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 220,
              height: 70,
              padding: const EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Huấn luyện viên 1-1",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Nhận hướng dẫn trực tiếp từ chuyên gia",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTrainerCallDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bắt đầu buổi tập 1-1'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage('assets/img/coach.jpg'),
              ),
              const SizedBox(height: 16),
              const Text(
                'Huấn luyện viên chuyên nghiệp',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Nhận hướng dẫn trực tiếp và phản hồi tức thì',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => VideoCallScreen()));
                    },
                    icon: const Icon(Icons.video_call, color: Colors.white),
                    label: const Text('Bắt đầu'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF6B00),
                      foregroundColor: Colors.white,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Hủy'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final double right;
  final double top;
  final TextStyle titleStyle;
  final TextStyle subtitleStyle;
  final Widget Function() destination;

  const CategoryCard({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.right,
    required this.top,
    required this.titleStyle,
    required this.subtitleStyle,
    required this.destination,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => destination()));
        },
        child: Container(
          width: 270,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  height: 150,
                  width: 270,
                ),
              ),
              Positioned(
                right: right,
                top: top,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(title, style: titleStyle),
                    Text(subtitle, style: subtitleStyle),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BlogCard extends StatefulWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final List<String> videoUrls;

  const BlogCard({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.videoUrls,
  }) : super(key: key);

  @override
  State<BlogCard> createState() => _BlogCardState();
}

class _BlogCardState extends State<BlogCard>
    with AutomaticKeepAliveClientMixin {
  bool isImageLoading = false;
  bool hasError = false;
  YoutubePlayerController? _youtubeController;
  bool _isVideoInitialized = false;
  int _currentVideoIndex = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    if (widget.videoUrls.isNotEmpty) {
      // Khởi tạo Youtube Player không đồng bộ để không chặn main thread
      Future.microtask(() {
        if (mounted) {
          _initializeYoutube();
        }
      });
    }
  }

  void _initializeYoutube() {
    if (!mounted) return;

    final videoId =
        YoutubePlayer.convertUrlToId(widget.videoUrls[_currentVideoIndex]);
    if (videoId != null) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          enableCaption: true,
          forceHD: false, // Không bắt buộc HD để tránh lỗi nếu không có HD
          loop: false,
        ),
      );

      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
          isImageLoading = false;
        });
      }
    } else if (mounted) {
      setState(() {
        hasError = true;
        isImageLoading = false;
      });
    }
  }

  void _playNextVideo() {
    if (_currentVideoIndex < widget.videoUrls.length - 1) {
      _currentVideoIndex++;
      final videoId =
          YoutubePlayer.convertUrlToId(widget.videoUrls[_currentVideoIndex]);
      if (videoId != null) {
        _youtubeController?.load(videoId);
      }
    }
  }

  void _playPreviousVideo() {
    if (_currentVideoIndex > 0) {
      _currentVideoIndex--;
      final videoId =
          YoutubePlayer.convertUrlToId(widget.videoUrls[_currentVideoIndex]);
      if (videoId != null) {
        _youtubeController?.load(videoId);
      }
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 10),
      child: GestureDetector(
        onTap: () {},
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 220,
              height: 115,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Stack(
                  children: [
                    if (widget.videoUrls.isNotEmpty)
                      _buildYoutubePlayer()
                    else
                      _buildImage(),
                    if (isImageLoading)
                      const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                        ),
                      ),
                    if (widget.videoUrls.length > 1)
                      Positioned(
                        right: 5,
                        top: 5,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_currentVideoIndex + 1}/${widget.videoUrls.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Container(
              width: 220,
              constraints: const BoxConstraints(maxHeight: 85),
              padding: const EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYoutubePlayer() {
    if (!_isVideoInitialized) {
      return Container(
        height: 115,
        width: 220,
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
          ),
        ),
      );
    }

    if (hasError) {
      return Container(
        height: 115,
        width: 220,
        color: Colors.grey[300],
        child: const Center(
          child: Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 40,
          ),
        ),
      );
    }

    // Sử dụng YoutubePlayerBuilder để tối ưu hiệu suất
    return YoutubePlayer(
      controller: _youtubeController!,
      showVideoProgressIndicator: true,
      progressIndicatorColor: Colors.red,
      progressColors: const ProgressBarColors(
        playedColor: Colors.red,
        handleColor: Colors.redAccent,
      ),
      onReady: () {
        if (mounted) {
          setState(() {
            isImageLoading = false;
          });
        }
      },
      onEnded: (data) {
        _youtubeController?.pause();
        if (_currentVideoIndex < widget.videoUrls.length - 1) {
          _playNextVideo();
        }
      },
      bottomActions: [
        if (widget.videoUrls.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous,
                    color: Colors.white, size: 20),
                onPressed: _currentVideoIndex > 0 ? _playPreviousVideo : null,
              ),
              const SizedBox(width: 20),
              IconButton(
                icon:
                    const Icon(Icons.skip_next, color: Colors.white, size: 20),
                onPressed: _currentVideoIndex < widget.videoUrls.length - 1
                    ? _playNextVideo
                    : null,
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildImage() {
    if (widget.imagePath.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: widget.imagePath,
        fit: BoxFit.cover,
        height: 115,
        width: 220,
        // Sử dụng memCacheWidth và memCacheHeight để giảm bộ nhớ
        memCacheWidth: 220,
        memCacheHeight: 115,
        fadeInDuration: const Duration(milliseconds: 200),
        placeholder: (context, url) => Container(
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
              strokeWidth: 2,
            ),
          ),
        ),
        errorWidget: (context, url, error) {
          return Container(
            height: 115,
            width: 220,
            color: Colors.grey[300],
            child: const Center(
              child: Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 40,
              ),
            ),
          );
        },
      );
    } else {
      return Image.asset(
        widget.imagePath,
        fit: BoxFit.cover,
        height: 115,
        width: 220,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 115,
            width: 220,
            color: Colors.grey[300],
            child: const Center(
              child: Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 40,
              ),
            ),
          );
        },
      );
    }
  }
}
