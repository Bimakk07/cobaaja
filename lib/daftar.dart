// ignore_for_file: use_build_context_synchronously, prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:cobaaja/komponen/buttom.dart';
import 'package:cobaaja/komponen/text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailTexController = TextEditingController();
  final passwordTexController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Sign up
  void signUp() async {
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Pastikan kata sandi
    if (passwordTexController.text != confirmPasswordController.text) {
      Navigator.pop(context);
      displayMessage("Kata sandi salah");
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailTexController.text, 
        password: passwordTexController.text,
      );

      FirebaseFirestore.instance
          .collection("user")
          .doc(userCredential.user!.email)
          .set({
            'username' : emailTexController.text.split('@') [0],
            'bio' : 'empty bio..'
          });

      if (context.mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      displayMessage(e.code);
    }
  }

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
                      'Daftar akun sekarang',
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

                    // Konfirmasi Password
                    MyTextField(
                      controller: confirmPasswordController,
                      hintText: 'Konfirmasi Password',
                      obscureText: true,
                    ),
                    const SizedBox(height: 25),

                    // Sign Up Button
                    MyButtom(
                      onTap: signUp,
                      text: 'Sign up',
                    ),
                    const SizedBox(height: 25),

                    // Login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Sudah punya akun",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: widget.onTap,
                          child: const Text(
                            "Login Sekarang",
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
