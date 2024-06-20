import 'package:cobaaja/daftar.dart';
import 'package:cobaaja/login.dart';
import 'package:flutter/material.dart';

 class LoginDaftar extends StatefulWidget {
  const LoginDaftar({super.key});

  @override
  State<LoginDaftar> createState () => _LoginDaftarState();
 }

 class _LoginDaftarState extends State<LoginDaftar>{

  //inisiasi login
  bool showLoginPage = true;

  void togglePages(){
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage){
      return LoginPage(onTap: togglePages);
    } else {
      return RegisterPage(onTap: togglePages);
    }
  }
 }