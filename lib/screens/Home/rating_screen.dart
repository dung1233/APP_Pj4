import 'package:flutter/material.dart';
import 'package:training_souls/models/student_model.dart';
import 'package:training_souls/services/student_service.dart';
import 'dart:math' as math;

class RatingScreen extends StatefulWidget {
  final Student student;

  const RatingScreen({
    super.key,
    required this.student,
  });

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  final _studentService = StudentService();
  bool _isLoading = false;

  // Ratings
  double _strengthRating = 0;
  double _speedRating = 0;
  double _staminaRating = 0;
  double _enduranceRating = 0;

  @override
  void initState() {
    super.initState();
    print('Student ID: ${widget.student.id}'); // Print student ID
    print('Student Name: ${widget.student.name}'); // Print student name
  }

  Future<void> _confirmLevelUp() async {
    if (widget.student.id == null || widget.student.id.isEmpty) {
      _showErrorSnackBar('Không tìm thấy ID học viên');
      return;
    }

    // Validate that all ratings have been submitted
    if (_strengthRating == 0 ||
        _speedRating == 0 ||
        _staminaRating == 0 ||
        _enduranceRating == 0) {
      _showErrorSnackBar(
          'Vui lòng đánh giá tất cả các tiêu chí trước khi xác nhận');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Here you would typically send the ratings along with the level up confirmation
      // This depends on your StudentService implementation
      final success = await _studentService.confirmLevelUp(widget.student.id);

      if (success && mounted) {
        _showSuccessSnackBar('Xác nhận lên cấp thành công');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Lỗi: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác nhận lên cấp'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildStudentInfoCard(),
                const SizedBox(height: 20),
                _buildRatingSection(),
                const SizedBox(height: 20),
                _buildConfirmationMessage(),
                const SizedBox(height: 30),
                _buildActionButtons(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentInfoCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(0xFFE6F7F2),
                  child: Icon(
                    Icons.person,
                    size: 32,
                    color: Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.student.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${widget.student.id}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildInfoItem(
                    'Cấp hiện tại', '${widget.student.level ?? "N/A"}'),
                // _buildInfoItem('Cấp mới', '${(widget.student.level ?? 0) + 1}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Đánh giá tiêu chí',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildRatingItem(
              'Sức mạnh',
              _strengthRating,
              Icons.fitness_center,
              Colors.red.shade700,
              (rating) {
                setState(() {
                  _strengthRating = rating;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildRatingItem(
              'Tốc độ',
              _speedRating,
              Icons.speed,
              Colors.blue.shade700,
              (rating) {
                setState(() {
                  _speedRating = rating;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildRatingItem(
              'Thể lực',
              _staminaRating,
              Icons.directions_run,
              Colors.green.shade700,
              (rating) {
                setState(() {
                  _staminaRating = rating;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildRatingItem(
              'Sức bền',
              _enduranceRating,
              Icons.timer,
              Colors.orange.shade700,
              (rating) {
                setState(() {
                  _enduranceRating = rating;
                });
              },
            ),
            const SizedBox(height: 20),
            _buildOverallRating(),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingItem(String title, double rating, IconData icon,
      Color color, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              rating.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: color,
                  inactiveTrackColor: color.withOpacity(0.2),
                  thumbColor: color,
                  overlayColor: color.withOpacity(0.3),
                  trackHeight: 4.0,
                ),
                child: Slider(
                  value: rating,
                  min: 0,
                  max: 10,
                  divisions: 20,
                  onChanged: onChanged,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOverallRating() {
    final avgRating =
        (_strengthRating + _speedRating + _staminaRating + _enduranceRating) /
            4;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          const Text(
            'Đánh giá tổng thể',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                avgRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF10B981),
                ),
              ),
              const Text(
                '/10',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildRatingStars(avgRating),
        ],
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        double starValue = math.min(1, math.max(0, rating / 2 - index));
        return _buildStar(starValue);
      }),
    );
  }

  Widget _buildStar(double value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (bounds) {
          return LinearGradient(
            stops: [0, value, value],
            colors: const [
              Color(0xFF10B981),
              Color(0xFF10B981),
              Colors.grey,
            ],
          ).createShader(bounds);
        },
        child: const Icon(
          Icons.star,
          size: 28,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildConfirmationMessage() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFFF9FAFB),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F7F2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.info_outline,
                color: Color(0xFF10B981),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'Xác nhận lên cấp cho học viên này? Hành động này không thể hoàn tác sau khi xác nhận.',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Hủy',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _confirmLevelUp,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_outline),
                      SizedBox(width: 8),
                      Text(
                        'Xác nhận lên cấp',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

Widget _buildInfoItem(String label, String value) {
  return Column(
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      const SizedBox(height: 4),
      Text(
        value,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Color(0xFF10B981),
        ),
      ),
    ],
  );
}
