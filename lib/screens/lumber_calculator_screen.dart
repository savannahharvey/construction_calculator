import 'package:flutter/material.dart';
import 'package:construction_calculator/theme/app_colors.dart';

class LumberCalculatorScreen extends StatefulWidget {
  const LumberCalculatorScreen({super.key});

  @override
  State<LumberCalculatorScreen> createState() => _LumberCalculatorScreenState();
}

class _LumberCalculatorScreenState extends State<LumberCalculatorScreen> {
  final TextEditingController _boardWidthController = TextEditingController();
  final TextEditingController _boardThicknessController = TextEditingController();
  final TextEditingController _areaToCoverWidthController = TextEditingController();

  String? _selectedLumberSize;
  int totalNumberOfBoards = 0;
  double totalWaste = 0.0;

  final List<String> predefinedSizes = ['2x4', '2x6', '2x8', '2x10', '2x12'];

  void _applyPredefinedSize(String? size) {
    switch (size) {
      case '2x4':
        _boardWidthController.text = '3.5';
        _boardThicknessController.text = '1.5';
        break;
      case '2x6':
        _boardWidthController.text = '5.5';
        _boardThicknessController.text = '1.5';
        break;
      case '2x8':
        _boardWidthController.text = '7.25';
        _boardThicknessController.text = '1.5';
        break;
      case '2x10':
        _boardWidthController.text = '9.25';
        _boardThicknessController.text = '1.5';
        break;
      case '2x12':
        _boardWidthController.text = '11.25';
        _boardThicknessController.text = '1.5';
        break;
    }
  }

  void _calculate() {
    final double width = double.tryParse(_boardWidthController.text) ?? 0.0;
    final double areaToCoverWidth = double.tryParse(_areaToCoverWidthController.text) ?? 0.0;

    final totalNumBoards = (areaToCoverWidth / width).ceil();
    final wastePercentage = (areaToCoverWidth / (width)).ceil() - (areaToCoverWidth / (width));

    setState(() {
      totalNumberOfBoards = totalNumBoards;
      totalWaste = wastePercentage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Lumber Calculator',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: BackButton(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              dropdownColor: AppColors.surface,
              decoration: const InputDecoration(
                labelText: 'Predefined Lumber Size',
                labelStyle: TextStyle(color: AppColors.textSecondary),
              ),
              value: _selectedLumberSize,
              items: predefinedSizes
                  .map((size) => DropdownMenuItem(
                        value: size,
                        child: Text(size, style: const TextStyle(color: AppColors.textPrimary)),
                      ))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _selectedLumberSize = val;
                  _applyPredefinedSize(val);
                });
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(_boardWidthController, 'Board Width (inches)'),
            _buildTextField(_boardThicknessController, 'Board Thickness (inches)'),
            _buildTextField(_areaToCoverWidthController, 'Total Width to Cover (sq ft)'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _calculate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonBackground,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 50),
              ),
              child: const Text('Calculate', style: TextStyle(fontSize: 18, color: AppColors.buttonText)),
            ),
            const SizedBox(height: 24),
            Text(
              'Total Boards Required: ${totalNumberOfBoards.toStringAsFixed(2)}',
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Total Waste Percentage: ${totalWaste.toStringAsFixed(2)}',
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
