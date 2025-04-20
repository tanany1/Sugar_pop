import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider with ChangeNotifier {
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _password = '';
  String _gender = '';
  List<Medication> _medications = [];

  // Getters
  String get firstName => _firstName;
  String get lastName => _lastName;
  String get email => _email;
  String get password => _password;
  String get gender => _gender;
  List<Medication> get medications => _medications;

  // Set user data locally
  void setUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String gender,
  }) {
    _firstName = firstName;
    _lastName = lastName;
    _email = email;
    _password = password;
    _gender = gender;
    notifyListeners();
  }

  // Save user data to Firestore
  Future<void> saveUserToFirestore(String uid) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'firstName': _firstName,
        'lastName': _lastName,
        'email': _email,
        'gender': _gender,
        'medications': [],
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving user data: $e');
      rethrow;
    }
  }

  // Load user data from Firestore
  Future<void> loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userData.exists) {
          final data = userData.data()!;
          _firstName = data['firstName'] ?? '';
          _lastName = data['lastName'] ?? '';
          _email = data['email'] ?? '';
          _gender = data['gender'] ?? '';

          // Load medications
          _medications = [];
          if (data['medications'] != null) {
            for (var med in data['medications']) {
              _medications.add(Medication(
                name: med['name'],
                time: TimeOfDay(
                  hour: med['hour'],
                  minute: med['minute'],
                ),
                id: med['id'],
              ));
            }
          }

          notifyListeners();
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  // Add a medication
  Future<void> addMedication(Medication medication) async {
    _medications.add(medication);
    notifyListeners();
    await _updateMedications();
  }

  // Remove a medication
  Future<void> removeMedication(String id) async {
    _medications.removeWhere((med) => med.id == id);
    notifyListeners();
    await _updateMedications();
  }

  // Update medications in Firestore
  Future<void> _updateMedications() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        List<Map<String, dynamic>> medsData = _medications.map((med) => {
          'name': med.name,
          'hour': med.time.hour,
          'minute': med.time.minute,
          'id': med.id,
        }).toList();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'medications': medsData});
      }
    } catch (e) {
      print('Error updating medications: $e');
    }
  }

  // Clear user data on logout
  void clearUser() {
    _firstName = '';
    _lastName = '';
    _email = '';
    _password = '';
    _gender = '';
    _medications = [];
    notifyListeners();
  }
}

class Medication {
  final String name;
  final TimeOfDay time;
  final String id;

  Medication({
    required this.name,
    required this.time,
    required this.id,
  });
}