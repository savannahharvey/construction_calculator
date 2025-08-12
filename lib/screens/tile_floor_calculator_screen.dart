import 'package:flutter/material.dart';
import 'package:construction_calculator/theme/app_colors.dart';

class TileFlooringEstimatorScreen extends StatefulWidget {
  const TileFlooringEstimatorScreen({super.key});

  @override
  State<TileFlooringEstimatorScreen> createState() => _TileFlooringEstimatorScreenState();
}

class _TileFlooringEstimatorScreenState extends State<TileFlooringEstimatorScreen> {
  final List<Map<String, TextEditingController>> _rooms = [];
  final TextEditingController _costPerPackageController = TextEditingController();
  final TextEditingController _packageCoverageController = TextEditingController();

  String _selectedUnit = 'sq ft';
  double _totalArea = 0;
  double _leftoverArea = 0;
  double _totalCost = 0;
  int _packagesNeeded = 0;

  @override
  void initState() {
    super.initState();
    _addRoom();
  }

  void _addRoom() {
    setState(() {
      _rooms.add({
        'length': TextEditingController(),
        'width': TextEditingController(),
      });
    });
  }

  void _removeRoom(int index) {
    setState(() {
      _rooms.removeAt(index);
    });
  }

  void _calculate() {
    double totalAreaSqFt = 0;

    for (var room in _rooms) {
      double length = double.tryParse(room['length']!.text) ?? 0;
      double width = double.tryParse(room['width']!.text) ?? 0;
      totalAreaSqFt += length * width;
    }

    // Convert units if needed
    double convertedArea = totalAreaSqFt;
    if (_selectedUnit == 'sq yd') {
      convertedArea = totalAreaSqFt / 9; // 1 sq yd = 9 sq ft
    } else if (_selectedUnit == 'sq m') {
      convertedArea = totalAreaSqFt * 0.092903; // 1 sq ft = 0.092903 sq m
    }

    double costPerPackage = double.tryParse(_costPerPackageController.text) ?? 0;
    double packageCoverage = double.tryParse(_packageCoverageController.text) ?? 0;

    if (packageCoverage <= 0) {
      // Avoid divide by zero
      setState(() {
        _totalArea = convertedArea;
        _leftoverArea = 0;
        _totalCost = 0;
        _packagesNeeded = 0;
      });
      return;
    }

    // Calculate packages needed (rounded UP)
    int packages = (convertedArea / packageCoverage).ceil();

    // Calculate total coverage from packages
    double totalCoverage = packages * packageCoverage;

    // Leftover = total coverage - area needed
    double leftover = totalCoverage - convertedArea;

    // Calculate cost based on packages * cost per package
    double totalCost = packages * costPerPackage;

    setState(() {
      _totalArea = convertedArea;
      _leftoverArea = leftover;
      _totalCost = totalCost;
      _packagesNeeded = packages;
    });
  }

  @override
  void dispose() {
    for (var room in _rooms) {
      room['length']!.dispose();
      room['width']!.dispose();
    }
    _costPerPackageController.dispose();
    _packageCoverageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Tile / Flooring Estimator',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Enter Room Dimensions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Room input fields
            Column(
              children: _rooms.asMap().entries.map((entry) {
                int index = entry.key;
                var controllers = entry.value;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Text('Room ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: controllers['length'],
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Length (ft)'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: controllers['width'],
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Width (ft)'),
                              ),
                            ),
                          ],
                        ),
                        if (_rooms.length > 1)
                          TextButton(
                            onPressed: () => _removeRoom(index),
                            child: const Text('Remove Room', style: TextStyle(color: Colors.red)),
                          )
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addRoom,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.buttonBackground),
              child: const Text('Add Another Room', style: TextStyle(color: AppColors.buttonText)),
            ),

            const Divider(height: 30),

            // Unit toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Measurement Unit:'),
                DropdownButton<String>(
                  value: _selectedUnit,
                  items: ['sq ft', 'sq yd', 'sq m']
                      .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedUnit = value!;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 10),

            TextField(
              controller: _costPerPackageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Cost per package ($_selectedUnit)'),
            ),
            TextField(
              controller: _packageCoverageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Coverage per package ($_selectedUnit)'),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _calculate,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.buttonBackground),
              child: const Text('Calculate', style: TextStyle(color: AppColors.buttonText)),
            ),

            const SizedBox(height: 20),

            if (_totalArea > 0)
              Card(
                color: AppColors.surface,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text('Total Area Needed: ${_totalArea.toStringAsFixed(2)} $_selectedUnit'),
                      Text('Packages Needed: $_packagesNeeded'),
                      Text('Leftover Area: ${_leftoverArea.toStringAsFixed(2)} $_selectedUnit'),
                      Text('Total Cost: \$${_totalCost.toStringAsFixed(2)}'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
