import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../../utils/providers/user_provider.dart';
import '../../utils/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isPasswordVisible = false;
  final TextEditingController medicineNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).loadMedications();
    });
  }
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
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: Colors.grey[100],
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
                                // Remove old medication
                                await user.removeMedication(medication.id);

                                // Add new medication with updated time
                                final newMedication = Medication(
                                  id: medication.id,
                                  name: medication.name,
                                  time: time,
                                );

                                await user.addMedication(newMedication);

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

                          // Add medication to provider (which will also save to Hive and schedule notification)
                          await Provider.of<UserProvider>(context,
                                  listen: false)
                              .addMedication(medication);

                          medicineNameController.clear();

                          // if (mounted) {
                          //   ScaffoldMessenger.of(context).showSnackBar(
                          //   //   const SnackBar(
                          //   //       // content: Text(
                          //   //       //     "Medication added with notification at ${time.format(context)}")),
                          //   // );
                          // }
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