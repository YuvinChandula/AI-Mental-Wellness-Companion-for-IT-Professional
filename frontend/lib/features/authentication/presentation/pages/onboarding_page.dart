import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../shared/widgets/app_button.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> _slides = <Map<String, String>>[
    <String, String>{
      'title': 'Track Moods & Habits',
      'description': 'Log sleep, stress levels, steps, and hydration seamlessly every day to build a mental wellness timeline.',
      'icon': 'self_improvement_rounded',
    },
    <String, String>{
      'title': 'Predict Burnout Risks',
      'description': 'Our Random Forest predictive model analyzes lifestyle patterns, alerting you before burnout triggers.',
      'icon': 'analytics_rounded',
    },
    <String, String>{
      'title': 'Personalized AI Coach',
      'description': 'Chat with our Gemini-powered wellness assistant to get personalized boundaries advice and mindfulness support.',
      'icon': 'chat_rounded',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: const Text('Skip'),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (int index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemCount: _slides.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Map<String, String> slide = _slides[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          _getIconData(slide['icon']!),
                          size: 100,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 40),
                        Text(
                          slide['title']!,
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          slide['description']!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(
                  _slides.length,
                  (int index) => _buildIndicator(index, theme),
                ),
              ),
              const SizedBox(height: 40),
              AppButton(
                text: _currentIndex == _slides.length - 1 ? 'Get Started' : 'Next',
                onPressed: () {
                  if (_currentIndex == _slides.length - 1) {
                    _completeOnboarding();
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator(int index, ThemeData theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: _currentIndex == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentIndex == index ? theme.colorScheme.primary : Colors.grey.withOpacity(0.5),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
    );
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'analytics_rounded':
        return Icons.analytics_rounded;
      case 'chat_rounded':
        return Icons.chat_rounded;
      default:
        return Icons.self_improvement_rounded;
    }
  }

  void _completeOnboarding() {
    StorageService.setOnboardingCompleted(true);
    context.go(AppRouter.login);
  }
}
