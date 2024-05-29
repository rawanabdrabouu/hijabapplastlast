import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';

class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  FirebaseMessaging _fcm = FirebaseMessaging.instance;

  @override
  Future intialize() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message ){
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if(message.notification != null){
        print("Message also contained a notification: ${message.notification}");
      }
    });
    FirebaseMessaging.onBackgroundMessage(backgroundHandler);
    // Get the token
    await getToken();
  }

  void initState() {
    super.initState();
    FirebaseMessaging fbm = FirebaseMessaging.instance;
    fbm.requestPermission(); // only shows on ios
    fbm.subscribeToTopic("New Product Alert");
  }

  Future<void> backgroundHandler(RemoteMessage message) async {
    print('Handling a background message ${message.messageId}');
  }
  Future<String?> getToken() async {
    String? token = await _fcm.getToken();
    print('Token: $token');
    return token;
  }


  Future<List<dynamic>> fetchProducts() async {
    final url = Uri.parse('https://hijaby-app-808a5-default-rtdb.firebaseio.com/products.json');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final Map<String, dynamic> productsMap = json.decode(response.body);
      return productsMap.entries.map((entry) => {'id': entry.key, 'data': entry.value}).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<void> announceDiscount(String productId) async {
    // Implement the push notification logic here
    print('Announced discount for product: $productId');
    // Example: Send a push notification via Firebase Cloud Messaging
    final url = Uri.parse('https://hijaby-app-808a5-default-rtdb.firebaseio.com/send');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'to': '/topics/all',
        'notification': {
          'title': 'Discount Announcement',
          'body': 'A new discount is available for product $productId!',
        },
      }),
    );

    if (response.statusCode == 200) {
      print('Push notification sent successfully');
    } else {
      print('Failed to send push notification');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final products = snapshot.data!;
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
                  title: Text('Product Name: ${product['data']['name']} with Category: ${product['data']['category']}'),
                  subtitle: Text("description: ${product['data']['description']}, price: ${product['data']['price']}, stock: ${product['data']['stock']}"),
                  trailing: ElevatedButton(
                    onPressed: () {
                      print(product['id']);
                      announceDiscount(product['id']);
                    },
                    child: Text('Announce Discount'),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
