import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_page.dart';
import 'bmi_calculator_page.dart';
import 'calculator_page.dart';
import 'number_type_page.dart';
import 'batch_calculate_page.dart';
import 'help_page.dart';
import 'time_converter_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  String _username = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _loadUsername();
  }

  void _loadUsername() async {
    final authService = AuthService();
    final rememberedUser = await authService.getRememberedUser();
    setState(() {
      _username = rememberedUser ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      {
        'title': 'Calculator',
        'icon': Icons.calculate,
        'color': Colors.blue,
        'page': const CalculatorPage(),
      },
      {
        'title': 'Batch Calculate',
        'icon': Icons.playlist_add,
        'color': Colors.purple,
        'page': const BatchCalculatePage(),
      },
      {
        'title': 'Number Type',
        'icon': Icons.numbers,
        'color': Colors.green,
        'page': const NumberTypePage(),
      },
      {
        'title': 'BMI Calculator',
        'icon': Icons.monitor_weight,
        'color': Colors.orange,
        'page': const BMICalculatorPage(),
      },
      {
        'title': 'Time Converter',
        'icon': Icons.access_time,
        'color': Colors.teal,
        'page': const TimeConverterPage(),
      },
      {
        'title': 'Help',
        'icon': Icons.help,
        'color': Colors.red,
        'page': const HelpPage(),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Calculator & Utilities'),
            if (_username.isNotEmpty)
              Text(
                'Welcome, $_username',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authService = AuthService();
              await authService.logout();
              if (!mounted) return;
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder:
                      (context, animation, secondaryAnimation) =>
                          const LoginPage(),
                  transitionsBuilder: (
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 1),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _animation,
        child: GridView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: menuItems.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            mainAxisExtent: 160, 
          ),
          itemBuilder: (context, index) {
            final item = menuItems[index];
            return _buildMenuCard(
              context,
              item['title'] as String,
              item['icon'] as IconData,
              item['color'] as Color,
              () => _navigateTo(context, item['page'] as Widget),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40, color: color),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }
}
