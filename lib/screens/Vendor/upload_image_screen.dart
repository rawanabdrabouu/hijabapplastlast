import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hijaby_app/models/product.dart';
import 'package:hijaby_app/providers/ProductProvider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UploadImageScreen extends StatelessWidget {
  final String productId;

  const UploadImageScreen({Key? key, required this.productId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Upload Image"),
        ),
        body: FutureBuilder<Product?>(
          future: Provider.of<ProductProvider>(context, listen: false)
              .fetchProductById(productId),
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
                      product.imageUrl.isNotEmpty
                          ? Image.network(product.imageUrl)
                          : const Text('No image available'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          _pickAndUploadImage(context, product);
                        },
                        child: const Text('Upload Image'),
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

  Future<void> _pickAndUploadImage(
      BuildContext context, Product product) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      // Generate a valid Firebase key
      String validKey = FirebaseDatabase.instance.reference().push().key!;

      // Upload image to Firebase Storage using the valid key
      String imageUrl;
      final storageReference =
          FirebaseStorage.instance.ref().child('products/$validKey.jpg');
      final uploadTask = storageReference.putFile(imageFile);
      final snapshot = await uploadTask;
      imageUrl = await snapshot.ref.getDownloadURL();

      // Update product with image URL
      product = Product(
        id: product.id,
        name: product.name,
        description: product.description,
        price: product.price,
        imageUrl: imageUrl,
        category: product.category,
        stock: product.stock,
      );

      await Provider.of<ProductProvider>(context, listen: false)
          .updateProduct(product);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image uploaded successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected')),
      );
    }
  }
}
