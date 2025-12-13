import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Ringo\'ya Hoş Geldin',
      'description':
          'Yarışmalar için ekip kurma ve projeleri tanıtmaya odaklı sosyal medya platformu.',
      'type': 'lottie',
      'path': 'assets/anim/animSplashTeamWork.json',
    },
    {
      'title': 'Takımını Kur',
      'description': 'Yarışmalar için uygun takım arkadaşları bul.',
      'type': 'icon',
      'data': Icons.rocket_launch,
    },
    {
      'title': 'Hemen Başla',
      'description':
          'Profilini oluştur, ilgi alanlarını seç ve Ringo dünyasına adım at.',
      'type': 'image',
      'path': 'assets/images/ringo_logo_tp.png',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
  }

  void _skip() {
    _pageController.animateToPage(
      _pages.length - 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _skip();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _currentPage < 2
                    ? TextButton(
                        onPressed: _skip,
                        child: const Text(
                          'Geç',
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : const SizedBox(
                        height: 48,
                      ), // Placeholder to keep layout stable
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildPageContent(page, index),
                        const SizedBox(height: 48),
                        Text(
                          page['title']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page['description']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _currentPage == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppColors.accentHighlight
                        : Colors.grey[700],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: _currentPage == 2
                  ? CustomButton(
                      text: 'Kayıt Ol',
                      onPressed: () => context.go('/register'),
                    )
                  : CustomButton(
                      text: 'İlerle',
                      onPressed: _nextPage,
                      isOutlined: true,
                      textColor: Colors.white,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageContent(Map<String, dynamic> page, int index) {
    switch (page['type']) {
      case 'lottie':
        return _OnboardingLottie(
          path: page['path'],
          isVisible: _currentPage == index,
        );
      case 'image':
        return Image.asset(
          page['path'],
          height: 75,
          fit: BoxFit.contain,
        );
      case 'icon':
        return Icon(
          page['data'],
          size: 120,
          color: AppColors.primary,
        );
      default:
        return const SizedBox(height: 120);
    }
  }
}

class _OnboardingLottie extends StatefulWidget {
  final String path;
  final bool isVisible;

  const _OnboardingLottie({
    required this.path,
    required this.isVisible,
  });

  @override
  State<_OnboardingLottie> createState() => _OnboardingLottieState();
}

class _OnboardingLottieState extends State<_OnboardingLottie>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void didUpdateWidget(covariant _OnboardingLottie oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      widget.path,
      controller: _controller,
      height: 250,
      fit: BoxFit.contain,
      repeat: false,
      onLoaded: (composition) {
        _controller.duration = composition.duration;
        if (widget.isVisible) {
          _controller.forward(from: 0);
        }
      },
    );
  }
}
