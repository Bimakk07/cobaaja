// ignore_for_file: prefer_const_constructors, prefer_final_fields, use_key_in_widget_constructors, library_private_types_in_public_api, avoid_print, avoid_function_literals_in_foreach_calls, use_super_parameters, unnecessary_string_escapes

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Keranjang(),
    );
  }
}

class Keranjang extends StatefulWidget {
  @override
  _KeranjangState createState() => _KeranjangState();
}

class _KeranjangState extends State<Keranjang> {
  OverlayEntry? _overlayEntry;
  TextEditingController _discountController = TextEditingController();
  double _discount = 0.0;
  UserShippingAddress? _shippingAddress;

  @override
  void initState() {
    super.initState();
    _overlayEntry = null; // Initialize overlay entry as null
  }

  void _showPaymentSuccessOverlay(BuildContext context) {
    // Create overlay entry
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height / 2 - 50,
        left: 20,
        right: 20,
        child: Material(
          elevation: 4.0,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            height: 100,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                'Pembayaran Berhasil!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // Insert overlay entry into the overlay
    Overlay.of(context).insert(_overlayEntry!);

    // Simpan alamat pengiriman ke Firestore
    if (_shippingAddress != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.email)
          .collection('Alamat Pengiriman')
          .add(_shippingAddress!.toMap())
          .then((value) => print('Alamat pengiriman disimpan'))
          .catchError((error) => print('Gagal menyimpan alamat pengiriman: $error'));
    }

    // Schedule the removal of overlay after 2 seconds
    Future.delayed(Duration(seconds: 2), () {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  void _applyDiscount() {
    setState(() {
      if (_discountController.text == 'kaka ganteng') {
        _discount = 0.10; // Set 10% discount
      } else {
        _discount = 0.0; // No discount
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users-cart-items')
            .doc(FirebaseAuth.instance.currentUser!.email)
            .collection('items')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Keranjang kosong'));
          }

          double subtotal = 0.0;
          snapshot.data!.docs.forEach((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            int quantity = data['quantity'];
            double price = data['price'];
            subtotal += quantity * price;
          });
          double total = subtotal * (1 - _discount); //apply discount

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(16),
                  children: snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                    int quantity = data['quantity'];
                    double price = data['price'];
                    double totalPrice = quantity * price;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  bottomLeft: Radius.circular(20),
                                ),
                                image: DecorationImage(
                                  image: NetworkImage(data['images'][0]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['name'],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      '\Harga: Rp.${totalPrice.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () {
                                            FirebaseFirestore.instance
                                                .collection('users-cart-items')
                                                .doc(FirebaseAuth.instance.currentUser!.email)
                                                .collection('items')
                                                .doc(document.id)
                                                .delete()
                                                .then((value) => print('Item dihapus'))
                                                .catchError((error) =>
                                                    print('Gagal menghapus item: $error'));
                                          },
                                        ),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                int newQuantity = quantity - 1;
                                                if (newQuantity >= 1) {
                                                  FirebaseFirestore.instance
                                                      .collection('users-cart-items')
                                                      .doc(FirebaseAuth.instance.currentUser!.email)
                                                      .collection('items')
                                                      .doc(document.id)
                                                      .update({'quantity': newQuantity});
                                                }
                                              },
                                              child: const Icon(Icons.remove, size: 20),
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              quantity.toString(),
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            GestureDetector(
                                              onTap: () {
                                                int newQuantity = quantity + 1;
                                                FirebaseFirestore.instance
                                                    .collection('users-cart-items')
                                                    .doc(FirebaseAuth.instance.currentUser!.email)
                                                    .collection('items')
                                                    .doc(document.id)
                                                    .update({'quantity': newQuantity});
                                              },
                                              child: const Icon(Icons.add, size: 20),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ShippingAddressWidget(
                  onAddressSaved: (address) {
                    setState(() {
                      _shippingAddress = address;
                    });
                  },
                ),
              ),
              CheckOutBox(
                subtotal: subtotal,
                total: total,
                onApplyDiscount: _applyDiscount,
                discountController: _discountController,
                onCheckout: () {
                  if (_shippingAddress == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Mohon lengkapi alamat pengiriman terlebih dahulu')),
                    );
                  } else {
                    _showPaymentSuccessOverlay(context); // Show payment success overlay
                    // Simpan ke Firestore dengan menggunakan _shippingAddress
                    // Implementasikan logika checkout
                  }
                },
                discount: _discount,
              ),
            ],
          );
        },
      ),
    );
  }
}

class CheckOutBox extends StatelessWidget {
  const CheckOutBox({
    Key? key,
    required this.subtotal,
    required this.total,
    required this.onApplyDiscount,
    required this.discountController,
    required this.onCheckout,
    required this.discount,
  }) : super(key: key);

  final double subtotal;
  final double total;
  final VoidCallback onApplyDiscount;
  final TextEditingController discountController;
  final VoidCallback onCheckout;
  final double discount;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
                    boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: discountController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 15,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                hintText: "Masukkan Kode Diskon",
                hintStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
                suffixIcon: TextButton(
                  onPressed: onApplyDiscount,
                  child: const Text(
                    "Terapkan",
                    style: TextStyle(
                      color: Colors.green,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Rp.${(total * (1 - discount)).toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Spacer(), // Spacer untuk memberikan ruang tambahan
            ElevatedButton(
              onPressed: onCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 55),
              ),
              child: const Text(
                "Beli Sekarang",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShippingAddressWidget extends StatefulWidget {
  final void Function(UserShippingAddress) onAddressSaved;

  const ShippingAddressWidget({Key? key, required this.onAddressSaved}) : super(key: key);

  @override
  _ShippingAddressWidgetState createState() => _ShippingAddressWidgetState();
}

class _ShippingAddressWidgetState extends State<ShippingAddressWidget> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Alamat Pengiriman', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(labelText: 'Nama'),
        ),
        TextField(
          controller: _phoneController,
          decoration: InputDecoration(labelText: 'Nomor Telepon'),
          keyboardType: TextInputType.phone,
        ),
        TextField(
          controller: _addressController,
          decoration: InputDecoration(labelText: 'Alamat'),
          maxLines: 2,
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            // Simpan alamat pengiriman ke dalam objek UserShippingAddress
            UserShippingAddress address = UserShippingAddress(
              name: _nameController.text.trim(),
              phoneNumber: _phoneController.text.trim(),
              address: _addressController.text.trim(),
            );
            widget.onAddressSaved(address);
          },
          child: Text('Simpan Alamat Pengiriman'),
        ),
      ],
    );
  }
}

class UserShippingAddress {
  final String name;
  final String phoneNumber;
  final String address;

  UserShippingAddress({
    required this.name,
    required this.phoneNumber,
    required this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'address': address,
    };
  }
}
