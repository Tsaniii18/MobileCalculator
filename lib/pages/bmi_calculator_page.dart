import 'package:flutter/material.dart';
import '../services/calculation_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class BMICalculatorPage extends StatefulWidget {
  const BMICalculatorPage({super.key});

  @override
  State<BMICalculatorPage> createState() => _BMICalculatorPageState();
}

class _BMICalculatorPageState extends State<BMICalculatorPage>
    with SingleTickerProviderStateMixin {
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  String _result = '';
  String _category = '';
  Color _categoryColor = Colors.grey;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutBack,
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _calculateBMI() {
    _animationController.reset();

    if (_weightController.text.isEmpty || _heightController.text.isEmpty) {
      setState(() {
        _result = 'Please enter both weight and height';
        _category = '';
        _categoryColor = Colors.grey;
      });
      _animationController.forward();
      return;
    }

    try {
      final weight = double.tryParse(_weightController.text);
      final height = double.tryParse(_heightController.text);

      if (weight == null || height == null) {
        throw FormatException('Please enter valid numbers');
      }

      if (weight <= 0 || height <= 0) {
        throw FormatException('Values must be greater than zero');
      }

      final bmiData = CalculationService.calculateBMI(weight, height);
      final bmiValue = double.parse(bmiData['bmi']!);

      setState(() {
        _result = 'BMI: ${bmiValue.toStringAsFixed(1)}';
        _category = 'Category: ${bmiData['category']}';
        _categoryColor = bmiData['categoryColor'] as Color;
      });

      _animationController.forward();
    } on FormatException catch (e) {
      setState(() {
        _result = 'Error: ${e.message}';
        _category = '';
        _categoryColor = Colors.red;
      });
      _animationController.forward();
    } catch (e) {
      setState(() {
        _result = 'Error: ${e.toString()}';
        _category = '';
        _categoryColor = Colors.red;
      });
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI Calculator'),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _weightController,
                        label: 'Weight (kg)',
                        icon: Icons.monitor_weight,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _heightController,
                        label: 'Height (cm)',
                        icon: Icons.height,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Calculate BMI',
                onPressed: _calculateBMI,
                color: Colors.blue,
                icon: Icons.calculate,
              ),
              const SizedBox(height: 30),
              if (_result.isNotEmpty)
                ScaleTransition(
                  scale: _animation,
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color:
                        _result.startsWith('Error')
                            ? Colors.red.withOpacity(0.2)
                            : _categoryColor.withOpacity(0.5),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Icon(
                            _result.startsWith('Error')
                                ? Icons.error
                                : Icons.calculate,
                            size: 36,
                            color:
                                _result.startsWith('Error')
                                    ? Colors.red
                                    : _categoryColor,
                          ),
                          Center(
                            child: Text(
                              _result,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: _categoryColor,
                              ),
                            ),
                          ),
                          if (_category.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Center(
                              child: Text(
                                _category,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: _categoryColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            LinearProgressIndicator(
                              value: double.parse(_result.split(': ')[1]) / 40,
                              backgroundColor: Colors.grey,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _categoryColor,
                              ),
                              minHeight: 12,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 30),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'BMI Categories:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildCategoryRow(Colors.blue, 'Underweight: < 18.5'),
                      _buildCategoryRow(Colors.green, 'Normal: 18.5 - 24.9'),
                      _buildCategoryRow(Colors.orange, 'Overweight: 25 - 29.9'),
                      _buildCategoryRow(Colors.red, 'Obese: ≥ 30'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryRow(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
