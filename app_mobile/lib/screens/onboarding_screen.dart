import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const _hasCompletedOnboardingKey = 'hasCompletedOnboarding';

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      icon: Icons.camera_alt,
      title: 'Foto Mineral',
      description:
          'Ambil foto mineral dari jarak dekat (10-20cm) dengan pencahayaan yang terang dan merata.',
      color: const Color(0xFF1F7A8C),
    ),
    OnboardingPageData(
      icon: Icons.psychology,
      title: 'AI Menganalisa',
      description:
          'Sistem pakar berbasis AI kami akan mengidentifikasi jenis mineral secara otomatis dalam hitungan detik.',
      color: const Color(0xFF022B3A),
    ),
    OnboardingPageData(
      icon: Icons.book,
      title: 'Pelajari Detail',
      description:
          'Dapatkan informasi geologi, sifat fisik, dan kegunaan lengkap tentang mineral yang terdeteksi.',
      color: const Color(0xFF022B3A),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFE1E5F2),
            Color(0xFFBFDBF7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 24.0, bottom: 32.0),
                child: Image.asset(
                  'assets/logo_geoscan.png',
                  height: 80,
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index]);
                  },
                ),
              ),
              _buildPageIndicator(),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_currentPage < _pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.fastOutSlowIn,
                        );
                      } else {
                        await _completeOnboarding();
                      }
                    },
                    child: Text(
                      _currentPage < _pages.length - 1
                          ? 'Lanjut'
                          : 'Mulai Sekarang',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              if (_currentPage < _pages.length - 1)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: TextButton(
                    onPressed: () async {
                      await _completeOnboarding();
                    },
                    child: const Text(
                      'Lewati',
                      style: TextStyle(color: Color(0xFF1F7A8C), fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasCompletedOnboardingKey, true);

    if (!mounted) return;

    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  Widget _buildPage(OnboardingPageData page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xCCFFFFFF),
              border: Border.all(color: const Color(0xFFE1E5F2)),
              boxShadow: [
                const BoxShadow(
                  color: Color(0x33022B3A),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Icon(page.icon, size: 96, color: page.color),
          ),
          const SizedBox(height: 40),
          Text(
            page.title,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: Color(0xFF022B3A),
              letterSpacing: 0.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          Text(
            page.description,
            style: const TextStyle(
              fontSize: 18,
              color: Color(0xFF1F7A8C),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 10,
          width: _currentPage == index ? 28 : 10,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? const Color(0xFF1F7A8C)
                : const Color(0x661F7A8C),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }
}

class OnboardingPageData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const OnboardingPageData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
