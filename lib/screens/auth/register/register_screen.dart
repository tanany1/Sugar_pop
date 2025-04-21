import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/dialog_utils.dart';
import '../../../utils/providers/user_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController rePasswordController = TextEditingController();
  String? selectedGender;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final _userDataBox = Hive.box('user_data');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F2),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                width: 350,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 20),
                      Image.asset(
                        'assets/images/logo.png',
                        height: 150,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Register',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 32),
                      buildTextField(
                        controller: firstNameController,
                        hintText: 'First Name',
                        prefixIcon: Icons.person_outline,
                        validator: (text) => text == null || text.trim().isEmpty
                            ? "Enter First Name"
                            : null,
                      ),
                      const SizedBox(height: 16),
                      buildTextField(
                        controller: lastNameController,
                        hintText: 'Last Name',
                        prefixIcon: Icons.person_outline,
                        validator: (text) => text == null || text.trim().isEmpty
                            ? "Enter Last Name"
                            : null,
                      ),
                      const SizedBox(height: 16),
                      buildTextField(
                        controller: emailController,
                        hintText: 'Email Address',
                        prefixIcon: Icons.email_outlined,
                        validator: (text) {
                          if (text == null || text.trim().isEmpty) {
                            return "Empty Email is not Allowed";
                          }
                          final bool emailValid = RegExp(
                              r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                              .hasMatch(text);
                          if (!emailValid) {
                            return "This Email is not Allowed";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      buildTextField(
                        controller: passwordController,
                        hintText: 'Password',
                        prefixIcon: Icons.lock_outline,
                        isPassword: true,
                        validator: (text) {
                          if (text == null || text.length < 6) {
                            return "Please Enter a Valid Password (min 6 characters)";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      buildTextField(
                        controller: rePasswordController,
                        hintText: 'Confirm Password',
                        prefixIcon: Icons.lock_outline,
                        isPassword: true,
                        validator: (text) {
                          if (text == null || text.length < 6) {
                            return "Please Enter a Valid Password";
                          }
                          if (text != passwordController.text) {
                            return "Passwords do not Match";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: DropdownButtonFormField<String>(
                          value: selectedGender,
                          hint: const Text('Select Gender'),
                          items: ['Male', 'Female']
                              .map((gender) => DropdownMenuItem(
                            value: gender,
                            child: Text(gender),
                          ))
                              .toList(),
                          onChanged: (value) {
                            setState(() => selectedGender = value);
                            // Debug message to check if the gender is being set
                            print('Selected gender: $selectedGender');
                          },
                          validator: (value) =>
                          value == null ? 'Please select a gender' : null,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(Icons.wc),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      buildButton(
                        text: 'Create Account',
                        onPressed: registerAccount,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account? ",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                color: Color(0xFFB98E8E),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool isPassword = false,
    required String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        obscuringCharacter: "*",
        validator: validator,
        cursorColor: AppColors.primary3,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            prefixIcon,
            color: Colors.grey[500],
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
        ),
      ),
    );
  }

  Widget buildButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary3,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> registerAccount() async {
    // First validate the form
    if (!formKey.currentState!.validate()) return;

    // Explicitly check gender selection
    if (selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a gender")),
      );
      return;
    }

    // Show loading indicator
    DialogUtils.showLoading(context);

    try {
      // Create user in Firebase Authentication
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final userId = userCredential.user!.uid;

      // Debug print to verify gender value
      print('About to save gender: $selectedGender');

      // Save user data to Hive
      await _userDataBox.put('$userId-firstName', firstNameController.text.trim());
      await _userDataBox.put('$userId-lastName', lastNameController.text.trim());
      await _userDataBox.put('$userId-email', emailController.text.trim());
      await _userDataBox.put('$userId-password', passwordController.text.trim());
      await _userDataBox.put('$userId-gender', selectedGender);

      // Verify what was saved to Hive
      print('Saved to Hive: ${_userDataBox.get('$userId-gender')}');

      // Ensure the selected gender is not null before updating UserProvider
      if (selectedGender != null) {
        // Update UserProvider with user data
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setUser(
          firstName: firstNameController.text.trim(),
          lastName: lastNameController.text.trim(),
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
          gender: selectedGender!,
        );
      } else {
        // This should not happen due to validation, but as an extra safety measure
        print('Error: Gender is null when trying to update UserProvider');
        DialogUtils.hideLoading(context);
        DialogUtils.showError(context, 'Registration failed: Gender selection is required.');
        return;
      }

      // Hide loading indicator
      DialogUtils.hideLoading(context);

      // Navigate to home screen
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      DialogUtils.hideLoading(context);
      if (e.code == 'weak-password') {
        DialogUtils.showError(context, 'The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        DialogUtils.showError(
            context, 'An account already exists for that email.');
      } else {
        DialogUtils.showError(context, 'Registration failed: ${e.message}');
      }
    } catch (e) {
      print('Registration error: $e');
      DialogUtils.hideLoading(context);
      DialogUtils.showError(
          context, 'Something went wrong. Please try again later.');
    }
  }
}