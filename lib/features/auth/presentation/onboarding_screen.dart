import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

  final List<Map<String, String>> _pages = [
    {
      'title': 'Ringo\'ya Hoş Geldin',
      'description': 'Yarışma ve ekip kurma odaklı sosyal medya platformu.',
      'icon': 'rocket_launch',
    },
    {
      'title': 'Takımını Kur',
      'description':
          'Yeteneklerine uygun takım arkadaşları bul ve yarışmalara katıl.',
      'icon': 'groups',
    },
    {
      'title': 'Hemen Başla',
      'description':
          'Profilini oluştur, ilgi alanlarını seç ve Ringo dünyasına adım at.',
      'icon': 'verified_user',
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
    context.go('/login');
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
                        Icon(
                          _getIconData(page['icon']!),
                          size: 120,
                          color: AppColors.primary,
                        ),
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

  IconData _getIconData(String name) {
    switch (name) {
      case 'rocket_launch':
        return Icons.rocket_launch;
      case 'groups':
        return Icons.groups;
      case 'verified_user':
        return Icons.verified_user;
      default:
        return Icons.circle;
    }
  }
}
