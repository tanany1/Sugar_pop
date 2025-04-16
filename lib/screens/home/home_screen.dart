import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';

import '../../utils/app_colors.dart';
import '../../utils/hive_model.dart';
import '../logEntry/log_entry_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box<BloodSugarReading> readingsBox;

  @override
  void initState() {
    super.initState();
    readingsBox = Hive.box<BloodSugarReading>('readings');
  }

  // Get the highest reading
  BloodSugarReading? getHighestReading() {
    if (readingsBox.isEmpty) return null;

    BloodSugarReading highest = readingsBox.values.first;
    for (var reading in readingsBox.values) {
      if (reading.value > highest.value) {
        highest = reading;
      }
    }
    return highest;
  }

  // Get the most recent readings (up to 3)
  List<BloodSugarReading> getRecentReadings() {
    final readings = readingsBox.values.toList();
    readings.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return readings.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  const Center(
                    child: Text(
                      'Sugar Pop',
                      style: TextStyle(
                        fontSize: 28,
                        color: AppColors.textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: (){
                      Navigator.pushNamed(context, '/tips');
                    },
                    child: const Icon(
                      Icons.notification_important,
                      size: 40,
                      color: AppColors.accentColor,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
              // Logo and Mascots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 250,
                    height: 250,
                    child: Image.asset('assets/images/logo.png'),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
              // Blood Sugar Card
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.primary3,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Blood Sugar',
                      style: TextStyle(
                        fontSize: 22,
                        color: AppColors.primary1,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${getHighestReading()?.value ?? 0}',
                          style: const TextStyle(
                            fontSize: 60,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary1,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          'mg/dL',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.primary1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Log Entry Button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LogEntryScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentColor,
                  foregroundColor: AppColors.textColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Log Entry',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 16),

              // Recent Readings
              const Text(
                'Recent Readings',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.textColor,
                ),
              ),
              const SizedBox(height: 8),

              // Reading cards
              ...getRecentReadings()
                  .map((reading) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Container(
                          height: 80,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primary1,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${reading.value} mg/dL',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textColor,
                                ),
                              ),
                              Text(
                                _formatDateTime(reading.timestamp),
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ))
                  .toList(),
            ],
          ),
        ),
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.only(left: 32.0),
          child: FloatingActionButton(
            backgroundColor: AppColors.primary3,
            foregroundColor: AppColors.primary1,
            child: const Icon(Icons.add),
            onPressed: () {
              _showAddReadingDialog();
            },
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateToCheck = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String prefix;
    if (dateToCheck == today) {
      prefix = 'Today';
    } else if (dateToCheck == yesterday) {
      prefix = 'Yesterday';
    } else {
      prefix = DateFormat('MMM d').format(dateTime);
    }

    return '$prefix, ${DateFormat('h:mm a').format(dateTime)}';
  }

  void _showAddReadingDialog() {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Add Blood Sugar Reading',
          style: TextStyle(color: AppColors.textColor),
        ),
        content: TextField(
          controller: textController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Blood sugar value (mg/dL)',
            hintStyle: TextStyle(color: AppColors.textColor.withOpacity(0.6)),
            suffix: const Text('mg/dL',
                style: TextStyle(color: AppColors.textColor)),
            filled: true,
            fillColor: AppColors.primary5,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textColor)),
          ),
          TextButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                try {
                  final value = int.parse(textController.text);
                  readingsBox.add(BloodSugarReading(
                    value: value,
                    timestamp: DateTime.now(),
                  ));
                  setState(() {});
                  Navigator.pop(context);
                } catch (e) {
                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please enter a valid number',
                        style: TextStyle(color: AppColors.primary1),
                      ),
                      backgroundColor: AppColors.primary3,
                    ),
                  );
                }
              }
            },
            child:
                const Text('Save', style: TextStyle(color: AppColors.primary3)),
          ),
        ],
        backgroundColor: AppColors.primary1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
