import 'package:flutter/material.dart';
import '../services/calculation_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class NumberTypePage extends StatefulWidget {
  const NumberTypePage({super.key});

  @override
  State<NumberTypePage> createState() => _NumberTypePageState();
}

class _NumberTypePageState extends State<NumberTypePage> with SingleTickerProviderStateMixin {
  final _numberController = TextEditingController();
  String _result = '';
  late AnimationController _animationController;
  late Animation<double> _animation;
  Color _resultColor = Colors.grey;

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
    _numberController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _checkNumberType() {
    if (_numberController.text.isEmpty) {
      setState(() {
        _result = 'Please enter a number first';
        _resultColor = Colors.grey;
      });
      return;
    }
    
    setState(() {
      _result = CalculationService.determineNumberType(_numberController.text);
      _resultColor = Colors.blue;
    });
    
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Number Type Checker'),
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
            colors: [
              Colors.blue,
              Colors.white,
            ],
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
                      const Text(
                        'Enter a number to check its properties:',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: _numberController,
                        label: 'Example: 7, 12.5, -3',
                        icon: Icons.numbers,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Check Number Type',
                onPressed: _checkNumberType,
                color: Colors.blue,
                icon: Icons.search,
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
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Text(
                              'Number Properties:',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          ..._result.split(', ').map((property) {
                            final propertyColor = CalculationService.getNumberTypeColor(property);
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Center(
                                child: Text(
                                  property.trim(),
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: propertyColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
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
                        'Possible Properties:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildPropertyRow(Colors.blue, 'Genap'),
                      _buildPropertyRow(Colors.green, 'Ganjil'),
                      _buildPropertyRow(Colors.pink, 'Bulat'),
                      _buildPropertyRow(Colors.yellow, 'Desimal'),
                      _buildPropertyRow(Colors.teal, 'Positif'),
                      _buildPropertyRow(Colors.orange, 'Negatif'),
                      _buildPropertyRow(Colors.purple, 'Prima'),
                      _buildPropertyRow(Colors.grey, 'Nol'),
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

  Widget _buildPropertyRow(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}