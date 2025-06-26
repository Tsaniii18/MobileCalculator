import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/calculation_service.dart';
import '../widgets/calculator_button.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage>
    with SingleTickerProviderStateMixin {
  String _output = '0';
  String _currentInput = '';
  double _num1 = 0;
  double _num2 = 0;
  String _operation = '';
  bool _waitingForSecondNumber = false;
  bool _isNegative = false;
  late AnimationController _animationController;
  late Animation<double> _buttonAnimation;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _buttonAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyInput(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      final key = event.logicalKey;

      if (key == LogicalKeyboardKey.enter) {
        _buttonPressed('=');
      } else if (key == LogicalKeyboardKey.escape) {
        _buttonPressed('C');
      } else if (key == LogicalKeyboardKey.backspace) {
        _handleBackspace();
      } else {
        final label = key.keyLabel;

        if (['+', '-', '*', '/'].contains(label)) {
          _buttonPressed(label);
        } else if (label == '.') {
          _buttonPressed('.');
        } else if (RegExp(r'^[0-9]$').hasMatch(label)) {
          _buttonPressed(label);
        }
      }
    }
  }

  void _handleBackspace() {
    setState(() {
      if (_currentInput.isNotEmpty) {
        _currentInput = _currentInput.substring(0, _currentInput.length - 1);
        _output = _currentInput.isEmpty ? '0' : _currentInput;
        if (_currentInput.isEmpty && _isNegative) {
          _isNegative = false;
        }
      } else if (_operation.isNotEmpty) {
        _operation = '';
        _currentInput = _num1.toString();
        _output = _currentInput;
        _waitingForSecondNumber = false;
      }
    });
  }

  void _buttonPressed(String buttonText) {
    _animationController.forward().then((_) => _animationController.reverse());

    setState(() {
      if (buttonText == 'C') {
        _resetCalculator();
      } else if (buttonText == '⌫') {
        _handleBackspace();
      } else if (['+', '*', '/'].contains(buttonText)) {
        _handleOperation(buttonText);
      } else if (buttonText == '-') {
        if (_currentInput.isEmpty && !_isNegative) {
          _isNegative = true;
          _output = '-';
        } else {
          _handleOperation(buttonText);
        }
      } else if (buttonText == '=') {
        _handleEquals();
      } else if (buttonText == '.') {
        _handleDecimal();
      } else {
        _handleNumberInput(buttonText);
      }

      if (_currentInput.length > 15) {
        _currentInput = _currentInput.substring(0, 15);
        _output = _currentInput;
      }
    });
  }

  void _resetCalculator() {
    _output = '0';
    _currentInput = '';
    _num1 = 0;
    _num2 = 0;
    _operation = '';
    _waitingForSecondNumber = false;
    _isNegative = false;
  }

  void _handleOperation(String buttonText) {
    if (_currentInput.isNotEmpty || (_operation.isEmpty && _num1 != 0)) {
      if (_currentInput.isNotEmpty) {
        _num1 = double.parse((_isNegative ? '-' : '') + _currentInput);
      }
      _operation = buttonText;
      _waitingForSecondNumber = true;
      _currentInput = '';
      _isNegative = false;
      _output = '$_num1$_operation';
    }
  }

  void _handleEquals() {
    if (_operation.isNotEmpty && _currentInput.isNotEmpty) {
      _num2 = double.parse((_isNegative ? '-' : '') + _currentInput);
      try {
        final result = CalculationService.calculate(_num1, _num2, _operation);
        _output = result.toString();
        _currentInput = result.abs().toString();
        _isNegative = result.isNegative;
        _operation = '';
        _waitingForSecondNumber = false;
      } catch (e) {
        _showErrorDialog(e.toString());
      }
    }
  }

  void _handleDecimal() {
    if (!_currentInput.contains('.')) {
      _currentInput += _currentInput.isEmpty ? '0.' : '.';
      _output = (_isNegative ? '-' : '') + _currentInput;
    }
  }

  void _handleNumberInput(String value) {
    if (_waitingForSecondNumber) {
      _currentInput = value;
      _waitingForSecondNumber = false;
    } else {
      _currentInput += value;
    }
    _output = (_isNegative ? '-' : '') + _currentInput;
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Calculation Error'),
            content: Text(error),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _resetCalculator();
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: RawKeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKey: _handleKeyInput,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue, Colors.white],
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            _operation.isNotEmpty
                                ? '$_num1$_operation${_isNegative ? '-' : ''}$_currentInput'
                                : (_isNegative ? '-' : '') + _currentInput,
                            style: TextStyle(fontSize: 24, color: Colors.grey),
                            textAlign: TextAlign.end,
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Text(
                                _output,
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Card(
                  elevation: 4,
                  margin: const EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: GridView.count(
                      crossAxisCount: 4,
                      children:
                          [
                            '7',
                            '8',
                            '9',
                            '/',
                            '4',
                            '5',
                            '6',
                            '*',
                            '1',
                            '2',
                            '3',
                            '-',
                            '.',
                            '0',
                            '=',
                            '+',
                            'C',
                            '⌫',
                          ].map((text) {
                            return CalculatorButton(
                              text: text,
                              onPressed: () => _buttonPressed(text),
                              isOperation: [
                                '+',
                                '-',
                                '*',
                                '/',
                                '=',
                              ].contains(text),
                              isClear: text == 'C',
                              isEquals: text == '=',
                              isBackspace: text == '⌫',
                              animation: _buttonAnimation,
                            );
                          }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
