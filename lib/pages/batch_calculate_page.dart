import 'package:flutter/material.dart';
import '../services/calculation_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class BatchCalculatePage extends StatefulWidget {
  const BatchCalculatePage({super.key});

  @override
  State<BatchCalculatePage> createState() => _BatchCalculatePageState();
}

class _BatchCalculatePageState extends State<BatchCalculatePage>
    with SingleTickerProviderStateMixin {
  final _numbersController = TextEditingController();
  String _result = '';
  String? _selectedOperation;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _numbersController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (_numbersController.text.isEmpty || _selectedOperation == null) {
      setState(() {
        _result = 'Please enter numbers and select an operation';
        _animationController.reset();
      });
      return;
    }

    try {
      final numbers =
          _numbersController.text
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .map((s) {
                final num = double.tryParse(s);
                if (num == null)
                  throw FormatException('"$s" is not a valid number');
                return num;
              })
              .toList();

      if (numbers.isEmpty) {
        setState(() {
          _result = 'Please enter valid numbers separated by commas';
          _animationController.reset();
        });
        return;
      }

      final result = CalculationService.batchCalculate(
        numbers,
        _selectedOperation!,
      );
      setState(() {
        _result = 'Result: $result';
        _animationController.forward();
      });
    } on FormatException catch (e) {
      setState(() {
        _result = 'Error: ${e.message}';
        _animationController.reset();
        _animationController.forward();
      });
    } catch (e) {
      setState(() {
        _result = 'Error: ${e.toString()}';
        _animationController.reset();
        _animationController.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Batch Calculator'),
        centerTitle: true,
        elevation: 0,
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Enter numbers separated by commas:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _numbersController,
                        label: 'e.g., 1, 2, 3, 4',
                        icon: Icons.numbers,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select operation:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children:
                            ['+', '-', '*', '/'].map((op) {
                              return ChoiceChip(
                                label: Text(
                                  op,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                                selected: _selectedOperation == op,
                                selectedColor: Colors.blue,
                                backgroundColor: Colors.white,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedOperation = selected ? op : null;
                                  });
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              );
                            }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Calculate',
                onPressed: _calculate,
                color: Colors.blue,
                icon: Icons.calculate,
              ),
              const SizedBox(height: 24),
              if (_result.isNotEmpty)
                ScaleTransition(
                  scale: _animation,
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Colors.blue,
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
                                    : Colors.white,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _result,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
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
                        'Instructions:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInstructionItem(
                        Icons.format_list_numbered,
                        'Enter numbers separated by commas',
                      ),
                      _buildInstructionItem(
                        Icons.control_point,
                        'Select one operation',
                      ),
                      _buildInstructionItem(Icons.calculate, 'Press Calculate'),
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

  Widget _buildInstructionItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
