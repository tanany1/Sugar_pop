import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../utils/providers/user_provider.dart';
import '../../utils/app_colors.dart';
import '../../services/notification_service.dart'; // Import the notification service

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isPasswordVisible = false;
  Timer? _minuteTimer;
  final TextEditingController medicineNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).loadMedications();
      _checkMedicationTime(); // Ensure this gets called after medications are loaded
    });
    _minuteTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }
  @override
  void dispose() {
    _minuteTimer?.cancel();
    super.dispose();
  }

  void _checkMedicationTime() {
    final medications = Provider.of<UserProvider>(context, listen: false).medications;
    final now = DateTime.now();

    for (var medication in medications) {
      // Create DateTime for medication time today
      final medicationTime = DateTime(
        now.year,
        now.month,
        now.day,
        medication.time.hour,
        medication.time.minute,
      );

      // Check if within a 2-minute window of medication time
      final difference = now.difference(medicationTime).inMinutes.abs();

      // Send a notification if we're within 2 minutes of medication time
      if (difference <= 2) {
        final reminderKey = '${medication.id}_${now.day}_${medication.time.hour}_${medication.time.minute}';

        // Use shared preferences to track sent notifications
        SharedPreferences.getInstance().then((prefs) {
          if (prefs.getBool(reminderKey) != true) {
            // Mark as sent
            prefs.setBool(reminderKey, true);

            // Remove the marker after 3 minutes
            Future.delayed(const Duration(minutes: 3), () {
              prefs.remove(reminderKey);
            });

            // Send an immediate notification instead of showing a dialog
            _sendImmediateMedicationNotification(medication);
          }
        });
      }
    }
  }

