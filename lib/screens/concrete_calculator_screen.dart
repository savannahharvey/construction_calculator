import 'package:flutter/material.dart';
import 'package:construction_calculator/theme/app_colors.dart'; // color theme

class ConcreteCalculatorScreen extends StatefulWidget {
  const ConcreteCalculatorScreen({super.key});

  @override
  State<ConcreteCalculatorScreen> createState() => _ConcreteCalculatorScreenState();
}

class _ConcreteCalculatorScreenState extends State<ConcreteCalculatorScreen> {
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  String _inputUnit = 'feet'; // or 'meters'
  double? _cubicFeet;
  double? _cubicMeters;
  double? _cubicYards;

  void _calculateVolume() {
    final double? length = double.tryParse(_lengthController.text);
    final double? width = double.tryParse(_widthController.text);
    final double? height = double.tryParse(_heightController.text);

    if (length == null || width == null || height == null) {
      setState(() {
        _cubicFeet = null;
        _cubicMeters = null;
        _cubicYards = null;
      });
      return;
    }

    double volumeInCubicFeet;
    if (_inputUnit == 'feet') {
      volumeInCubicFeet = length * width * height;
    } else {
      // Convert meters³ to feet³ (1 m³ = 35.3147 ft³)
      double volumeInCubicMeters = length * width * height;
      volumeInCubicFeet = volumeInCubicMeters * 35.3147;
    }

    setState(() {
      _cubicFeet = volumeInCubicFeet;
      _cubicMeters = volumeInCubicFeet / 35.3147;
      _cubicYards = volumeInCubicFeet / 27;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Concrete Calculator',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            ToggleButtons(
              isSelected: [_inputUnit == 'feet', _inputUnit == 'meters'],
              onPressed: (int index) {
                setState(() {
                  _inputUnit = index == 0 ? 'feet' : 'meters';
                });
              },
              borderRadius: BorderRadius.circular(8),
              selectedColor: AppColors.buttonText,
              fillColor: AppColors.constructionOrange,
              color: AppColors.textSecondary,
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('Feet'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('Meters'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildInputField('Length (${_inputUnit})', _lengthController),
            _buildInputField('Width (${_inputUnit})', _widthController),
            _buildInputField('Height (${_inputUnit})', _heightController),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  backgroundColor: AppColors.buttonBackground,
                  foregroundColor: AppColors.buttonText,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _calculateVolume,
                child: const Text(
                  'Calculate Volume',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 30),
            if (_cubicFeet != null) _buildResults()
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
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

  Widget _buildResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Volume Results:',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          '- Cubic Feet: ${_cubicFeet!.toStringAsFixed(2)} ft³',
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
        ),
        Text(
          '- Cubic Meters: ${_cubicMeters!.toStringAsFixed(2)} m³',
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
        ),
        Text(
          '- Cubic Yards: ${_cubicYards!.toStringAsFixed(2)} yd³',
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
        ),
      ],
    );
  }
}
