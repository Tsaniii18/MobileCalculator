import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/calculation_service.dart';
import '../widgets/custom_button.dart';

class TimeConverterPage extends StatefulWidget {
  const TimeConverterPage({super.key});

  @override
  State<TimeConverterPage> createState() => _TimeConverterPageState();
}

class _TimeConverterPageState extends State<TimeConverterPage> with SingleTickerProviderStateMixin {
  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;
  Map<String, int>? _timeDifference;
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
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        _calculateDifference();
      });
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
        _calculateDifference();
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
        _calculateDifference();
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
        _calculateDifference();
      });
    }
  }

  void _calculateDifference() {
    if (_startDate != null && _endDate != null) {
      DateTime startDateTime = _startDate!;
      if (_startTime != null) {
        startDateTime = DateTime(
          startDateTime.year,
          startDateTime.month,
          startDateTime.day,
          _startTime!.hour,
          _startTime!.minute,
        );
      }

      DateTime endDateTime = _endDate!;
      if (_endTime != null) {
        endDateTime = DateTime(
          endDateTime.year,
          endDateTime.month,
          endDateTime.day,
          _endTime!.hour,
          _endTime!.minute,
        );
      }

      if (endDateTime.isBefore(startDateTime)) {
        setState(() {
          _timeDifference = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('End date/time must be after start date/time'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        return;
      }

      setState(() {
        _timeDifference = CalculationService.calculateTimeDifference(
          startDateTime,
          endDateTime,
        );
        _animationController.forward();
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select Date';
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return 'Select Time';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Converter'),
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
            colors: [
              Colors.blue,
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateTimeCard(
                title: 'Start Date & Time:',
                dateLabel: 'Date:',
                timeLabel: 'Time:',
                dateText: _formatDate(_startDate),
                timeText: _formatTime(_startTime),
                onDatePressed: () => _selectStartDate(context),
                onTimePressed: () => _selectStartTime(context),
              ),
              const SizedBox(height: 16),
              _buildDateTimeCard(
                title: 'End Date & Time:',
                dateLabel: 'Date:',
                timeLabel: 'Time:',
                dateText: _formatDate(_endDate),
                timeText: _formatTime(_endTime),
                onDatePressed: () => _selectEndDate(context),
                onTimePressed: () => _selectEndTime(context),
              ),
              const SizedBox(height: 24),
              if (_timeDifference != null)
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Text(
                              'Time Difference',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: Text(
                              '${_timeDifference!['days']} hari, '
                              '${_timeDifference!['hours']} jam, '
                              '${_timeDifference!['minutes']} menit.',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildTimeDifferenceDetailRow('Hari', _timeDifference!['days']),
                          _buildTimeDifferenceDetailRow('Jam', _timeDifference!['hours']),
                          _buildTimeDifferenceDetailRow('Menit', _timeDifference!['minutes']),
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
                      _buildInstructionItem(Icons.calendar_today, 'Select start date and time'),
                      _buildInstructionItem(Icons.calendar_today, 'Select end date and time'),
                      _buildInstructionItem(Icons.access_time, 'The time difference will be calculated automatically'),
                      _buildInstructionItem(Icons.info, 'End time must be after start time'),
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

  Widget _buildDateTimeCard({
    required String title,
    required String dateLabel,
    required String timeLabel,
    required String dateText,
    required String timeText,
    required VoidCallback onDatePressed,
    required VoidCallback onTimePressed,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(dateLabel, style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 45,
                        child: CustomButton(
                          text: dateText,
                          onPressed: onDatePressed,
                          icon: Icons.calendar_today,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(timeLabel, style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 45,
                        child: CustomButton(
                          text: timeText,
                          onPressed: onTimePressed,
                          icon: Icons.access_time,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeDifferenceDetailRow(String label, int? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Text(
            value?.toString() ?? '0',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
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
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}