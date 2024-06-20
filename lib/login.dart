// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously, prefer_const_constructors

import 'package:cobaaja/komponen/buttom.dart';
import 'package:cobaaja/komponen/text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Edit text
  final emailTexController = TextEditingController();
  final passwordTexController = TextEditingController();

  // Sign user
  void SignIn() async {
    // Show loading
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Try sign in
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailTexController.text,
        password: passwordTexController.text,
      );

      // Loading pop
      if (context.mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      displayMessage(e.code);
    }
  }

  // Display dialog
  void displayMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: const [Colors.green, Colors.yellow],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: screenSize.width > 600 ? 500 : screenSize.width,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    const Icon(
                      Icons.lock,
                      size: 100,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 50),

                    Text(
                      'Welcome',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Email
                    MyTextField(
                      controller: emailTexController,
                      hintText: 'Email',
                      obscureText: false,
                    ),
                    const SizedBox(height: 25),

                    // Password
                    MyTextField(
                      controller: passwordTexController,
                      hintText: 'Password',
                      obscureText: true,
                    ),
                    const SizedBox(height: 25),

                    // Sign In Button
                    MyButtom(
                      onTap: SignIn,
                      text: 'Sign In',
                    ),
                    const SizedBox(height: 25),

                    // Register
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Belum Punya Akun?",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: widget.onTap,
                          child: const Text(
                            "Daftar Sekarang",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
