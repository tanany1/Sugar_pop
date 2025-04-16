import 'dart:math';
import 'package:flutter/material.dart';

class DailyTipScreen extends StatefulWidget {
  const DailyTipScreen({super.key});

  @override
  State<DailyTipScreen> createState() => _DailyTipScreenState();
}

class _DailyTipScreenState extends State<DailyTipScreen> {
  final List<String> tips = [
    "Try to get at least 30 minutes of exercise today.",
    "Drink 8 glasses of water to stay hydrated.",
    "Take deep breaths to reduce stress.",
    "Eat at least 5 servings of fruits and vegetables.",
    "Take a short walk during your break.",
    "Avoid screen time before bed for better sleep.",
    "Stretch for 5 minutes every hour if sitting.",
  ];

  late String selectedTip;

  @override
  void initState() {
    super.initState();
    selectRandomTip();
  }

  void selectRandomTip() {
    final random = Random();
    selectedTip = tips[random.nextInt(tips.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F3),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Daily Tip",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF925F6B),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 150,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F1EC),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    selectedTip,
                    style: const TextStyle(
                      fontSize: 24,
                      color: Color(0xFF6A7B7B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Image.asset(
                'assets/images/droplet_character.png',
                height: 200,
                width: 200,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
