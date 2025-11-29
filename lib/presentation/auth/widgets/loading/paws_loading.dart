import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class PawsLoading extends StatelessWidget {
  const PawsLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Transform.rotate(
        angle: 3.1416 / 2, // 90 degrees in radians
        child: Lottie.asset('assets/lotties/paws_walking.json'),
      ),
    );
  }
}
