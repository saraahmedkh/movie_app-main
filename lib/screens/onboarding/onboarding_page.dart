import 'package:flutter/material.dart';
import '../../core/styles/app_colors.dart';

class OnboardingModel {
  final String imagePath;
  final String title;
  final String description;

  const OnboardingModel({
    required this.imagePath,
    required this.title,
    this.description = '',
  });
}

class OnboardingPage extends StatelessWidget {
  final OnboardingModel data;

  const OnboardingPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          data.imagePath,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),

        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                AppColors.background.withValues(alpha: 0.5),
                AppColors.background,
              ],
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                data.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (data.description.isNotEmpty) ...[
                const SizedBox(height: 15),
                Text(
                  data.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ],
              const SizedBox(height: 120),
            ],
          ),
        ),
      ],
    );
  }
}
