import 'dart:async';
import 'dart:convert'; // Tambahkan import ini
import 'package:agro/consts/gambar.dart';
import 'package:agro/screens/chat/chatlist.dart';
import 'package:agro/screens/product_detail.dart';
import 'package:flutter/material.dart';
import 'cart.dart';
import 'trs.dart';
import 'setting.dart';
import 'mystore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';

class Dashboard extends StatefulWidget {
  Dashboard({
    Key? key,
    required List products,
  }) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String selectedCategory = 'Semua';
  int _currentIndex = 0;
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
      print(
          'Produk berhasil diambil: ${displayedProducts.length} produk ditemukan.');
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
              icon: Icon(Icons.chat_bubble_outline, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatList(),
                  ),
                );
              },
            ),
            SizedBox(width: 10),
            IconButton(
              icon: Icon(Icons.settings, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Setting()),
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
      bottomNavigationBar: _buildBottomNavigationBar(),
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

      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetail(
                productId: product['id'], // Mengoper ID produk yang dipilih
                onAddToCart: (Map<String, dynamic> item) {
                  // Tambahkan logika untuk menambahkan produk ke keranjang jika diperlukan
                },
                sellerName: product['sellerId'] ?? 'Nama Penjual',
                storeName: product['storeId'] ?? 'Nama Toko',
                product: product,
              ),
            ),
          );
        },
        child: SingleChildScrollView( // Membuat konten produk dapat di-scroll
          child: Column(
            children: [
              SizedBox(height: 8),
              // Menampilkan gambar produk di sini
              if (product['productImage'] != null &&
                  product['productImage'].isNotEmpty)
                FutureBuilder<Uint8List?>(
                  future: _getImageFromBase64(
                      product['productImage']), // Fungsi untuk mendekode Base64
                  builder: (context, imageSnapshot) {
                    if (imageSnapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (imageSnapshot.hasError || imageSnapshot.data == null) {
                      return Center(child: Icon(Icons.image, color: Colors.grey));
                    }
                    return Container(
                      width: double.infinity, // Lebar gambar mengikuti lebar kontainer
                      height: 100, // Atur tinggi sesuai kebutuhan
                      child: Image.memory(
                        imageSnapshot.data!,
                        fit: BoxFit.cover, // Mengisi seluruh kontainer
                      ),
                    );
                  },
                ),
              Text(
                product['name'],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Rp${product['price']}',
                style: TextStyle(color: Color.fromRGBO(168, 207, 69, 1)),
              ),
            ],
          ),
        ),
      );
    },
  );
}


  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Dashboard',
            backgroundColor: Color.fromRGBO(168, 207, 69, 1)),
        BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Pesanan',
            backgroundColor: Color.fromRGBO(168, 207, 69, 1)),
        BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Toko Saya',
            backgroundColor: Color.fromRGBO(168, 207, 69, 1)),
        BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Transaksi',
            backgroundColor: Color.fromRGBO(168, 207, 69, 1)),
      ],
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.blueGrey,
      onTap: (int index) {
        setState(() {
          _currentIndex = index;
          switch (_currentIndex) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => Dashboard(
                          products: [],
                        )),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => Cart(
                          userId: '',
                        )),
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
        });
      },
    );
  }
}
