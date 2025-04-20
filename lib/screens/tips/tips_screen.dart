import 'dart:math';
import 'package:flutter/material.dart';

class DailyTipScreen extends StatefulWidget {
  const DailyTipScreen({super.key});

  @override
  State<DailyTipScreen> createState() => _DailyTipScreenState();
}

class _DailyTipScreenState extends State<DailyTipScreen> {
  final List tips = [
    "Aim for 150 minutes of moderate aerobic activity weekly to help manage blood sugar.",
    "Check your blood glucose before and after exercise to understand your body's response.",
    "Choose low glycemic index foods that won't spike blood sugar levels.",
    "Stay hydrated by drinking water throughout the day, especially before exercise.",
    "Include protein with each meal to help stabilize blood sugar levels.",
    "Take short walks after meals to help lower post-meal glucose spikes.",
    "Monitor carbohydrate intake and balance with appropriate insulin or medication.",
    "Wear proper footwear during exercise to protect your feet from injuries.",
    "Keep fast-acting carbohydrates handy during workouts in case of hypoglycemia.",
    "Incorporate resistance training twice weekly to improve insulin sensitivity.",
    "Establish a consistent meal schedule to maintain steady blood glucose levels.",
    "Practice portion control using the plate method: ½ non-starchy vegetables, ¼ protein, ¼ carbs.",
    "Choose whole grains over refined carbohydrates for better blood sugar control.",
    "Monitor your feet daily for cuts, blisters, or redness to prevent complications.",
    "Stay consistent with medication timing relative to meals and exercise.",
    "Get adequate sleep to help regulate blood sugar and reduce insulin resistance.",
    "Track your carbohydrate intake to better manage blood glucose fluctuations.",
    "Limit alcohol consumption as it can cause unpredictable blood sugar changes.",
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
      appBar: AppBar(title:const Text(" Daily Tip"),),
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
                height: 200,
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
