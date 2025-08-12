import 'package:flutter/material.dart';
import 'package:construction_calculator/theme/app_colors.dart';

class UnitConverterScreen extends StatefulWidget {
  const UnitConverterScreen({super.key});

  @override
  State<UnitConverterScreen> createState() => _UnitConverterScreenState();
}

class _UnitConverterScreenState extends State<UnitConverterScreen> {
  final TextEditingController _inputController = TextEditingController();

  final List<String> _units = [
    'feet',
    'inches',
    'yards',
    'meters',
    'centimeters',
    'millimeters',
  ];

  String _inputUnit = 'feet';
  String _outputUnit = 'meters';
  double? _convertedValue;

  final Map<String, double> _toMeters = {
    'feet': 0.3048,
    'inches': 0.0254,
    'yards': 0.9144,
    'meters': 1.0,
    'centimeters': 0.01,
    'millimeters': 0.001,
  };

  void _convert() {
    final input = double.tryParse(_inputController.text);
    if (input == null) {
      setState(() => _convertedValue = null);
      return;
    }

    final meters = input * (_toMeters[_inputUnit] ?? 1);
    final output = meters / (_toMeters[_outputUnit] ?? 1);

    setState(() {
      _convertedValue = output;
    });
  }

  String _formatDouble(double val) => val.toStringAsFixed(4);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Unit Converter',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _inputController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Value',
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.divider),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (_) => _convert(),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _inputUnit,
                    items: _units
                        .map((unit) => DropdownMenuItem(
                              value: unit,
                              child: Text(unit, style: const TextStyle(color: AppColors.textPrimary)),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _inputUnit = val);
                        _convert();
                      }
                    },
                    dropdownColor: AppColors.surface,
                    decoration: InputDecoration(
                      labelText: 'From',
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
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _outputUnit,
                    items: _units
                        .map((unit) => DropdownMenuItem(
                              value: unit,
                              child: Text(unit, style: const TextStyle(color: AppColors.textPrimary)),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _outputUnit = val);
                        _convert();
                      }
                    },
                    dropdownColor: AppColors.surface,
                    decoration: InputDecoration(
                      labelText: 'To',
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
                ),
              ],
            ),
            const SizedBox(height: 30),
            if (_convertedValue != null)
              Text(
                'Converted Value: ${_formatDouble(_convertedValue!)} $_outputUnit',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
