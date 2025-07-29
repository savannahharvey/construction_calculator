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

  // Units options
  final List<String> _units = [
    'feet',
    'inches',
    'yards',
    'meters',
    'centimeters',
    'millimeters',
  ];

  // Selected unit per input
  String _lengthUnit = 'feet';
  String _widthUnit = 'feet';
  String _heightUnit = 'inches';

  double? _volumeCubicMeters; // internal base unit: meters³

  // Conversion factors to meters
  final Map<String, double> _toMeters = {
    'feet': 0.3048,
    'inches': 0.0254,
    'yards': 0.9144,
    'meters': 1.0,
    'centimeters': 0.01,
    'millimeters': 0.001,
  };

  void _calculateVolume() {
    double? length = double.tryParse(_lengthController.text);
    double? width = double.tryParse(_widthController.text);
    double? height = double.tryParse(_heightController.text);

    if (length == null || width == null || height == null) {
      setState(() {
        _volumeCubicMeters = null;
      });
      return;
    }

    // Convert each to meters
    length *= _toMeters[_lengthUnit]!;
    width *= _toMeters[_widthUnit]!;
    height *= _toMeters[_heightUnit]!;

    final volume = length * width * height; // cubic meters

    setState(() {
      _volumeCubicMeters = volume;
    });
  }

  String _formatDouble(double val) => val.toStringAsFixed(3);

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInputRow('Length', _lengthController, _lengthUnit, (val) {
              setState(() => _lengthUnit = val);
            }),
            _buildInputRow('Width', _widthController, _widthUnit, (val) {
              setState(() => _widthUnit = val);
            }),
            _buildInputRow('Height', _heightController, _heightUnit, (val) {
              setState(() => _heightUnit = val);
            }),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
            if (_volumeCubicMeters != null) _buildResults(_volumeCubicMeters!)
          ],
        ),
      ),
    );
  }

  Widget _buildInputRow(
    String label,
    TextEditingController controller,
    String selectedUnit,
    ValueChanged<String> onUnitChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
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
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              value: selectedUnit,
              items: _units
                  .map((unit) => DropdownMenuItem(
                        value: unit,
                        child: Text(unit, style: const TextStyle(color: AppColors.textPrimary)),
                      ))
                  .toList(),
              onChanged: (val) {
                if (val != null) onUnitChanged(val);
              },
              dropdownColor: AppColors.surface,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surface,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.divider),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(double volumeMeters) {
    final volumeFeet = volumeMeters / 0.0283168; // 1 cubic meter = ~35.3147 cubic feet
    final volumeYards = volumeFeet / 27;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Volume Results:',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 12),
        Text(
          '- Cubic Meters: ${_formatDouble(volumeMeters)} m³',
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
        ),
        Text(
          '- Cubic Feet: ${_formatDouble(volumeFeet)} ft³',
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
        ),
        Text(
          '- Cubic Yards: ${_formatDouble(volumeYards)} yd³',
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
        ),
      ],
    );
  }
}
