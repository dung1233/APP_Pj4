import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Sử dụng font đẹp hơn

class Wellcome extends StatefulWidget {
  const Wellcome({super.key});

  @override
  _WellcomeState createState() => _WellcomeState();
}

class _WellcomeState extends State<Wellcome>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    // Tạo animation cho progress bar
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 0.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward(); // Chạy animation khi vào màn hình
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 25, left: 22, right: 20),
      child: Container(
        width: double.infinity,
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 4),
              blurRadius: 8,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: Colors.blueAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/icons/PT.png',
                width: 50,
                height: 50,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        'Task Completion (5%/100%)',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Image.asset(
                        'assets/icons/Cup.png',
                        width: 22,
                        height: 22,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: _progressAnimation.value,
                          minHeight: 10,
                          backgroundColor: Colors.grey[300],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.blueAccent,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