// Track which medication reminders have been shown to prevent duplicates
  void _sendImmediateMedicationNotification(Medication medication) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'medication_reminders_immediate',
      'Immediate Medication Reminders',
      channelDescription: 'Immediate notifications for medication reminders',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      // category: 'alarm',
      visibility: NotificationVisibility.public,
      enableVibration: true,
      playSound: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Generate a unique ID for this immediate notification
    final int notificationId = '${medication.id}_immediate_${DateTime.now().millisecondsSinceEpoch}'.hashCode;

    try {
      await LocalNotificationService.flutterLocalNotificationsPlugin.show(
        notificationId,
        'Medication Reminder',
        'Time to take ${medication.name}',
        details,
      );

      print('Sent immediate notification for ${medication.name}');
    } catch (e) {
      print('Error sending immediate notification: $e');
    }
  }
  // void _showMedicationReminder(Medication medication) {
  //   // Check if we've already shown this reminder in the last few minutes
  //   final String reminderKey = '${medication.id}_${DateTime.now().day}_${DateTime.now().hour}_${DateTime.now().minute}';
  //
  //   if (!_shownReminders.contains(reminderKey)) {
  //     _shownReminders.add(reminderKey);
  //
  //     // Remove the reminder key after a few minutes to allow showing again next day
  //     Future.delayed(const Duration(minutes: 5), () {
  //       _shownReminders.remove(reminderKey);
  //     });
  //
  //     // Show the actual reminder
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       if (mounted) {
  //         showDialog(
  //           context: context,
  //           builder: (context) => AlertDialog(
  //             title: const Text("Medication Reminder"),
  //             content: Text("It's time to take ${medication.name}"),
  //             actions: [
  //               TextButton(
  //                 onPressed: () => Navigator.pop(context),
  //                 child: const Text("OK"),
  //               ),
  //             ],
  //           ),
  //         );
  //       }
  //     });
  //   }
  // }

  Future<void> _showLogoutConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Log Out', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                try {
                  // First close the dialog
                  Navigator.of(context).pop();

                  // Show loading indicator
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Logging out...")),
                  );

                  // Sign out from Firebase
                  await FirebaseAuth.instance.signOut();

                  // Clear user data in provider
                  if (mounted) {
                    Provider.of<UserProvider>(context, listen: false)
                        .clearUser();
                  }

                  // Navigate to login screen - using pushNamedAndRemoveUntil to clear navigation stack
                  if (mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                          (route) => false, // This clears the navigation stack
                    );
                  }
                } catch (e) {
                  // Handle any errors during logout
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text("Error logging out: ${e.toString()}")),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _showLogoutConfirmationDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50),
              ),
              const SizedBox(height: 16),
              Text(
                '${user.firstName} ${user.lastName}',
                style:
                const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              buildProfileInfoField(label: 'Email', value: user.email),
              buildProfileInfoField(
                label: 'Password',
                value: user.password,
                isPassword: true,
                isPasswordVisible: isPasswordVisible,
                onVisibilityToggle: () =>
                    setState(() => isPasswordVisible = !isPasswordVisible),
              ),
              buildProfileInfoField(label: 'Gender', value: user.gender),
              const SizedBox(height: 24),
              buildMedicationSection(user),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildProfileInfoField({
    required String label,
    required String value,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onVisibilityToggle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                isPassword && !isPasswordVisible ? '•••••••••••' : value,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            if (isPassword && onVisibilityToggle != null)
              IconButton(
                icon: Icon(isPasswordVisible
                    ? Icons.visibility_off
                    : Icons.visibility),
                onPressed: onVisibilityToggle,
              ),
          ],
        ),
      ),
    );
  }

  Widget buildMedicationSection(UserProvider user) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.medication, color: AppColors.primary3),
                SizedBox(width: 8),
                Text(
                  'My Medications',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // List of medications
            if (user.medications.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No medications added yet'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: user.medications.length,
                itemBuilder: (context, index) {
                  final medication = user.medications[index];

                  // Check if it's exactly medication time
                  final now = TimeOfDay.now();
                  final isMedicationTimeNow = now.hour == medication.time.hour && now.minute == medication.time.minute;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: isMedicationTimeNow
                        ? Colors.green[100]
                        : Colors.grey[100],
                    child: ListTile(
                      leading: const Icon(Icons.notifications_active,
                          color: AppColors.primary3),
                      title: Text(medication.name),
                      subtitle: Text(
                        'Reminder: ${medication.time.format(context)}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: medication.time,
                              );

                              if (time != null) {
                                // Cancel the old notification
                                await LocalNotificationService.cancelMedicationReminder(
                                    medication.id);

                                // Remove old medication
                                await user.removeMedication(medication.id);

                                // Add new medication with updated time
                                final newMedication = Medication(
                                  id: medication.id,
                                  name: medication.name,
                                  time: time,
                                );

                                await user.addMedication(newMedication);

                                // Schedule new notification
                                await LocalNotificationService.scheduleMedicationReminder(
                                  newMedication.id,
                                  newMedication.name,
                                  newMedication.time,
                                );

                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                        Text("Medication time updated")),
                                  );
                                }
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              // Show confirmation dialog
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Delete Medication"),
                                  content: Text(
                                      "Are you sure you want to remove ${medication.name}?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text("Delete",
                                          style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmed == true) {
                                // Cancel notification first
                                await LocalNotificationService.cancelMedicationReminder(
                                    medication.id);

                                // Then remove medication
                                await user.removeMedication(medication.id);

                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text("Medication removed")),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            // Add new medication form
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.add_circle, color: AppColors.primary3),
                      SizedBox(width: 8),
                      Text(
                        'Add New Medication',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: medicineNameController,
                    decoration: InputDecoration(
                      labelText: 'Medication Name',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary3,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        if (medicineNameController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Please enter medication name")),
                          );
                          return;
                        }

                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );

                        if (time != null) {
                          final medicationId = const Uuid().v4();
                          final medication = Medication(
                            name: medicineNameController.text.trim(),
                            time: time,
                            id: medicationId,
                          );

                          // Add medication to provider
                          await Provider.of<UserProvider>(context, listen: false)
                              .addMedication(medication);

                          // Schedule notification
                          await LocalNotificationService.scheduleMedicationReminder(
                            medicationId,
                            medication.name,
                            time,
                          );

                          medicineNameController.clear();

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      "Medication added with reminder at ${time.format(context)}")),
                            );
                          }
                        }
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add,
                            size: 20,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text('Add Medication'),
                        ],
                      ),
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