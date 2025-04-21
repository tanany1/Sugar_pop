import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Medication {
  final String id;
  final String name;
  final TimeOfDay time;

  Medication({
    required this.id,
    required this.name,
    required this.time,
  });
}

class UserProvider extends ChangeNotifier {
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _password = '';
  String _gender = '';
  List<Medication> _medications = [];
  final Box _userDataBox = Hive.box('user_data');

  String get firstName => _firstName;
  String get lastName => _lastName;
  String get email => _email;
  String get password => _password;
  String get gender => _gender;
  List<Medication> get medications => _medications;

  void setEmailAndPassword({required String email, required String password}) {
    _email = email;
    _password = password;
    notifyListeners();
  }

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
    _saveUserDataToHive();
    notifyListeners();
  }

  void _saveUserDataToHive() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      _userDataBox.put('$userId-firstName', _firstName);
      _userDataBox.put('$userId-lastName', _lastName);
      _userDataBox.put('$userId-email', _email);
      _userDataBox.put('$userId-password', _password);
      _userDataBox.put('$userId-gender', _gender);
    }
  }

  void clearMedications() {
    _medications = [];
    notifyListeners();
  }

  Future<void> loadMedications() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final medicationsBox = Hive.box('medications');
      final userMedications = medicationsBox.get(userId, defaultValue: []);
      _medications = [];
      for (var med in userMedications) {
        final medication = Medication(
          id: med['id'],
          name: med['name'],
          time: TimeOfDay(hour: med['hour'], minute: med['minute']),
        );
        _medications.add(medication);
      }
      notifyListeners();
    }
  }


  Future<void> saveMedicationsToHive() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final medicationsBox = Hive.box('medications');

      final List<Map<String, dynamic>> medicationData = _medications.map((med) => {
        'id': med.id,
        'name': med.name,
        'hour': med.time.hour,
        'minute': med.time.minute,
      }).toList();

      await medicationsBox.put(userId, medicationData);
    }
  }

  Future<void> addMedication(Medication medication) async {
    _medications.add(medication);
    await saveMedicationsToHive();
    notifyListeners();
  }

  Future<void> removeMedication(String id) async {
    _medications.removeWhere((med) => med.id == id);
    await saveMedicationsToHive();
    notifyListeners();
  }

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
