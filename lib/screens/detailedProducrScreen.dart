import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:provider/provider.dart';
import 'package:hijaby_app/models/product.dart';
import 'package:hijaby_app/providers/productProvider.dart';
import 'package:hijaby_app/providers/cartProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


class ProductDetailsScreen extends StatefulWidget {
  final String productId;

  const ProductDetailsScreen({Key? key, required this.productId}) : super(key: key);

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final _commentController = TextEditingController();
  double _rating = 0.0;
  var loginStatus = "";
  var loggedInEmail = "";
  var loggedInRole = "";
  var loggedInName = "";
  
 @override

  void initState() {
    super.initState();
    initializesharedPreferences();
    getUserInfo();
  }
  Future<void> _submitComment(Product product) async {
    final newComment = Comment(
      userId: 'some_user_id', // Replace with actual user ID
      userName: loggedInName, // Replace with actual user name
      text: _commentController.text,
      rating: _rating,
    );

    try {
      await Provider.of<ProductProvider>(context, listen: false)
          .addCommentToProduct(widget.productId, newComment);

      setState(() {
        _commentController.clear();
        _rating = 0.0;
      });

      // Send notification
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id:  DateTime.now().millisecondsSinceEpoch.remainder(100000),
          channelKey: 'basic_channel',
          title: 'New Comment Added',
          body: 'Your comment on ${product.name} has been added successfully',
          largeIcon: 'assets/images/logo.webp', // Update the image path
 
        ),
      );

    } catch (error) {
      // Handle error, e.g., show a toast or a dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit comment: $error')),
      );
    }
  }

  Future<void> initializesharedPreferences() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    setState(() {
      loginStatus = _prefs.getBool('isLoggedIn').toString();
      print('login status is -> ${loginStatus}');

      loggedInEmail = _prefs.getString('email').toString();
      print('login email is -> ${loggedInEmail}');
    });
  }
   Future<void> getUserInfo() async {
    final url = Uri.parse('https://hijaby-app-808a5-default-rtdb.firebaseio.com/users.json');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        responseData.forEach((key, value) {
          print('logged role ->, ${loggedInRole}');
          if (value['email'] == loggedInEmail) {
            setState(() {
              loggedInRole = value['role'];
              loggedInName = value['name'];

              print('logged role ->, ${loggedInRole}');
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Details"),
      ),
      body: FutureBuilder<Product>(
        future: Provider.of<ProductProvider>(context, listen: false).fetchProductById(widget.productId),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Product not found'));
          } else {
            final product = snapshot.data!;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.network(
                        product.imageUrl,
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      product.name,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 20, color: Colors.green),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.yellow, size: 24.0),
                        const SizedBox(width: 4),
                        Text(
                          '${product.averageRating}',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      product.description,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Stock: ${product.stock}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Category: ${product.category}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Provider.of<CartProvider>(context, listen: false).addToCart(product, 1);
                        },
                        child: const Text('Add to Cart'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        labelText: 'Add a comment',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text('Rating:'),
                        Expanded(
                          child: Slider(
                            value: _rating,
                            onChanged: (newRating) {
                              setState(() {
                                _rating = newRating;
                              });
                            },
                            divisions: 5,
                            label: '$_rating',
                            min: 0,
                            max: 5,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _submitComment(product),
                        child: const Text('Submit Comment'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Comments:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: product.comments.length,
                      itemBuilder: (ctx, index) {
                        final comment = product.comments[index];
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: ListTile(
                            title: Text(comment.userName),
                            subtitle: Text(comment.text),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star, color: Colors.yellow, size: 16.0),
                                Text('${comment.rating}'),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
