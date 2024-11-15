import 'dart:async';
import 'dart:convert';
import 'package:agro/consts/gambar.dart';
import 'package:agro/screens/setting_adm.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';

class AdminDashboard extends StatefulWidget {
  AdminDashboard({
    Key? key,
    required List products,
  }) : super(key: key);

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String selectedCategory = 'Semua';
  List<Map<String, dynamic>> allProducts = [];
  List<Map<String, dynamic>> displayedProducts = [];
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";

  final List<String> images = [Slider1, Slider2, Slider3, Slider4];
  late PageController _pageController;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _timer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      if (_pageController.hasClients) {
        int nextPage = _pageController.page!.toInt() + 1;
        if (nextPage >= images.length) {
          nextPage = 0;
        }
        _pageController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });

    _fetchProducts();
    _searchController.addListener(_filterProducts);
  }

  void _fetchProducts() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('products').get();

      setState(() {
        allProducts = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final productImage =
              data.containsKey('productImage') ? data['productImage'] : '';

          return {
            'id': doc.id,
            'name': data['name'] ?? 'Produk Tanpa Nama',
            'description': data['description'] ?? '',
            'price': data['price'] ?? 0,
            'category': data['category'] ?? 'Lainnya',
            'storeId': data['storeId'] ?? '',
            'sellerId': data['sellerId'] ?? '',
            'productImage': productImage,
          };
        }).toList();
        _filterProducts();
        displayedProducts = List.from(allProducts);
      });
    } catch (e) {
      print('Error mengambil produk: $e');
    }
  }

  void _filterProducts() {
    setState(() {
      displayedProducts = allProducts.where((product) {
        final matchesSearch = product['name']
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()) ??
            false;
        final matchesCategory = selectedCategory == 'Semua' ||
            product['category'] == selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  Future<Uint8List?> _getImageFromBase64(String base64String) async {
    try {
      return Base64Decoder().convert(base64String);
    } catch (e) {
      print('Error decoding base64 image: $e');
      return null;
    }
  }

  Future<void> _confirmDeleteProduct(
      String productId, String productName) async {
    bool? deleteConfirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Penghapusan'),
          content:
              Text('Apakah Anda yakin ingin menghapus produk "$productName"?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (deleteConfirmed == true) {
      _deleteProduct(productId);
    }
  }

  Future<void> _deleteProduct(String productId) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .delete();
      setState(() {
        allProducts.removeWhere((product) => product['id'] == productId);
        displayedProducts.removeWhere((product) => product['id'] == productId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produk berhasil dihapus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus produk: $e')),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(168, 207, 69, 1),
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                  hintText: 'Cari Produk...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 10),
            IconButton(
              icon: Icon(Icons.settings, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingAdm()),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildWelcomeBanner(),
            SizedBox(height: 20),
            _buildCategoryButtons(),
            _buildProductGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      height: 200,
      child: PageView.builder(
        controller: _pageController,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Center(
            child: Image.asset(
              images[index],
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryButtons() {
  return Padding(
    padding: const EdgeInsets.all(6.0),
    child: Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCategoryButton('Semua'),
            SizedBox(width: 5),
            _buildCategoryButton('Sayuran'),
            SizedBox(width: 5),
            _buildCategoryButton('Buah'),
            SizedBox(width: 5),
            _buildCategoryButton('Hasil Ternak'),
            SizedBox(width: 5),
          ],
        ),
      ),
    ),
  );
}


  ElevatedButton _buildCategoryButton(String category) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedCategory = category;
          _filterProducts();
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedCategory == category
            ? Colors.grey[800]
            : Color.fromRGBO(168, 207, 69, 1),
      ),
      child: Text(category),
    );
  }

  Widget _buildProductGrid() {
    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.8,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: displayedProducts.length,
      itemBuilder: (context, index) {
        final product = displayedProducts[index];

        return Stack(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              onPressed: () {},
              child: Column(
                children: [
                  SizedBox(height: 8),
                  if (product['productImage'] != null &&
                      product['productImage'].isNotEmpty)
                    FutureBuilder<Uint8List?>(
                      future: _getImageFromBase64(product['productImage']),
                      builder: (context, imageSnapshot) {
                        if (imageSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (imageSnapshot.hasError ||
                            imageSnapshot.data == null) {
                          return Center(
                              child: Icon(Icons.image, color: Colors.grey));
                        }
                        return Container(
                          width: double.infinity,
                          height: 100,
                          child: Image.memory(
                            imageSnapshot.data!,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    )
                  else
                    Icon(Icons.image, color: Colors.grey),
                  Text(
                    product['name'],
                    style: TextStyle(color: Colors.black),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Rp ${product['price']}',
                    style: TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmDeleteProduct(
                  product['id'],
                  product['name'],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
