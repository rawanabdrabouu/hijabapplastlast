import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hijaby_app/providers/cartProvider.dart';
import 'package:hijaby_app/screens/CreditCardPaymentScreen.dart';
import 'package:hijaby_app/widgets/PlatformWidgetandButton.dart';


class CheckoutScreen extends StatefulWidget {
  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPaymentMethod = 'Cash on Delivery';

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Payment Method:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Card(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Credit Card'),
                      leading: Radio<String>(
                        value: 'Credit Card',
                        groupValue: _selectedPaymentMethod,
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentMethod = value!;
                            if (_selectedPaymentMethod == 'Credit Card') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CreditCardPaymentScreen(
                                    onPaymentDetailsEntered: (cardNumber, expiryDate, cvv) {
                                      // Handle the card details here
                                      print('Card Number: $cardNumber');
                                      print('Expiry Date: $expiryDate');
                                      print('CVV: $cvv');
                                    },
                                  ),
                                ),
                              );
                            }
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text('PayPal'),
                      leading: Radio<String>(
                        value: 'PayPal',
                        groupValue: _selectedPaymentMethod,
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentMethod = value!;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text('Cash on Delivery'),
                      leading: Radio<String>(
                        value: 'Cash on Delivery',
                        groupValue: _selectedPaymentMethod,
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentMethod = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Estimated Delivery Time: 30-45 minutes',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              Text(
                'Total Price: \$${cartProvider.totalPrice.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                'Order Summary:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: cartProvider.cart.length,
                  itemBuilder: (context, index) {
                    final cartItem = cartProvider.cart[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        title: Text(cartItem['name']),
                        subtitle: Text(
                            'Quantity: ${cartItem['quantity']} - Price: \$${cartItem['price']}'),
                        trailing: Text(
                            'Total: \$${(cartItem['quantity'] * cartItem['price']).toStringAsFixed(2)}'),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text('Order Confirmed'),
                        content: Text(
                            'Your order has been confirmed and is being processed.'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('OK'),
                            onPressed: () {
                              Navigator.of(ctx).pop();
                              cartProvider.clearCart();
                              Navigator.of(context).popUntil((route) => route.isFirst);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                    textStyle: TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('Confirm Order'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
