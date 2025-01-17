import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:item/selectedItemDetails.dart';
import 'dart:convert';
import 'cart_item.dart'; // Assuming you have CartItem defined in cart_item.dart

class CartPage extends StatefulWidget {
  final List<CartItem> cartItems;
  final String id;

  CartPage({super.key, required this.cartItems, required this.id});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Method to handle adding items to the cart
  Future<void> addToCart(BuildContext context, String custId, CartItem item) async {
    final String url = 'https://swati.amisys.in/dashboard_api/cart.php'; // Update with your PHP endpoint

    final response = await http.post(
      Uri.parse(url),
      body: {
        'id': '1', // Assuming a quantity of 1 for simplicity
        'name': item.name,
        'company': item.company,
        'openingstocks': item.openingStock, // Add other extra fields as needed
        'rate': '',
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['status'] == 'success') {
        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'])),
        );
      } else {
        // Handle error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${responseData['message']}')),
        );
      }
    } else {
      // Handle HTTP error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('HTTP error: ${response.statusCode}')),
      );
    }
  }

  double _calculateTotalAmount() {
    double total = 0.0;
    for (var item in widget.cartItems) {
      total += item.rate * item.quantity; // Update the total amount calculation
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        backgroundColor: Colors.orange,
      ),
      body: widget.cartItems.isEmpty
          ? const Center(child: Text('No items in the cart!'))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.cartItems.length,
              itemBuilder: (context, index) {
                final cartItem = widget.cartItems[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: Image.network(
                      cartItem.imageUrl.isNotEmpty
                          ? cartItem.imageUrl
                          : 'https://cdn.pixabay.com/photo/2017/03/19/20/19/ball-2157465_640.png', // Fallback image
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image_not_supported);
                      },
                    ),
                    title: Text(
                      cartItem.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Text(
                          'Company: ${cartItem.company}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Stock: ${cartItem.openingStock}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Rate: ${cartItem.rate.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Quantity: ${cartItem.quantity}', // Display quantity
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    onTap: () {
                      // Navigate to the ItemDetailsPage when tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => selectedItemDetails(cartItem: cartItem),
                        ),
                      );
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              // Handle quantity decrease
                              if (cartItem.quantity > 1) {
                                // Only decrease if quantity is more than 1
                                cartItem.quantity--;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('${cartItem.name} quantity decreased')),
                                );
                              } else {
                                // Handle item removal if quantity is 1
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('${cartItem.name} removed from cart')),
                                );
                                // Remove the item from the cart
                                widget.cartItems.removeAt(index);
                              }
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              // Handle quantity increase
                              cartItem.quantity++;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${cartItem.name} quantity increased')),
                              );
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '₹${_calculateTotalAmount().toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Exit the cart...'),
          ),
          const SizedBox(height: 20),
        ],

      ),
    );
  }
}
