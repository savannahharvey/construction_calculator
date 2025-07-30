import 'package:flutter/material.dart';
import 'package:construction_calculator/theme/app_colors.dart'; // color theme

class ConcreteCalculatorScreen extends StatefulWidget {
  const ConcreteCalculatorScreen({super.key});

  @override
  State<ConcreteCalculatorScreen> createState() => _ConcreteCalculatorScreenState();
}

class _ConcreteCalculatorScreenState extends State<ConcreteCalculatorScreen> {
  final TextEditingController _lengthFeetController = TextEditingController();
  final TextEditingController _lengthInchesController = TextEditingController();
  final TextEditingController _widthFeetController = TextEditingController();
  final TextEditingController _widthInchesController = TextEditingController();
  final TextEditingController _heightFeetController = TextEditingController();
  final TextEditingController _heightInchesController = TextEditingController();


  // Ordered amount input
  final TextEditingController _orderedAmountController = TextEditingController();
  String _orderedUnit = 'cubic yards';

  double? _volumeCubicMeters; // internal base unit: meters³

  void _calculateVolume() {
    double? lengthFeet = double.tryParse(_lengthFeetController.text) ?? 0;
    double? lengthInches = double.tryParse(_lengthInchesController.text) ?? 0;
    double? widthFeet = double.tryParse(_widthFeetController.text) ?? 0;
    double? widthInches = double.tryParse(_widthInchesController.text) ?? 0;
    double? heightFeet = double.tryParse(_heightFeetController.text) ?? 0;
    double? heightInches = double.tryParse(_heightInchesController.text) ?? 0;

    // Convert total inches to feet, then to meters
    final lengthMeters = ((lengthFeet + (lengthInches / 12)) * 0.3048);
    final widthMeters = ((widthFeet + (widthInches / 12)) * 0.3048);
    final heightMeters = ((heightFeet + (heightInches / 12)) * 0.3048);

    final volume = lengthMeters * widthMeters * heightMeters;

    setState(() {
      _volumeCubicMeters = volume;
    });
  }


  final List<Map<String, dynamic>> _manualVolumes = [];

  String _manualUnit = 'cubic yards';
  final _manualVolumeController = TextEditingController();

  final List<String> _volumeUnits = ['cubic meters', 'cubic feet', 'cubic yards'];

  // Convert from any volume unit to cubic meters
  double _convertToCubicMeters(double value, String unit) {
    switch (unit) {
      case 'cubic feet':
        return value * 0.0283168;
      case 'cubic yards':
        return value * 0.764555;
      case 'cubic meters':
      default:
        return value;
    }
  }

  void _addManualVolume() {
    final val = double.tryParse(_manualVolumeController.text);
    if (val != null && val > 0) {
      setState(() {
        _manualVolumes.add({'value': val, 'unit': _manualUnit});
        _manualVolumeController.clear();
      });
    }
  }

  void _removeManualVolume(int index) {
    setState(() {
      _manualVolumes.removeAt(index);
    });
  }

  double _getManualVolumeMeters() {
    return _manualVolumes.fold(
      0.0,
      (sum, entry) => sum + _convertToCubicMeters(entry['value'], entry['unit']),
    );
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
            _buildFeetInchesInputRow('Length', _lengthFeetController, _lengthInchesController),
            _buildFeetInchesInputRow('Width', _widthFeetController, _widthInchesController),
            _buildFeetInchesInputRow('Height', _heightFeetController, _heightInchesController),
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
            if (_volumeCubicMeters != null) _buildResults(_volumeCubicMeters!),
            
            const SizedBox(height: 30),
            const Text(
              'Manual Volume Entries:',
              style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _manualVolumeController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Volume',
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
                    value: _manualUnit,
                    items: _volumeUnits
                        .map((unit) => DropdownMenuItem(
                              value: unit,
                              child: Text(unit, style: const TextStyle(color: AppColors.textPrimary)),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _manualUnit = val);
                    },
                    dropdownColor: AppColors.surface,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: AppColors.divider),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addManualVolume,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonBackground,
                    foregroundColor: AppColors.buttonText,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                  child: const Text('+', style: TextStyle(fontSize: 20)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _manualVolumes.length,
              itemBuilder: (context, index) {
                final entry = _manualVolumes[index];
                return ListTile(
                  tileColor: AppColors.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  title: Text(
                    '${_formatDouble(entry['value'])} ${entry['unit']}',
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _removeManualVolume(index),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            _buildCombinedTotal(),

            const SizedBox(height: 30),
            const Text(
              'Order Comparison',
              style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _orderedAmountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Planned Order Amount',
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
                    value: _orderedUnit,
                    items: _volumeUnits
                        .map((unit) => DropdownMenuItem(
                              value: unit,
                              child: Text(unit, style: const TextStyle(color: AppColors.textPrimary)),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _orderedUnit = val);
                    },
                    dropdownColor: AppColors.surface,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
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
            const SizedBox(height: 16),
            _buildLossCalculation()

          ],
        ),
      ),
    );
  }

  Widget _buildFeetInchesInputRow(
    String label,
    TextEditingController feetController,
    TextEditingController inchesController,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: feetController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: '$label (ft)',
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
            child: TextField(
              controller: inchesController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: '(in)',
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

  Widget _buildCombinedTotal() {
    final manual = _getManualVolumeMeters();
    final total = (_volumeCubicMeters ?? 0) + manual;

    final feet = total / 0.0283168;
    final yards = feet / 27;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Total Volume (Rectangle + Manual):',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 12),
        Text(
          '- Cubic Meters: ${_formatDouble(total)} m³',
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
        ),
        Text(
          '- Cubic Feet: ${_formatDouble(feet)} ft³',
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
        ),
        Text(
          '- Cubic Yards: ${_formatDouble(yards)} yd³',
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildLossCalculation() {
    final totalNeeded = (_volumeCubicMeters ?? 0) + _getManualVolumeMeters();
    final ordered = double.tryParse(_orderedAmountController.text);
    if (ordered == null || ordered <= 0) return const SizedBox();

    final orderedMeters = _convertToCubicMeters(ordered, _orderedUnit);
    final difference = orderedMeters - totalNeeded;
    final percent = ((difference / totalNeeded) * 100).toStringAsFixed(1);
    final isOverLow = difference >= 0 && ((difference / totalNeeded) * 100) < 15;
    final isOverHigh = difference >= 0 && ((difference / totalNeeded) * 100) >= 15;

    final diffFeet = difference / 0.0283168;
    final diffYards = diffFeet / 27;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ordered > 0 ? 'Overage (Extra Ordered):' : 'Shortage (Under Ordered):',
          style: TextStyle(
            color: isOverLow ? Colors.green : isOverHigh ? Colors.yellow: Colors.redAccent,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '- Difference: ${_formatDouble(difference.abs())} m³',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        Text(
          '- Difference: ${_formatDouble(diffFeet.abs())} ft³',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        Text(
          '- Difference: ${_formatDouble(diffYards.abs())} yd³',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        Text(
          '- Percentage: ${isOverLow || isOverHigh ? '+' : '-'}$percent%',
          style: TextStyle(
            color: isOverLow ? Colors.green : isOverHigh ? Colors.yellow: Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
