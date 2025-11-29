import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petsapp_mobile/core/constants.dart';
import 'package:petsapp_mobile/core/providers/shared_preferences_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/onboarding_slide.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  late PageController _pageController;
  int _currentPage = 0;

  final List<OnboardingSlideData> slides = [
    OnboardingSlideData(
      title: 'Meet All Your Pet Needs Here',
      description:
          'Discover services, care tips, and resources to keep your pets happy and healthy every day.',
      imagePath: 'assets/lotties/owner_dog.json',
      width: 250,
      height: 250,
      top: 320,
    ),
    OnboardingSlideData(
      title: 'Easily Manage Your Pet Activities',
      description:
          'Keep track of appointments, care routines, and important tasks for all your pets in one place.',
      imagePath: 'assets/lotties/cat_playing.json',
      width: 350,
      height: 350,
      top: 300,
    ),
    OnboardingSlideData(
      title: 'Connect and Explore Pet Services',
      description:
          'Find the right services, resources, and connections to make your pet\'s life better and easier.',
      imagePath: 'assets/lotties/adoption_dog.json',
      width: 350,
      height: 350,
      top: 300,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setBool(AppConstants.onboardingCompletedKey, true);

    if (mounted) {
      context.go('/login');
    }
  }

  void _nextPage() {
    if (_currentPage < slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Page View
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: slides.length,
            itemBuilder: (context, index) {
              return OnboardingSlide(data: slides[index]);
            },
          ),
          // Bottom indicators and button
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              children: [
                // Dots indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    slides.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: _currentPage == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? AppColors.primary
                            : AppColors.grey,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Next/Get Started button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: Size(200, 60),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    onPressed: _nextPage,
                    child: Text(
                      _currentPage == slides.length - 1
                          ? 'Get Started'
                          : 'Next',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
