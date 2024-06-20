// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, library_private_types_in_public_api, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cobaaja/product_detail.dart';

class BerandaPage extends StatefulWidget {
  @override
  _BerandaPageState createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  List<String> _carouselImages = [];
  var _dotPosition = 0;
  List _products = [];
  List _filteredProducts = [];
  var _firestoreInstance = FirebaseFirestore.instance;

  fetchCarouselImages() async {
    QuerySnapshot qn = await _firestoreInstance.collection("carousel-slider").get();
    setState(() {
      for (int i = 0; i < qn.docs.length; i++) {
        _carouselImages.add(qn.docs[i]["img-path"]);
      }
    });
    return qn.docs;
  }

  fetchProducts() async {
    QuerySnapshot qn = await _firestoreInstance.collection("products").get();
    setState(() {
      _products = qn.docs.map((doc) => doc.data()).toList();
      _filteredProducts = _products;
    });
    return qn.docs;
  }

  _searchProducts(String query) {
    List filteredList = _products.where((product) {
      return product["product-name"].toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredProducts = filteredList;
    });
  }

  @override
  void initState() {
    fetchCarouselImages();
    fetchProducts();
    super.initState();
  }

  void _navigateToProductDetail(Map product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Halo, Selamat Datang sobat tani',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 50.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: "Cari Produk",
                            hintStyle: TextStyle(fontSize: 15.sp),
                            border: InputBorder.none,
                            suffixIcon: Icon(Icons.search),
                            contentPadding: EdgeInsets.symmetric(vertical: 15.h),
                          ),
                          onChanged: (value) {
                            _searchProducts(value);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              AspectRatio(
                aspectRatio: screenSize.width > 600 ? 3 : 2,
                child: CarouselSlider(
                  items: _carouselImages.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          image: DecorationImage(
                            image: NetworkImage(item),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                  ).toList(),
                  options: CarouselOptions(
                    autoPlay: true,
                    enlargeCenterPage: true,
                    viewportFraction: 0.8,
                    enlargeStrategy: CenterPageEnlargeStrategy.height,
                    onPageChanged: (val, reason) {
                      setState(() {
                        _dotPosition = val;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              DotsIndicator(
                dotsCount: _carouselImages.isEmpty ? 1 : _carouselImages.length,
                position: _dotPosition.toDouble(),
                decorator: DotsDecorator(
                  activeColor: Color.fromARGB(255, 0, 202, 71),
                  color: Color.fromARGB(255, 0, 202, 71).withOpacity(0.5),
                  spacing: EdgeInsets.all(2),
                  activeSize: Size(8, 8),
                  size: Size(6, 6),
                ),
              ),
              SizedBox(height: 10.h),
              Expanded(
                child: GridView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: _filteredProducts.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: screenSize.width > 600 ? 4 : 2,
                    childAspectRatio: 0.7,
                  ),
                  itemBuilder: (_, index) {
                    var product = _filteredProducts[index];
                    return GestureDetector(
                      onTap: () {
                        _navigateToProductDetail(product);
                      },
                      child: Card(
                        elevation: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AspectRatio(
                              aspectRatio: 1,
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8.0),
                                  topRight: Radius.circular(8.0),
                                ),
                                child: Image.network(
                                  product["product-img"][0],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${product["product-name"]}",
                                    style: TextStyle(
                                      fontSize: screenSize.width > 600 ? 16.sp : 14.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    "Harga: Rp.${product["product-price"].toStringAsFixed(2)}",
                                    style: TextStyle(
                                      fontSize: screenSize.width > 600 ? 14.sp : 12.sp,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
