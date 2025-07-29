import 'package:flutter/material.dart';
import 'package:construction_calculator/theme/app_colors.dart'; // color theme
import 'package:construction_calculator/screens/concrete_calculator_screen.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> buttonTitles = [
      'Concrete Calculator',
      'Lumber Calculator',
      'Paint Estimator',
      'Roofing Estimator',
      'Tile / Flooring',
      'Wall Framing',
      'Unit Converter',
      'Simple Calculator',
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Construction Calculator',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.settings, color: AppColors.textPrimary),
          onPressed: () {
            // TODO: Navigate to settings
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: AppColors.textPrimary),
            onPressed: () {
              // TODO: Open drawer or options
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
        child: Column(
          children: buttonTitles
              .map(
                (title) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18.0),
                        backgroundColor: AppColors.buttonBackground,
                        foregroundColor: AppColors.buttonText,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        if (title == 'Concrete Calculator') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ConcreteCalculatorScreen(),
                            ),
                          );
                        } else {
                          // TODO: Add other page routes later
                        }
                      },
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18.0,
                          color: AppColors.buttonText,
                        ),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
