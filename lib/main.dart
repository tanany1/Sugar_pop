import 'package:diabetes/screens/auth/login/login_screen.dart';
import 'package:diabetes/screens/auth/register/register_screen.dart';
import 'package:diabetes/screens/food/food_screen.dart';
import 'package:diabetes/screens/home/home_screen.dart';
import 'package:diabetes/screens/logEntry/log_entry_screen.dart';
import 'package:diabetes/screens/medicine/medicine_screen.dart';
import 'package:diabetes/screens/profile/profile_screen.dart';
import 'package:diabetes/screens/splash/splash_screen.dart';
import 'package:diabetes/screens/tips/tips_screen.dart';
import 'package:diabetes/services/notification_service.dart';
import 'package:diabetes/utils/hive_model.dart';
import 'package:diabetes/utils/providers/user_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(BloodSugarReadingAdapter());
  await Hive.openBox<BloodSugarReading>('readings');
  await Hive.openBox('medications');
  await Hive.openBox('user_data');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await LocalNotificationService.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sugar Pop',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color(0xFFF8F5F2),
      ),
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/splash': (context) => const SplashScreen(),
        '/logEntry': (context) => const LogEntryScreen(),
        '/tips': (context) => const DailyTipScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/food': (context) => const FoodScreen(),
        '/medicine': (context) => const MedicineScreen(),
      },
      initialRoute: '/splash',
    );
  }
}