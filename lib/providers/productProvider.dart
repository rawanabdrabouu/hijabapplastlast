import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:hijaby_app/models/product.dart';

class ProductProvider with ChangeNotifier {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref('products');

  Future<void> addProduct(Product product) async {
    await _databaseRef.child(product.id).set(product.toMap());
    notifyListeners();
  }

  Future<Product> fetchProductById(String id) async {
    try {
      final snapshot = await _databaseRef.child(id).get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        return Product.fromMap(data);
      } else {
        throw Exception('Product not found');
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateProduct(Product product) async {
    await _databaseRef.child(product.id).update(product.toMap());
    notifyListeners();
  }

  Stream<List<Product>> getProducts() {
    return _databaseRef.onValue.map((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        return data.entries.map((entry) {
          final productData = Map<String, dynamic>.from(entry.value);
          return Product.fromMap(productData);
        }).toList();
      } else {
        return [];
      }
    });
  }

  Future<void> deleteProduct(String productId) async {
    await _databaseRef.child(productId).remove();
    notifyListeners();
  }

  Future<void> addCommentToProduct(String productId, Comment comment) async {
    final product = await fetchProductById(productId);
    product.comments.add(comment);
    product.averageRating = _calculateAverageRating(product.comments);
    await updateProduct(product);
  }

  double _calculateAverageRating(List<Comment> comments) {
    if (comments.isEmpty) return 0.0;
    double totalRating = comments.fold(0, (sum, comment) => sum + comment.rating);
    return totalRating / comments.length;
  }
}
