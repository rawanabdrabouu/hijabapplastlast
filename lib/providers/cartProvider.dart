import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';
import 'package:hijaby_app/models/product.dart'; // Ensure you have imported the correct path to your Product class

class CartProvider with ChangeNotifier {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref("cart");
  List<Map<String, dynamic>> _cart = [];

  CartProvider() {
    fetchCartProducts();
  }

  List<Map<String, dynamic>> get cart => _cart;

  double get totalPrice => _cart.fold(0, (sum, item) => sum + ((item['price'] ?? 0) * (item['quantity'] ?? 0)));

  bool get isCartEmpty => _cart.isEmpty;

  Future<void> addToCart(Product product, int quantity) async {
    try {
      // Fetch the current state of the cart from the database
      await fetchCartProducts();

      // Check if the product already exists in the cart
      var existingCartItemIndex = _cart.indexWhere((item) => item['productId'] == product.id);
      if (existingCartItemIndex != -1) {
        // Product exists, update quantity
        var existingCartItem = _cart[existingCartItemIndex];
        int newQuantity = existingCartItem['quantity'] + quantity;
        _cart[existingCartItemIndex]['quantity'] = newQuantity;

        await _databaseRef.child(existingCartItem['id']).update({'quantity': newQuantity});
      } else {
        // Product does not exist, add new item
        final String cartId = Uuid().v4();
        final Map<String, dynamic> cartItem = {
          'id': cartId,
          'productId': product.id,
          'name': product.name,
          'price': product.price,
          'quantity': quantity,
          'imageUrl': product.imageUrl, // Assuming your Product model has imageUrl field
        };
        await _databaseRef.child(cartId).set(cartItem);
        _cart.add(cartItem);
      }
      notifyListeners();
    } catch (error) {
      print('Failed to add to cart: $error');
    }
  }

  Future<void> removeItem(String id) async {
    try {
      await _databaseRef.child(id).remove();
      _cart.removeWhere((item) => item['id'] == id);
      notifyListeners();
    } catch (error) {
      print('Failed to remove item: $error');
    }
  }

  Future<void> updateQuantity(String id, int newQuantity) async {
    if (newQuantity < 1) {
      await removeItem(id);
    } else {
      var index = _cart.indexWhere((item) => item['id'] == id);
      if (index != -1) {
        _cart[index]['quantity'] = newQuantity;
        try {
          await _databaseRef.child(id).update({'quantity': newQuantity});
          notifyListeners();
        } catch (error) {
          print('Failed to update quantity: $error');
        }
      }
    }
  }

  Future<String?> fetchCartProducts() async {
    try {
      DataSnapshot snapshot = await _databaseRef.get();
      final Map<dynamic, dynamic>? cartItemsMap = snapshot.value as Map<dynamic, dynamic>?;
      if (cartItemsMap == null || cartItemsMap.isEmpty) {
        _cart = [];
        notifyListeners();
        return 'The cart is empty';
      }

      _cart = cartItemsMap.values.map((e) => Map<String, dynamic>.from(e)).toList();
      print('Cart items fetched: $_cart');
      notifyListeners();
      return null;
    } catch (err) {
      print('Failed to load cart items: $err');
      return 'Failed to load cart items';
    }
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }
}
