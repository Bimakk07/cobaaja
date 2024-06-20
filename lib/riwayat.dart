// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cobaaja/riwayat/checkout.dart';
import 'package:flutter/material.dart';

class RiwayatPembelianPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'CheckOut',
            style: TextStyle(fontSize: 18), // Mengurangi ukuran teks
          ),
          centerTitle: true,
          backgroundColor: Colors.grey[300], 
        ),
        body: TabBarView(
          children: [
            Keranjang(),
          ],
        ),
      ),
    );
  }
}

