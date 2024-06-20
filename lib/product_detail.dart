// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductDetailPage extends StatefulWidget {
  final Map product;

  ProductDetailPage({required this.product});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late int _selectedTypeIndex;
  int _quantity = 1;
  int currentImage = 0;

  @override
  void initState() {
    super.initState();
    _selectedTypeIndex = 0; // Default to the first type
  }

  Future<void> addToFavourite() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    var currentUser = _auth.currentUser;
    CollectionReference _collectionRef = FirebaseFirestore.instance.collection("users-favourite-items");

    return _collectionRef
        .doc(currentUser!.email)
        .collection("items")
        .doc()
        .set({
          "name": widget.product["product-name"],
          "price": widget.product["product-price"],
          "images": widget.product["product-img"],
        })
        .then((value) => print("Added to favourite"));
  }

  void _toggleSaved() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final collectionRef = FirebaseFirestore.instance
          .collection('users-favourite-items')
          .doc(user.email)
          .collection('items')
          .where('name', isEqualTo: widget.product['product-name']);

      collectionRef.get().then((snapshot) {
        if (snapshot.docs.isEmpty) {
          addToFavourite();
        } else {
          print("Already Added");
        }
      });
    } else {
      print("User not logged in");
    }
  }

  void _changeType(int index) {
    setState(() {
      _selectedTypeIndex = index;
      currentImage = index; // Update the current image to the selected type
    });
  }

  void _decrementQuantity() {
    setState(() {
      if (_quantity > 1) {
        _quantity--;
      }
    });
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  Future<void> addToCart() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    var currentUser = _auth.currentUser;
    CollectionReference _collectionRef = FirebaseFirestore.instance.collection("users-cart-items");

    return _collectionRef
        .doc(currentUser!.email)
        .collection("items")
        .doc()
        .set({
          "name": widget.product["product-name"],
          "price": widget.product["product-price"],
          "images": widget.product["product-img"],
          "quantity": _quantity, // tambahkan jumlah barang yang dibeli
        })
        .then((value) => print("Added to cart"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 20), // Adjust bottom margin as needed
        child: FloatingActionButton.extended(
          onPressed: () {
            addToCart(); // Tambahkan produk ke keranjang
            print('Membeli $_quantity ${widget.product["product-name"]} sekarang!');
          },
          label: Text('CheckOut'),
          icon: Icon(Icons.shopping_cart),
          backgroundColor: Colors.green,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                title: Text(
                  'Detail Produk',
                  textAlign: TextAlign.center,
                ),
                // Hanya satu ikon kembali di sebelah kiri AppBar
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                floating: true,
                pinned: true,
                snap: true,
                backgroundColor: Colors.white,
                elevation: 0,
              ),
            ];
          },
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Slider gambar produk
                _buildImageSlider(),
                // Indikator gambar
                _buildImageIndicator(),
                // Detail produk
                _buildProductDetail(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSlider() {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.network(
            widget.product["product-img"][_selectedTypeIndex],
            fit: BoxFit.contain,
          ),
        ),
        StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("users-favourite-items")
              .doc(FirebaseAuth.instance.currentUser?.email)
              .collection("items")
              .where("name", isEqualTo: widget.product['product-name'])
              .snapshots(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return Align(
                alignment: Alignment.topRight,
                child: Icon(Icons.bookmark_border),
              );
            }
            return Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(
                  snapshot.data.docs.length == 0 ? Icons.bookmark_border : Icons.bookmark,
                ),
                onPressed: _toggleSaved,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildImageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.product["product-img"].length,
        (index) => AnimatedContainer(
          duration: Duration(milliseconds: 300),
          width: currentImage == index ? 15 : 8,
          height: 8,
          margin: EdgeInsets.only(right: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: currentImage == index ? Colors.black : Colors.transparent,
            border: Border.all(color: Colors.black),
          ),
          child: Image.network(
            widget.product["product-img"][index],
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildProductDetail() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(40),
          topLeft: Radius.circular(40),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.product["product-name"],
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            "Harga: Rp.${widget.product["product-price"].toStringAsFixed(2)}",
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 20),
          Text(
            "Jumlah yang akan dibeli:",
            style: TextStyle(fontSize: 20),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: _decrementQuantity,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Icon(Icons.remove, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Text(
                _quantity.toString(),
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(width: 10),
              GestureDetector(
                onTap: _incrementQuantity,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          Text(
            "Pilih Tipe Produk",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Wrap(
            spacing: 10.0,
            children: List.generate(
              widget.product["product-img"].length,
              (index) => GestureDetector(
                onTap: () {
                  _changeType(index);
                },
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _selectedTypeIndex == index ? Colors.blue : Colors.grey,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(widget.product["product-img"][index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Text(
            "Deskripsi Produk",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            widget.product["product-description"],
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.justify,
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}