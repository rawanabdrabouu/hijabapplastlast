import 'package:flutter/material.dart';
import 'package:hijaby_app/models/product.dart';
import 'package:hijaby_app/screens/vendor/update_product_screen.dart';
import 'package:hijaby_app/services/RealtimeDatabaseService.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class ProductsScreen extends StatelessWidget {
  final RealtimeDatabaseService _realtimeDatabaseService = RealtimeDatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
      ),
      body: StreamBuilder<List<Product>>(
        stream: _realtimeDatabaseService.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final products = snapshot.data ?? [];
          return GridView.builder(
            padding: EdgeInsets.all(8.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 24.0, // Increased spacing between cards
              mainAxisSpacing: 24.0,  // Increased spacing between rows
              childAspectRatio: 0.65,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                          child: product.imageUrl.isNotEmpty
                              ? Image.network(
                                  product.imageUrl,
                                  fit: BoxFit.cover,
                                )
                              : Center(
                                  child: Icon(
                                    Icons.image,
                                    color: Colors.grey,
                                    size: 60,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        product.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        product.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 12.0), // Increased space between description and price
                      Row(
                        children: [
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Spacer(),
                          IconButton(
                            icon: Icon(Icons.discount, color: Colors.blue),
                            onPressed: () async {
                              final discount = await _showDiscountDialog(context);
                              if (discount != null) {
                                await _realtimeDatabaseService.applyDiscount(product.id, discount);
                                sendNotification('Discount Applied', 'A discount of $discount% has been applied to ${product.name}');
                              }
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UpdateProductScreen(product: product),
                                  ),
                                );
                              },
                              child: Text('Update'),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _deleteProduct(context, product.id),
                              child: Text('Delete'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Positioned(
            right: 16,
            bottom: 16,
            child: Container(
              width: 70,
              height: 70,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/add-product');
                },
                tooltip: 'Add a new product',
                child: Icon(Icons.add, size: 36),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Colors.pink, Colors.redAccent],
                  center: Alignment(-0.3, -0.5),
                  radius: 0.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Future<void> _deleteProduct(BuildContext context, String productId) async {
    try {
      await _realtimeDatabaseService.deleteProduct(productId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product deleted successfully')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete product: $error')),
      );
    }
  }

  Future<double?> _showDiscountDialog(BuildContext context) {
    final TextEditingController discountController = TextEditingController();
    return showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Discount'),
          content: TextField(
            controller: discountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: 'Discount %'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final discount = double.tryParse(discountController.text);
                if (discount != null && discount > 0) {
                  Navigator.of(context).pop(discount);
                } else {
                  // Show error message
                }
              },
              child: Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  void sendNotification(String title, String body) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'basic_channel',
        title: title,
        body: body,
      ),
    ).then((_) {
      print('Notification sent');
    }).catchError((error) {
      print('Error sending notification: $error');
    });
  }
}
