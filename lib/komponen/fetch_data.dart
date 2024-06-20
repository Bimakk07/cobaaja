// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Widget fetchData(String collectionName, {required Null Function(dynamic product) onTap}) {
  return StreamBuilder(
    stream: FirebaseFirestore.instance
        .collection(collectionName)
        .doc(FirebaseAuth.instance.currentUser!.email)
        .collection("items")
        .snapshots(),
    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
      if (snapshot.hasError) {
        return Center(
          child: Text("Something went wrong"),
        );
      }

      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      }

      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return Center(child: Text("No favourite items found."));
      }

      return ListView.builder(
        itemCount: snapshot.data!.docs.length,
        itemBuilder: (context, index) {
          DocumentSnapshot item = snapshot.data!.docs[index];
          List<dynamic> images = item['images'];

          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              leading: images.isNotEmpty
                  ? Image.network(
                      images[0], // Displaying the first image
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    )
                  : Container(width: 50, height: 50, color: Colors.grey), // Placeholder if no image
              title: Text(item['name']),
              subtitle: Text("Harga: Rp.${item['price'].toStringAsFixed(2)}"),
              trailing: GestureDetector(
                child: CircleAvatar(
                  child: Icon(Icons.remove_circle),
                ),
                onTap: () {
                  FirebaseFirestore.instance
                      .collection(collectionName)
                      .doc(FirebaseAuth.instance.currentUser!.email)
                      .collection("items")
                      .doc(item.id)
                      .delete();
                },
              ),
            ),
          );
        },
      );
    },
  );
}
