import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
  final _medicationsBox = Hive.box('medications');

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final userMedications = _medicationsBox.get(userId, defaultValue: []);
      if (userMedications != null) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        for (var med in userMedications) {
          final medication = Medication(
            id: med['id'],
            name: med['name'],
            time: TimeOfDay(hour: med['hour'], minute: med['minute']),
          );
          userProvider.addMedication(medication);
        }
      }
    }
  }

  Future<void> _saveMedication(Medication medication, String userId) async {
    final existingMedications = _medicationsBox.get(userId, defaultValue: []) ?? [];

    final medData = {
      'id': medication.id,
      'name': medication.name,
      'hour': medication.time.hour,
      'minute': medication.time.minute,
    };

    existingMedications.add(medData);
    await _medicationsBox.put(userId, existingMedications);
  }

  Future<void> _deleteMedication(String id, String userId) async {
    final existingMedications = _medicationsBox.get(userId, defaultValue: []) ?? [];
    existingMedications.removeWhere((med) => med['id'] == id);
    await _medicationsBox.put(userId, existingMedications);
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
                await FirebaseAuth.instance.signOut();
                Provider.of<UserProvider>(context, listen: false).clearUser();
                Navigator.of(context).pop(); // Close dialog
                Navigator.pushReplacementNamed(context, '/login');
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
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              buildProfileInfoField(label: 'Email', value: user.email),
              buildProfileInfoField(
                label: 'Password',
                value: user.password,
                isPassword: true,
                isPasswordVisible: isPasswordVisible,
                onVisibilityToggle: () => setState(() => isPasswordVisible = !isPasswordVisible),
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
                icon: Icon(isPasswordVisible ? Icons.visibility_off : Icons.visibility),
                onPressed: onVisibilityToggle,
              ),
          ],
        ),
      ),
    );
  }

  Widget buildMedicationSection(UserProvider user) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Medications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
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
                      title: Text(medication.name),
                      subtitle: Text(
                        'Reminder: ${medication.time.format(context)}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await user.removeMedication(medication.id);
                          await _deleteMedication(medication.id, userId);
                        },
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 16),

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
                  const Text(
                    'Add New Medication',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
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
                            const SnackBar(content: Text("Please enter medication name")),
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

                          // Save to Hive
                          await _saveMedication(medication, userId);

                          medicineNameController.clear();

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Medication added successfully")),
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
                          SizedBox(width: 10,),
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