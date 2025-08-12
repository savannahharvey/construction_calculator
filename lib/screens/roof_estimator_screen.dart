import 'dart:math';
import 'package:flutter/material.dart';
import 'package:construction_calculator/theme/app_colors.dart';

class RoofEstimatorScreen extends StatefulWidget {
  const RoofEstimatorScreen({super.key});

  @override
  State<RoofEstimatorScreen> createState() => _RoofEstimatorScreenState();
}

class _RoofEstimatorScreenState extends State<RoofEstimatorScreen> {
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _pitchRiseController = TextEditingController();
  final TextEditingController _pitchRunController = TextEditingController();
  final TextEditingController _costPerPackageController = TextEditingController();

  double? _roofArea; // total surface area
  int? _packagesNeeded;
  double? _waste; // leftover material
  double? _totalCost;

  // Shingle types and coverage per package (in sq ft)
  final Map<String, double> _shingleTypes = {
    '3-Tab Asphalt': 33.3,
    'Architectural Asphalt': 33.3,
    'Wood Shingles': 25.0,
    'Metal Panels': 50.0,
  };
  String _selectedShingle = '3-Tab Asphalt';

  void _calculateRoof() {
    final width = double.tryParse(_widthController.text);
    final length = double.tryParse(_lengthController.text);
    final rise = double.tryParse(_pitchRiseController.text);
    final run = double.tryParse(_pitchRunController.text);
    final costPerPackage = double.tryParse(_costPerPackageController.text);

    if (width == null || length == null || rise == null || run == null || costPerPackage == null) {
      setState(() {
        _roofArea = null;
        _packagesNeeded = null;
        _waste = null;
        _totalCost = null;
      });
      return;
    }

    // Calculate roof pitch multiplier = sqrt(1 + (rise/run)^2)
    final pitchMultiplier = sqrt(1 + pow(rise / run, 2));

    // Total roof surface area = footprint area * pitch multiplier * 2 (for both sides)
    final footprintArea = width * length;
    final surfaceArea = footprintArea * pitchMultiplier * 2;

    final coveragePerPackage = _shingleTypes[_selectedShingle]!;
    final packages = (surfaceArea / coveragePerPackage).ceil();
    final waste = packages * coveragePerPackage - surfaceArea;
    final totalCost = packages * costPerPackage;

    setState(() {
      _roofArea = surfaceArea;
      _packagesNeeded = packages;
      _waste = waste;
      _totalCost = totalCost;
    });
  }

  String _formatDouble(double val) => val.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Roof Estimator',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildNumberInput('Width (ft)', _widthController),
            _buildNumberInput('Length (ft)', _lengthController),
            const SizedBox(height: 12),
            const Text(
              'Roof Pitch (Rise / Run)',
              style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Row(
              children: [
                Expanded(child: _buildNumberInput('Rise (ft)', _pitchRiseController)),
                const SizedBox(width: 12),
                Expanded(child: _buildNumberInput('Run (ft)', _pitchRunController)),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedShingle,
              items: _shingleTypes.keys
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type, style: const TextStyle(color: AppColors.textPrimary)),
                      ))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedShingle = val);
              },
              dropdownColor: AppColors.surface,
              decoration: InputDecoration(
                labelText: 'Shingle Type',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.divider),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
            ),
            const SizedBox(height: 16),
            _buildNumberInput('Cost per Package (\$)', _costPerPackageController),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _calculateRoof,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.buttonBackground,
                  foregroundColor: AppColors.buttonText,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Calculate', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 30),
            if (_roofArea != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Roof Surface Area: ${_formatDouble(_roofArea!)} sq ft',
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Packages Needed: $_packagesNeeded',
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Waste (Leftover Material): ${_formatDouble(_waste!)} sq ft',
                    style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Estimated Total Cost: \$${_formatDouble(_totalCost!)}',
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberInput(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.divider),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
