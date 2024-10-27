import 'dart:async';
import 'package:agro/consts/gambar.dart';
import 'package:flutter/material.dart';
import 'cart.dart';
import 'trs.dart';
import 'chat.dart';
import 'setting.dart';
import 'mystore.dart';
import 'product_detail.dart';

class Dashboard extends StatefulWidget {
  final List<Map<String, dynamic>>
      products; // Mengubah tipe dari String menjadi dynamic
  final String storeName;

  Dashboard({Key? key, required this.products, required this.storeName})
      : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String selectedCategory = 'Semua';
  int _currentIndex = 0;
  List<Map<String, dynamic>> cartItems = [];
  List<Map<String, dynamic>> allProducts = [];
  List<Map<String, dynamic>> displayedProducts = [];

  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";

  final List<String> images = [Slider1, Slider2, Slider3];

  late PageController _pageController;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    allProducts = widget.products; // Menggunakan parameter produk dari widget
    displayedProducts = List.from(allProducts);
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

    allProducts = [
      {
        'name': 'Kangkung',
        'category': 'Sayuran',
        'price': '\5000',
        'image': Cthproduk,
        'quantity': 1
      },
      {
        'name': 'Bayam',
        'category': 'Sayuran',
        'price': '\5000',
        'image': Cthproduk,
        'quantity': 1
      },
      {
        'name': 'Wortel',
        'category': 'Sayuran',
        'price': '\5000',
        'image': Cthproduk,
        'quantity': 1
      },
      {
        'name': 'Ganja',
        'category': 'Buah',
        'price': '\5000',
        'image': Cthproduk,
        'quantity': 1
      },
      {
        'name': 'Apel',
        'category': 'Buah',
        'price': '\5000',
        'image': Cthproduk,
        'quantity': 1
      },
      {
        'name': 'Duren',
        'category': 'Buah',
        'price': '\5000',
        'image': Cthproduk,
        'quantity': 1
      },
    ];

    displayedProducts = List.from(allProducts);

    _searchController.addListener(_filterProducts);
  }

  void _filterProducts() {
    setState(() {
      searchQuery = _searchController.text.toLowerCase();
      displayedProducts = allProducts.where((product) {
        final matchesSearch =
            product['name']?.toLowerCase().contains(searchQuery) ?? false;
        final matchesCategory = selectedCategory == 'Semua' ||
            product['category'] == selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
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
        backgroundColor: const Color.fromARGB(255, 42, 226, 42),
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
              MaterialPageRoute(builder: (context) => Chat(sellerName: '', initialMessages: [], initialChatWith: '',)),
                );
              },
            ),
            SizedBox(width: 10),
            IconButton(
              icon: Icon(Icons.settings, color: Colors.white),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Setting()));
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedCategory = 'Semua';
                          _filterProducts();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedCategory == 'Semua'
                            ? Colors.grey[800]
                            : Colors.green,
                      ),
                      child: Text('Semua'),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedCategory = 'Sayuran';
                          _filterProducts();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedCategory == 'Sayuran'
                            ? Colors.grey[800]
                            : Colors.green,
                      ),
                      child: Text('Sayuran'),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedCategory = 'Buah';
                          _filterProducts();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedCategory == 'Buah'
                            ? Colors.grey[800]
                            : Colors.green,
                      ),
                      child: Text('Buah'),
                    ),
                  ],
                ),
              ),
            ),
            _buildProductGrid(),
          ],
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

  Widget _buildWelcomeBanner() {
    return Container(
      height: 200,
      child: PageView.builder(
        controller: _pageController,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              Center(
                child: Image.asset(
                  images[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProductGrid() {
    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
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
                  product: product,
                  storeName: 'Nama Toko',
                  sellerName: 'Nama Penjual',
                  rating: 4.5,
                  onAddToCart: (Map<String, dynamic> product) {
                    setState(() {
                      if (!cartItems
                          .any((item) => item['name'] == product['name'])) {
                        cartItems.add(product);
                      }
                    });
                  },
                  initialMessages: [],
                ),
              ),
            );
          },
          child: Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Image.asset(
                    product['image']!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Column(
                    children: [
                      Text(
                        product['name']!,
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Rp ${product['price']!}',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToPage(int index) {
    switch (index) {
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Cart(cartItems: cartItems)),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Mystore()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Trs()),
        );
        break;
      default:
        break;
    }
  }
}
