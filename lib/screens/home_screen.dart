import 'package:flutter/material.dart';
import 'package:hijaby_app/models/product.dart';
import 'package:hijaby_app/screens/Vendor/ProductsScreen.dart';
import 'package:hijaby_app/services/RealtimeDatabaseService.dart';
import 'package:hijaby_app/screens/user_profile.dart';
import 'package:hijaby_app/screens/cartScreen.dart';
import 'package:hijaby_app/screens/detailedProducrScreen.dart';
import 'package:hijaby_app/screens/signInPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();

  static final List<String> categories = [
    "",
    "Scarfs",
    'Kaftan',
    'Cardigans',
    'Kimono',
    'Jacket',
    'Dresses',
    'Blouse',
    'Pants',
    'Skirt',
    'Shirt',
    'Bandanas'
  ];
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedCategory;
  String _searchTerm = '';
  final RealtimeDatabaseService _databaseService = RealtimeDatabaseService();
  var loginStatus = "";
  var loggedInEmail = "";
  var loggedInRole = "";

  void _onCategoryChanged(String? category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _onSearchChanged(String searchTerm) {
    setState(() {
      _searchTerm = searchTerm;
    });
  }

  Future<void> initializesharedPreferences() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    setState(() {
      loginStatus = _prefs.getBool('isLoggedIn').toString();
      print('login status is -> $loginStatus');

      loggedInEmail = _prefs.getString('email').toString();
      print('login email is -> $loggedInEmail');
    });
  }

  Future<void> getUserInfo() async {
    final url = Uri.parse('https://hijaby-app-808a5-default-rtdb.firebaseio.com/users.json');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        responseData.forEach((key, value) {
          if (value['email'] == loggedInEmail) {
            setState(() {
              loggedInRole = value['role'];
            });
          }
        });
      } else {
        print('Failed to get users data');
      }
    } catch (err) {
      print("Error: " + err.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    initializesharedPreferences();
    getUserInfo();
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (index) {
        case 0:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
          break;
        case 1:
          if (loginStatus == "true") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserProfile()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SignInPage()),
            );
          }
          break;
        case 2:
          if (loginStatus == "true") {
            SharedPreferences.getInstance().then((prefs) {
              prefs.clear();
              setState(() {
                loginStatus = "false";
                loggedInEmail = "";
              });
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => SignInPage()),
                (Route<dynamic> route) => false,
              );
            });
          }
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.webp',
              height: 32,
            ),
            SizedBox(width: 8),
            Text('Hijab Boutique'),
          ],
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 200,
                child: Image.asset(
                  'assets/images/banner.jpg',
                  fit: BoxFit.cover,
                  alignment: Alignment(-0.2, -0.5), // Adjust alignment to show the face
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Shop by Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: HomeScreen.categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    _onCategoryChanged(value);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),
              SizedBox(height: 16.0),
              Expanded(
                child: StreamBuilder<List<Product>>(
                  stream: _databaseService.getProducts(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    final products = snapshot.data ?? [];
                    final filteredProducts = products.where((product) {
                      final matchesCategory = _selectedCategory == null ||
                          _selectedCategory!.isEmpty ||
                          product.category == _selectedCategory;
                      final matchesSearch = _searchTerm.isEmpty ||
                          product.name.toLowerCase().contains(_searchTerm.toLowerCase());
                      return matchesCategory && matchesSearch;
                    }).toList();

                    if (filteredProducts.isEmpty) {
                      return Center(child: Text('No products found'));
                    }

                    return GridView.builder(
                      padding: EdgeInsets.all(16.0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailsScreen(productId: product.id),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(15.0),
                                    ),
                                    child: product.imageUrl.isNotEmpty
                                        ? Image.network(
                                            product.imageUrl,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                              if (loadingProgress == null) {
                                                return child;
                                              }
                                              return Center(
                                                child: CircularProgressIndicator(
                                                  value: loadingProgress.expectedTotalBytes != null
                                                      ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                                      : null,
                                                ),
                                              );
                                            },
                                            errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                                              return Center(
                                                child: Icon(
                                                  Icons.error,
                                                  color: Colors.red,
                                                ),
                                              );
                                            },
                                          )
                                        : Center(
                                            child: Icon(
                                              Icons.image,
                                              color: Colors.grey,
                                            ),
                                          ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4.0),
                                      Row(
                                        children: [
                                          Text(
                                            '\$${product.price.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: product.discount > 0 ? Colors.grey : Colors.green,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              decoration: product.discount > 0 ? TextDecoration.lineThrough : null,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (product.discount > 0)
                                        Column(
                                          children: [
                                            SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Text(
                                                  '\$${(product.price * (1 - product.discount / 100)).toStringAsFixed(2)}',
                                                  style: TextStyle(
                                                    color: Colors.green,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                SizedBox(width: 4),
                                                Icon(Icons.discount, color: Colors.red),
                                              ],
                                            ),
                                          ],
                                        ),
                                      SizedBox(height: 4.0),
                                      Row(
                                        children: [
                                          Icon(Icons.star, color: Colors.yellow, size: 16.0),
                                          Text('${product.averageRating}', style: TextStyle(fontSize: 14)),
                                        ],
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
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: loginStatus == "true" ? 'Profile' : 'Sign In',
          ),
          if (loginStatus == "true")
            BottomNavigationBarItem(
              icon: Icon(Icons.logout),
              label: 'Logout',
            ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.pink,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    if (loginStatus == "true") {
      if (loggedInRole == 'vendor') {
        return SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          backgroundColor: Colors.pink,
          overlayColor: Colors.black,
          overlayOpacity: 0.5,
          spacing: 10,
          spaceBetweenChildren: 10,
          children: [
            SpeedDialChild(
              child: Icon(Icons.add),
              label: 'Add Product',
              backgroundColor: Colors.green,
              onTap: () {
                Navigator.pushNamed(context, '/add-product');
              },
            ),
            SpeedDialChild(
              child: Icon(Icons.edit),
              label: 'Edit Product',
              backgroundColor: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductsScreen()),
                );
              },
            ),
          ],
        );
      } else {
        return FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CartScreen()),
            );
          },
          backgroundColor: Colors.pink,
          child: Icon(Icons.shopping_cart),
        );
      }
    }
    return Container();
  }
}
