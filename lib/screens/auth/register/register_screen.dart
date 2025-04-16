import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/dialog_utils.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController rePasswordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

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
                        controller: userNameController,
                        hintText: 'Username',
                        prefixIcon: Icons.person_outline,
                        validator: (text) {
                          if (text == null || text.trim().isEmpty) {
                            return "Please Enter a Valid Name";
                          }
                          return null;
                        },
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
                            return "Please Enter a Valid Password";
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
    if (!formKey.currentState!.validate()) return;

    DialogUtils.showLoading(context);

    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      DialogUtils.hideLoading(context);
      // Navigate to home screen
      Navigator.pushReplacementNamed(context, '/home');

    } on FirebaseAuthException catch (e) {
      DialogUtils.hideLoading(context);
      if (e.code == 'weak-password') {
        DialogUtils.showError(context, 'The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        DialogUtils.showError(context, 'An account already exists for that email.');
      } else {
        DialogUtils.showError(context, 'Registration failed: ${e.message}');
      }
    } catch (e) {
      DialogUtils.hideLoading(context);
      DialogUtils.showError(context, 'Something went wrong. Please try again later.');
    }
  }
}