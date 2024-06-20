import 'package:flutter/material.dart';
import 'package:cobaaja/komponen/fetch_data.dart'; // Assuming this fetches data correctly
import 'package:cobaaja/product_detail.dart'; // Import ProductDetailPage

class Favourite extends StatefulWidget {
  @override
  _FavouriteState createState() => _FavouriteState();
}

class _FavouriteState extends State<Favourite> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Simpan Product'),
        centerTitle: true,
        backgroundColor: Colors.grey[300],
      ),
      body: SafeArea(
        child: fetchData("users-favourite-items", onTap: (product) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailPage(product: product),
            ),
          );
        }),
      ),
    );
  }
}
