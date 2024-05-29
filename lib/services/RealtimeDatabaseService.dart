import 'package:firebase_database/firebase_database.dart';
import 'package:hijaby_app/models/product.dart';

class RealtimeDatabaseService {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref('products');

  Stream<List<Product>> getProducts() {
    final Stream<DatabaseEvent> stream = _databaseRef.onValue;
    return stream.map((DatabaseEvent event) {
      final List<Product> products = [];
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        data.forEach((key, value) {
          products.add(Product.fromMap(Map<String, dynamic>.from(value)));
        });
      }
      return products;
    });
  }

  Future<void> addProduct(Product product) async {
    await _databaseRef.child(product.id).set(product.toMap());
  }

  Future<void> updateProduct(Product product) async {
    await _databaseRef.child(product.id).update(product.toMap());
  }

  Future<void> deleteProduct(String productId) async {
    await _databaseRef.child(productId).remove();
  }

  Future<Product?> getProductById(String id) async {
    try {
      DatabaseEvent event = await _databaseRef.child(id).once();
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.exists) {
        return Product.fromMap(Map<String, dynamic>.from(snapshot.value as Map));
      } else {
        return null;
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> addCommentToProduct(String productId, Comment comment) async {
    final productSnapshot = await _databaseRef.child(productId).get();
    if (productSnapshot.exists) {
      final productMap = productSnapshot.value as Map<dynamic, dynamic>;
      final product = Product.fromMap(Map<String, dynamic>.from(productMap));

      final newComments = List<Comment>.from(product.comments)..add(comment);
      final newAverageRating = newComments.fold(0.0, (sum, comment) => sum + comment.rating) / newComments.length;

      final updatedProduct = Product(
        id: product.id,
        name: product.name,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        category: product.category,
        stock: product.stock,
        averageRating: newAverageRating,
        comments: newComments,
        discount: product.discount, // Ensure discount is maintained
      );

      await _databaseRef.child(productId).set(updatedProduct.toJson());
    }
  }

  Future<void> addToCart(Product product) async {
    await _databaseRef.child('cart').child(product.id).set(product.toMap());
  }

  Future<void> removeFromCart(String productId) async {
    await _databaseRef.child('cart').child(productId).remove();
  }

  Stream<List<Product>> getCartProducts() {
    Query query = _databaseRef.child('cart');

    return query.onValue.map((event) {
      final Map<dynamic, dynamic>? cartMap = event.snapshot.value as Map<dynamic, dynamic>?;
      if (cartMap != null) {
        return cartMap.values
            .map((e) => Product.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList();
      } else {
        return <Product>[];
      }
    });
  }
  
   Future<void> applyDiscount(String productId, double discount) async {
    try {
      final productSnapshot = await _databaseRef.child(productId).get();
      if (productSnapshot.exists) {
        final productMap = productSnapshot.value as Map<dynamic, dynamic>;
        final product = Product.fromMap(Map<String, dynamic>.from(productMap));

        // Calculate the new price based on the discount
        final newPrice = product.price * (1 - discount / 100);

        final updatedProduct = Product(
          id: product.id,
          name: product.name,
          description: product.description,
          price: newPrice, // Apply the new discounted price
          imageUrl: product.imageUrl,
          category: product.category,
          stock: product.stock,
          averageRating: product.averageRating,
          comments: product.comments,
          discount: discount, // Apply the discount
        );

        await _databaseRef.child(productId).update(updatedProduct.toMap());
      }
    } catch (error) {
      throw error;
    }
  }
}