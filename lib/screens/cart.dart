import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'mystore.dart';
import 'trs.dart';
import 'payment.dart';

class Cart extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;

  Cart({required this.cartItems});

  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    double totalPrice = _calculateTotalPrice();

    return Scaffold(
      appBar: AppBar(
        title: Text('Keranjang'),
        backgroundColor: const Color.fromARGB(255, 42, 226, 42),
        automaticallyImplyLeading: false,
      ),
      body: widget.cartItems.isNotEmpty
          ? Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.cartItems.length,
                    itemBuilder: (context, index) {
                      var item = widget.cartItems[index];

                      String name = item['name'] ?? 'Nama produk tidak tersedia';
                      double price = item['price'] != null
                          ? double.tryParse(item['price'].toString().replaceAll('\Rp', '')) ?? 0.0
                          : 0.0;
                      int quantity = item['quantity'] ?? 1;

                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            item['image'] != null
                                ? Image.network(
                                    item['image'],
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  )
                                : Icon(Icons.image_not_supported, size: 80),
                            SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Harga: \Rp${price}',
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.remove),
                                      onPressed: () {
                                        setState(() {
                                          if (quantity > 1) {
                                            item['quantity'] -= 1;
                                          }
                                        });
                                      },
                                    ),
                                    Text('$quantity'),
                                    IconButton(
                                      icon: Icon(Icons.add),
                                      onPressed: () {
                                        setState(() {
                                          item['quantity'] += 1;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Spacer(),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  widget.cartItems.removeAt(index);
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('$name dihapus dari keranjang'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Total: \Rp${totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Payment(totalPrice: totalPrice, productName: '',)),
                    );
                  },
                  child: Text('Beli'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            )
          : Center(
              child: Text(
                'Keranjang Anda kosong',
                style: TextStyle(fontSize: 18),
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Dashboard',
            backgroundColor: Color.fromARGB(255, 42, 226, 42),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Pesanan',
            backgroundColor: Color.fromARGB(255, 42, 226, 42),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Toko Saya',
            backgroundColor: Color.fromARGB(255, 42, 226, 42),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Transaksi',
            backgroundColor: Color.fromARGB(255, 42, 226, 42),
          ),
        ],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.blueGrey,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
          _navigateToPage(index);
        },
      ),
    );
  }

  double _calculateTotalPrice() {
    double totalPrice = 0.0;
    for (var item in widget.cartItems) {
      if (item['price'] != null && item['quantity'] != null) {
        try {
          double itemPrice = double.tryParse(item['price'].toString().replaceAll('\$', '')) ?? 0.0;
          totalPrice += itemPrice * item['quantity'];
        } catch (e) {
          print('Error parsing price: ${item['price']}');
        }
      }
    }
    return totalPrice;
  }

  void _navigateToPage(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Dashboard(products: [], storeName: '',)),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Mystore()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Trs()),
        );
        break;
    }
  }
}
