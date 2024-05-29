import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hijaby_app/models/product.dart';
import 'package:hijaby_app/providers/productProvider.dart';
import 'package:hijaby_app/providers/cartProvider.dart';

class ProductDetailsScreen extends StatelessWidget {
  final String productId;

  const ProductDetailsScreen({Key? key, required this.productId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Product Details"),
        ),
        body: FutureBuilder<Product>(
          future: Provider.of<ProductProvider>(context, listen: false).fetchProductById(productId),
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
                      Image.network(product.imageUrl),
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
                      const SizedBox(height: 16),
                      Text(product.description),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Provider.of<CartProvider>(context, listen: false).addToCart(product, 1);
                        },
                        child: const Text('Add to Cart'),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
