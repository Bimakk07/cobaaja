// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cobaaja/auth/auth.dart';
import 'package:cobaaja/komponen/text_box.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({Key? key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final usersCollection = FirebaseFirestore.instance.collection("user");

  Future<void> editField(String field) async {
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          "Edit $field",
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          autofocus: true,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Enter new $field",
            hintStyle: TextStyle(color: Colors.grey),
          ),
          onChanged: (value) {
            newValue = value;
          },
        ),
        actions: [
          TextButton(
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => Navigator.of(context).pop(newValue),
          ),
        ],
      ),
    );

    // Update Firestore jika nilai baru tidak kosong
    if (newValue.trim().isNotEmpty) {
      await usersCollection.doc(currentUser.email).update({field: newValue});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profil Page"),
        centerTitle: true,
        backgroundColor: Colors.grey[300],
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => Authpage(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("user")
              .doc(currentUser.email)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final userData = snapshot.data!.data() as Map<String, dynamic>;

              return ListView(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                children: [
                  SizedBox(height: 50),
                  Icon(
                    Icons.person,
                    size: 72,
                  ),
                  SizedBox(height: 10),
                  Text(
                    currentUser.email!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  SizedBox(height: 50),

                  Padding(
                    padding: const EdgeInsets.only(left: 25.0),
                    child: Text(
                      'My Details',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),

                  MyTextBox(
                    text: userData['username'],
                    sectionName: 'Nama Lengkap',
                    onPressed: () => editField('username'),
                  ),

                  MyTextBox(
                    text: userData['No Telp'],
                    sectionName: 'No Telp',
                    onPressed: () => editField('No Telp'),
                  ),

                  MyTextBox(
                    text: userData['alamat'],
                    sectionName: 'Alamat',
                    onPressed: () => editField('alamat'),
                  ),
                  SizedBox(height: 50),

                  Padding(
                    padding: const EdgeInsets.only(left: 25.0),
                    child: Text(
                      'DEVELOP BY',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),

                  // Profil 1
                  Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: AssetImage('assets/bimakk.jpg'), 
                          ),
                          SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bima Kaka Bani Adam', 
                                style: TextStyle(fontSize: 18),
                              ),
                              Text(
                                'NPM: 22082010007',
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  //profil 2
                  Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: AssetImage('assets/safir.jpg'), 
                          ),
                          SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Shafira Faiz Aulia Winanda', 
                                style: TextStyle(fontSize: 18),
                              ),
                              Text(
                                'NPM: 22082010044', 
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
