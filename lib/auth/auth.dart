import 'package:cobaaja/auth/login_daftar.dart';
import 'package:cobaaja/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Authpage extends StatelessWidget {
  const Authpage ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder:(context, snapshot) {
          if (snapshot.hasData) {
            return const Beranda();
          }

          else {
            return const LoginDaftar();
          }
        },
    ),
    );
  }
}