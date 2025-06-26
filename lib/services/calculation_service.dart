import 'package:flutter/material.dart';

class CalculationService {
  static double calculate(double num1, double num2, String operation) {
    switch (operation) {
      case '+':
        return num1 + num2;
      case '-':
        return num1 - num2;
      case '*':
        return num1 * num2;
      case '/':
        if (num2 == 0) throw Exception('Cannot divide by zero');
        return num1 / num2;
      default:
        throw Exception('Invalid operation');
    }
  }

  static Color getNumberTypeColor(String type) {
    if (type.contains('Genap')) return Colors.blue;
    if (type.contains('Ganjil')) return Colors.green;
    if (type.contains('Bulat')) return Colors.pink;
    if (type.contains('Desimal')) return Colors.yellow;
    if (type.contains('Positif')) return Colors.teal;
    if (type.contains('Negatif')) return Colors.orange;
    if (type.contains('Prima')) return Colors.purple;
    if (type.contains('Nol')) return Colors.grey;
    return Colors.black;
  }

  static String determineNumberType(String input) {
    try {
      final number = double.tryParse(input);
      if (number == null) return 'Not a valid number';

      String result = '';

      if (number % 1 == 0) {
        result += 'Bulat, ';
        final intNum = number.toInt();

        if (intNum > 0) {
          result += 'Positif, ';
        } else if (intNum < 0) {
          result += 'Negatif, ';
        } else {
          result += 'Nol, ';
        }

        if (intNum != 0) {
          if (intNum % 2 == 0) {
            result += 'Genap, ';
          } else {
            result += 'Ganjil, ';
          }
        }

        if (intNum > 1) {
          bool isPrime = true;
          for (int i = 2; i <= intNum / 2; i++) {
            if (intNum % i == 0) {
              isPrime = false;
              break;
            }
          }
          result += isPrime ? 'Prima, ' : 'Bukan Prima, ';
        }
      } else {
        result += 'Desimal, ';
        if (number > 0) {
          result += 'Positif, ';
        } else {
          result += 'Negatif, ';
        }
      }

      return result.substring(0, result.length - 2);
    } catch (e) {
      return 'Error determining number type';
    }
  }

  static Map<String, dynamic> getBMICategoryData(double bmiValue) {
    String category;
    Color categoryColor;

    if (bmiValue < 18.5) {
      category = 'Underweight';
      categoryColor = Colors.blue;
    } else if (bmiValue < 25) {
      category = 'Normal';
      categoryColor = Colors.green;
    } else if (bmiValue < 30) {
      category = 'Overweight';
      categoryColor = Colors.orange;
    } else {
      category = 'Obese';
      categoryColor = Colors.red;
    }

    return {'category': category, 'categoryColor': categoryColor};
  }

  static Map<String, dynamic> calculateBMI(double weight, double height) {
    if (weight <= 0 || height <= 0) {
      throw Exception('Weight and height must be positive values');
    }

    final heightInMeter = height / 100;
    final bmi = weight / (heightInMeter * heightInMeter);
    final categoryData = getBMICategoryData(bmi);

    return {
      'bmi': bmi.toStringAsFixed(2),
      'category': categoryData['category'],
      'categoryColor': categoryData['categoryColor'],
    };
  }

  static double batchCalculate(List<double> numbers, String operation) {
    if (numbers.isEmpty) return 0;

    double result = numbers[0];
    for (int i = 1; i < numbers.length; i++) {
      switch (operation) {
        case '+':
          result += numbers[i];
          break;
        case '-':
          result -= numbers[i];
          break;
        case '*':
          result *= numbers[i];
          break;
        case '/':
          if (numbers[i] == 0) throw Exception('Cannot divide by zero');
          result /= numbers[i];
          break;
      }
    }
    return result;
  }

  static Map<String, int> calculateTimeDifference(
    DateTime start,
    DateTime end,
  ) {
    final difference = end.difference(start);
    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;

    return {'days': days, 'hours': hours, 'minutes': minutes};
  }
}
