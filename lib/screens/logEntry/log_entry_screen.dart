import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';

import '../../utils/app_colors.dart';
import '../../utils/hive_model.dart';

class LogEntryScreen extends StatelessWidget {
  const LogEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final readingsBox = Hive.box<BloodSugarReading>('readings');
    final readings = readingsBox.values.toList();
    readings.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Blood Sugar Log',
          style: TextStyle(color: AppColors.primary1),
        ),
        backgroundColor: AppColors.primary3,
        iconTheme: const IconThemeData(color: AppColors.primary1),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: readings.length,
        itemBuilder: (context, index) {
          final reading = readings[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary5,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${reading.value} mg/dL',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textColor,
                    ),
                  ),
                  Text(
                    _formatDateTime(reading.timestamp),
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
}