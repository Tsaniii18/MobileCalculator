import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'App Features:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildFeatureCard(
              context,
              Icons.calculate,
              'Basic Calculator',
              'Perform addition, subtraction, multiplication, and division operations',
            ),
            _buildFeatureCard(
              context,
              Icons.numbers,
              'Number Type Checker',
              'Determine if a number is integer, decimal, prime, positive, negative, odd, or even',
            ),
            _buildFeatureCard(
              context,
              Icons.monitor_weight,
              'BMI Calculator',
              'Calculate Body Mass Index based on weight and height with category indicators',
            ),
            _buildFeatureCard(
              context,
              Icons.playlist_add,
              'Batch Calculator',
              'Perform operations on multiple numbers at once (sum, subtract, multiply, divide)',
            ),
            _buildFeatureCard(
              context,
              Icons.access_time,
              'Time Converter',
              'Calculate difference between two dates with time precision',
            ),
            const SizedBox(height: 30),
            const Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Creator',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    ListTile(
                      leading: Icon(Icons.person),
                      title: Text('Muhamad Tsani Putra Tronchet'),
                    ),
                    ListTile(
                      leading: Icon(Icons.email),
                      title: Text('123220115@student.upnyk.ac.id'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, IconData icon, String title, String description) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 40, color: Theme.of(context).primaryColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}