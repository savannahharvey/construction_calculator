import 'package:flutter/material.dart';
import 'dart:math';
import 'package:construction_calculator/theme/app_colors.dart';

class PaintEstimatorScreen extends StatefulWidget {
  const PaintEstimatorScreen({super.key});

  @override
  State<PaintEstimatorScreen> createState() => _PaintEstimatorScreenState();
}

class _PaintEstimatorScreenState extends State<PaintEstimatorScreen> {
  // Room dimensions
  final TextEditingController lengthFtController = TextEditingController();
  final TextEditingController lengthInController = TextEditingController();
  final TextEditingController widthFtController = TextEditingController();
  final TextEditingController widthInController = TextEditingController();
  final TextEditingController heightFtController = TextEditingController();
  final TextEditingController heightInController = TextEditingController();

  // Paint and feature details
  final TextEditingController coatsController = TextEditingController(text: '1');
  final TextEditingController coverageController = TextEditingController(text: '350');

  final TextEditingController numDoorsController = TextEditingController(text: '0');
  final TextEditingController numWindowsController = TextEditingController(text: '0');
  final TextEditingController doorAreaController = TextEditingController(text: '21'); // default 3ft x 7ft
  final TextEditingController windowAreaController = TextEditingController(text: '12'); // default 3ft x 4ft

  bool includeCeiling = false;

  double? totalArea;
  double? totalGallons;
  double? leftoverSqFt;
  String? leftoverText;

  void calculatePaint() {
    double toFeet(String ftText, String inText) {
      final ft = double.tryParse(ftText) ?? 0;
      final inches = double.tryParse(inText) ?? 0;
      return ft + inches / 12;
    }

    final length = toFeet(lengthFtController.text, lengthInController.text);
    final width = toFeet(widthFtController.text, widthInController.text);
    final height = toFeet(heightFtController.text, heightInController.text);

    final numCoats = int.tryParse(coatsController.text) ?? 1;
    final coveragePerGallon = double.tryParse(coverageController.text) ?? 350;

    final numDoors = int.tryParse(numDoorsController.text) ?? 0;
    final numWindows = int.tryParse(numWindowsController.text) ?? 0;
    final doorArea = double.tryParse(doorAreaController.text) ?? 0;
    final windowArea = double.tryParse(windowAreaController.text) ?? 0;

    double wallArea = 2 * (length * height) + 2 * (width * height);
    double ceilingArea = includeCeiling ? (length * width) : 0;
    double excludedArea = (numDoors * doorArea) + (numWindows * windowArea);

    final totalPaintArea = max((wallArea + ceilingArea - excludedArea), 0.0) * numCoats;
    final gallonsNeeded = (totalPaintArea / coveragePerGallon).ceilToDouble();
    final leftoverPaint = max((gallonsNeeded * coveragePerGallon) - totalPaintArea, 0.0);

    setState(() {
      totalArea = totalPaintArea;
      totalGallons = gallonsNeeded;
      leftoverSqFt = leftoverPaint;
      leftoverText = formatLeftoverGallons(leftoverPaint, coveragePerGallon);
    });
  }

  // Helper method to format leftover gallons
  String formatLeftoverGallons(double leftoverSqFt, double coveragePerGallon) {
    double fraction = leftoverSqFt / coveragePerGallon;

    if (fraction < 0.125) return "Less than 1/8 gallon";
    if ((fraction - 0.25).abs() < 0.1) return "0.25 gallons (~${(coveragePerGallon * 0.25).toStringAsFixed(1)} sq ft)";
    if ((fraction - 0.33).abs() < 0.1) return "1/3 gallon (~${(coveragePerGallon * 0.33).toStringAsFixed(1)} sq ft)";
    if ((fraction - 0.5).abs() < 0.1) return "0.5 gallons (~${(coveragePerGallon * 0.5).toStringAsFixed(1)} sq ft)";
    if ((fraction - 0.75).abs() < 0.1) return "0.75 gallons (~${(coveragePerGallon * 0.75).toStringAsFixed(1)} sq ft)";
    if (fraction < 1) {
      return "${fraction.toStringAsFixed(2)} gallons (~${leftoverSqFt.toStringAsFixed(1)} sq ft)";
    }

    return "${fraction.toStringAsFixed(2)} gallons (~${leftoverSqFt.toStringAsFixed(1)} sq ft)";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Paint Estimator',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Room Dimensions", style: TextStyle(color: AppColors.textPrimary, fontSize: 18)),
            const SizedBox(height: 8),
            _buildDimensionRow("Length", lengthFtController, lengthInController),
            _buildDimensionRow("Width", widthFtController, widthInController),
            _buildDimensionRow("Height", heightFtController, heightInController),
            const SizedBox(height: 16),

            const Text("Paint Details", style: TextStyle(color: AppColors.textPrimary, fontSize: 18)),
            const SizedBox(height: 8),
            _buildTextField("Number of Coats", coatsController),
            _buildTextField("Coverage per Gallon (sq ft)", coverageController),
            const SizedBox(height: 16),

            const Text("Excluded Areas", style: TextStyle(color: AppColors.textPrimary, fontSize: 18)),
            const SizedBox(height: 8),
            _buildTextField("Number of Doors", numDoorsController),
            _buildTextField("Area per Door (sq ft)", doorAreaController),
            _buildTextField("Number of Windows", numWindowsController),
            _buildTextField("Area per Window (sq ft)", windowAreaController),

            SwitchListTile(
              title: const Text("Include Ceiling?", style: TextStyle(color: AppColors.textPrimary)),
              value: includeCeiling,
              activeColor: AppColors.constructionOrange,
              onChanged: (val) => setState(() => includeCeiling = val),
            ),
            const SizedBox(height: 20),

            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonBackground,
                  foregroundColor: AppColors.buttonText,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                ),
                onPressed: calculatePaint,
                child: const Text("Calculate Paint", style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 24),

            if (totalArea != null && totalGallons != null && leftoverSqFt != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Total Area to Paint: ${totalArea!.toStringAsFixed(2)} sq ft",
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text("Gallons of Paint Needed: ${totalGallons!.toStringAsFixed(0)}",
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text("Approximate Paint Leftover: $leftoverText",
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: AppColors.textPrimary),
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

  Widget _buildDimensionRow(String label, TextEditingController ftCtrl, TextEditingController inCtrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          ),
          Expanded(
            flex: 3,
            child: _buildLabeledField("ft", ftCtrl),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: _buildLabeledField("in", inCtrl),
          ),
        ],
      ),
    );
  }

  Widget _buildLabeledField(String unit, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        prefixText: '$unit ',
        prefixStyle: const TextStyle(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
