import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PremiumRequiredPopup extends StatelessWidget {
  final VoidCallback onBuyPremium;
  const PremiumRequiredPopup({super.key, required this.onBuyPremium});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Chặn back
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.7),
        body: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Material(
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Banner gradient header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 25),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFFF6F00), Color(0xFFFF6F00)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.workspace_premium,
                            color: Colors.white,
                            size: 48,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Hết 1 tuần trải nghiệm Premium',
                            style: GoogleFonts.urbanist(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Text(
                            'Bạn đã hết 1 tuần trải nghiệm miễn phí Premium. Để tiếp tục sử dụng các tính năng nâng cao như tư vấn dinh dưỡng, bạn cần nâng cấp tài khoản Premium.',
                            style: GoogleFonts.urbanist(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: _buildFeatureItem(
                                  Icons.restaurant_menu,
                                  'Thực đơn chi tiết',
                                ),
                              ),
                              Expanded(
                                child: _buildFeatureItem(
                                  Icons.timer,
                                  'Lịch ăn uống',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildFeatureItem(
                                  Icons.health_and_safety,
                                  'Dinh dưỡng cân bằng',
                                ),
                              ),
                              Expanded(
                                child: _buildFeatureItem(
                                  Icons.trending_up,
                                  'Theo dõi tiến độ',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: onBuyPremium,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6F00),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: Text(
                              'Nâng cấp Premium',
                              style: GoogleFonts.urbanist(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Bạn không thể tiếp tục sử dụng ứng dụng nếu không nâng cấp Premium.',
                            style: GoogleFonts.urbanist(
                              fontSize: 14,
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Column(
      children: [
        Icon(
          icon,
          color: const Color(0xFFFF6F00),
          size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: GoogleFonts.urbanist(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
