import 'package:flutter/material.dart';
import 'package:construction_calculator/theme/app_colors.dart'; // color theme
import 'dart:math';

class RoofEstimatorScreen extends StatefulWidget {
  const RoofEstimatorScreen({super.key});

  @override
  State<RoofEstimatorScreen> createState() => _RoofEstimatorScreenState();
}

class _RoofEstimatorScreenState extends State<RoofEstimatorScreen> {
  final _lengthFtController = TextEditingController();
  final _lengthInController = TextEditingController();
  final _widthFtController = TextEditingController();
  final _widthInController = TextEditingController();
  final _wasteController = TextEditingController(text: "10");
  final _coveragePerPackageController = TextEditingController(text: "33.3"); // typical bundle coverage

  String _selectedPitch = "4/12";
  String _selectedShingleType = "Asphalt";

  double? surfaceArea;
  double? materialNeededBeforeWaste;
  double? materialNeededAfterWaste;
  int? totalPackages;
  double? leftoverSqFt;

  final List<String> _pitchOptions = ["3/12", "4/12", "5/12", "6/12", "8/12", "10/12", "12/12"];
  final List<String> _shingleTypes = ["Asphalt", "Architectural", "Metal", "Wood Shake"];

  double pitchMultiplier(String pitch) {
    // Convert pitch like "6/12" to multiplier
    var split = pitch.split("/");
    double rise = double.tryParse(split[0]) ?? 0;
    double run = double.tryParse(split[1]) ?? 12;
    double slope = sqrt(pow(rise, 2) + pow(run, 2)) / run;
    return slope;
  }

  void calculateRoof() {
    double lengthFt = double.tryParse(_lengthFtController.text) ?? 0;
    double lengthIn = double.tryParse(_lengthInController.text) ?? 0;
    double widthFt = double.tryParse(_widthFtController.text) ?? 0;
    double widthIn = double.tryParse(_widthInController.text) ?? 0;
    double wastePercent = double.tryParse(_wasteController.text) ?? 0;
    double coveragePerPackage = double.tryParse(_coveragePerPackageController.text) ?? 1;

    // Convert everything to feet
    double totalLengthFt = lengthFt + (lengthIn / 12);
    double totalWidthFt = widthFt + (widthIn / 12);

    // Base area (2 sides of roof)
    double baseArea = totalLengthFt * totalWidthFt * 2;

    // Adjust for pitch
    double multiplier = pitchMultiplier(_selectedPitch);
    double adjustedArea = baseArea * multiplier;

    // Material needed before and after waste
    double neededBeforeWaste = adjustedArea;
    double neededAfterWaste = adjustedArea * (1 + wastePercent / 100);

    // Packages needed
    int packages = (neededAfterWaste / coveragePerPackage).ceil();

    // Leftover material
    double leftover = (packages * coveragePerPackage) - neededAfterWaste;

    setState(() {
      surfaceArea = adjustedArea;
      materialNeededBeforeWaste = neededBeforeWaste;
      materialNeededAfterWaste = neededAfterWaste;
      totalPackages = packages;
      leftoverSqFt = leftover;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Roof Estimator"),
        backgroundColor: AppColors.scaffoldBackground,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Roof Dimensions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(child: _buildNumberField(_lengthFtController, "Length (ft)")),
                const SizedBox(width: 8),
                Expanded(child: _buildNumberField(_lengthInController, "Length (in)")),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildNumberField(_widthFtController, "Width (ft)")),
                const SizedBox(width: 8),
                Expanded(child: _buildNumberField(_widthInController, "Width (in)")),
              ],
            ),
            const SizedBox(height: 16),

            const Text("Roof Pitch", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButtonFormField<String>(
              value: _selectedPitch,
              items: _pitchOptions.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
              onChanged: (value) => setState(() => _selectedPitch = value!),
            ),
            const SizedBox(height: 16),

            const Text("Shingle Type", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButtonFormField<String>(
              value: _selectedShingleType,
              items: _shingleTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (value) => setState(() => _selectedShingleType = value!),
            ),
            const SizedBox(height: 16),

            _buildNumberField(_wasteController, "Waste %"),
            const SizedBox(height: 8),
            _buildNumberField(_coveragePerPackageController, "Coverage per Package (sq ft)"),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.constructionOrange),
                onPressed: calculateRoof,
                child: const Text("Calculate", style: TextStyle(color: Colors.white)),
              ),
            ),

            const SizedBox(height: 24),
            if (surfaceArea != null) ...[
              _buildResultRow("Roof Surface Area:", "${surfaceArea!.toStringAsFixed(2)} sq ft"),
              _buildResultRow("Material Needed (no waste):", "${materialNeededBeforeWaste!.toStringAsFixed(2)} sq ft"),
              _buildResultRow("Material Needed (with waste):", "${materialNeededAfterWaste!.toStringAsFixed(2)} sq ft"),
              _buildResultRow("Total Packages Needed:", "$totalPackages"),
              _buildResultRow("Estimated Leftover Material:", "${leftoverSqFt!.toStringAsFixed(2)} sq ft"),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildNumberField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
