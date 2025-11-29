import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../core/theme/app_colors.dart';

class OnboardingSlideData {
  final String title;
  final String description;
  final String imagePath;
  final double? width;
  final double? height;
  final double? top;

  OnboardingSlideData({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.width,
    required this.height,
    required this.top,
  });
}

class OnboardingSlide extends StatelessWidget {
  final OnboardingSlideData data;

  const OnboardingSlide({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          // Title at top-left
          Positioned(
            top: 60,
            left: 24,
            right: 24,
            child: Text(
              data.title,
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w700),
            ),
          ),

          // Centered image
          Positioned(
            top: data.top,
            left: 0,
            right: 0,
            child: Center(
              child: Lottie.asset(
                data.imagePath, // make sure this is a .json file in assets
                width: data.width,
                height: data.height,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Description at bottom
          Positioned(
            left: 24,
            right: 24,
            bottom: 200,
            child: Text(
              data.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
