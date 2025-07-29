import 'package:flutter/material.dart';
import 'package:construction_calculator/theme/app_colors.dart';

class FramingCalculatorScreen extends StatefulWidget {
  const FramingCalculatorScreen({super.key});

  @override
  State<FramingCalculatorScreen> createState() => _FramingCalculatorScreenState();
}

class _FramingCalculatorScreenState extends State<FramingCalculatorScreen> {
  final _heightController = TextEditingController();
  final _widthController = TextEditingController();
  final _lengthController = TextEditingController();
  final _panelCoverageController = TextEditingController(text: '32'); // sq ft
  final _screwsPerPanelController = TextEditingController(text: '30');

  bool includeCeiling = true;

  double totalArea = 0;
  int totalPanels = 0;
  int totalScrews = 0;

  void calculateDrywall() {
    final double? height = double.tryParse(_heightController.text);
    final double? width = double.tryParse(_widthController.text);
    final double? length = double.tryParse(_lengthController.text);
    final double? panelCoverage = double.tryParse(_panelCoverageController.text);
    final int? screwsPerPanel = int.tryParse(_screwsPerPanelController.text);

    if (height == null || width == null || length == null || panelCoverage == null || screwsPerPanel == null) {
      return;
    }

    // Wall area: 2*(height × width) + 2*(height × length)
    double wallArea = 2 * (height * width) + 2 * (height * length);
    double ceilingArea = includeCeiling ? width * length : 0;
    totalArea = wallArea + ceilingArea;

    totalPanels = (totalArea / panelCoverage).ceil();
    totalScrews = totalPanels * screwsPerPanel;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Framing Calculator', style: TextStyle(color: AppColors.textPrimary)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInputField('Room Height (ft)', _heightController),
            _buildInputField('Room Width (ft)', _widthController),
            _buildInputField('Room Length (ft)', _lengthController),
            _buildInputField('Panel Coverage (sq ft)', _panelCoverageController),
            _buildInputField('Screws per Panel', _screwsPerPanelController),
            SwitchListTile(
              value: includeCeiling,
              onChanged: (val) => setState(() => includeCeiling = val),
              title: const Text('Include Ceiling', style: TextStyle(color: AppColors.textPrimary)),
              activeColor: AppColors.accentOrange,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: calculateDrywall,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonBackground,
                foregroundColor: AppColors.buttonText,
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Calculate', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 30),
            if (totalPanels > 0) _buildResults()
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: AppColors.textPrimary),
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('📐 Total Area: ${totalArea.toStringAsFixed(2)} sq ft',
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 16)),
        Text('🧱 Panels Needed: $totalPanels',
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 16)),
        Text('🔩 Screws Needed: $totalScrews',
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 16)),
      ],
    );
  }
}
