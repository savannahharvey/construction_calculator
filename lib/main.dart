import 'package:flutter/material.dart';
import 'package:construction_calculator/screens/home_screen.dart';
import 'package:construction_calculator/theme/app_colors.dart'; // color theme

void main() {
  runApp(const ConstructionCalculatorApp());
}

class ConstructionCalculatorApp extends StatelessWidget {
  const ConstructionCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Construction Calculator',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.scaffoldBackground,
        colorScheme: ColorScheme.dark(
          primary: AppColors.constructionOrange,
          surface: AppColors.surface,
          onPrimary: AppColors.textPrimary,
          onSurface: AppColors.textSecondary,
        ),
        dividerColor: AppColors.divider,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
