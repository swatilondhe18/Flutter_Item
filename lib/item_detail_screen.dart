import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'cart_item.dart';
import 'package:item/CartPage.dart'; // Ensure this import is correct based on your structure

class ItemDetailScreen extends StatefulWidget {
  final String ig_id;
  final String groupName; // Add groupName parameter

  const ItemDetailScreen({super.key, required this.ig_id, required this.groupName});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  List orderDetails = [];
  List<CartItem> cartItems = []; // List to hold cart items
  bool isLoading = true; // Show loading spinner until data is fetched
  bool hasError = false; // Flag for error handling

  @override
  void initState() {
    super.initState();
    getOrderDetails();
  }

  Future<void> getOrderDetails() async {
    // API endpoint to get order details filtered by ig_id
    String uri = "http://swati.amisys.in/dashboard_api/view_item.php?ig_id=${widget.ig_id}"; // Pass ig_id to filter

    try {
      var response = await http.get(Uri.parse(uri));
      if (response.statusCode == 200) {
        try {
          var jsonResponse = jsonDecode(response.body);
          if (jsonResponse is List && jsonResponse.isNotEmpty) {
            // Filter the data based on ig_id
            setState(() {
              orderDetails = jsonResponse.where((order) => order['ig_id'] == widget.ig_id).toList();
              isLoading = false; // Data loaded
            });
          } else {
            setState(() {
              isLoading = false;
              hasError = true; // Handle if no details found
            });
          }
        } catch (e) {
          print('JSON decoding error: $e');
          setState(() {
            isLoading = false;
            hasError = true; // JSON decoding error
          });
        }
      } else {
        print('Request failed with status: ${response.statusCode}');
        setState(() {
          isLoading = false;
          hasError = true; // HTTP error
        });
      }
    } catch (e) {
      print('Request error: $e');
      setState(() {
        isLoading = false;
        hasError = true; // Request error
      });
    }
  }

  void _addToCart(CartItem item) {
    setState(() {
      cartItems.add(item); // Add item to the cart
    });
    // Show a confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item.name} added to cart')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text(widget.groupName),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              // Navigate to CartPage if there are items in the cart
              if (cartItems.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CartPage(
                      id: widget.ig_id, // Pass ig_id as a parameter
                      cartItems: cartItems,
                      // quantity: 1, // Remove this line if CartPage does not take a quantity parameter
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Your cart is empty')),
                );
              }
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Loading spinner
          : hasError
          ? const Center(child: Text('Error fetching order details'))
          : orderDetails.isEmpty
          ? const Center(child: Text('No order details available'))
          : ListView.builder(
            itemCount: orderDetails.length,
            itemBuilder: (context, index) {
            var order = orderDetails[index];
            return Card(
                margin: const EdgeInsets.all(10),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order['name'] ?? 'No Name Available',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Company: ${order['company'] ?? 'N/A'}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blueGrey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Opening Stock: ${order['openingstocks'] ?? 'N/A'}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blueGrey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(Icons.currency_rupee, color: Colors.green, size: 20,),
                          Text(
                            order['rate']?.toString() ?? '0.00',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 100),
                          InkWell(
                            onTap: () {
                              _addToCart(CartItem(
                                name: order['name'] ?? 'No Name',
                                company: order['company'] ?? 'N/A',
                                openingStock: order['openingstocks'] ?? '0',
                                rate: double.tryParse(order['rate'].toString()) ?? 0.0,
                                imageUrl: order['imageUrl'] ?? '',
                                quantity: 1// Add image URL if available
                              ));
                            },
                            child: const Icon(Icons.add_shopping_cart, color: Colors.orange),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                  const SizedBox(width: 5),
                  Container(
                    margin: EdgeInsets.only(right: 0.0),
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200], // Placeholder background color
                    ),
                    child: Image.network(
                      order['imageUrl'] ?? "https://images.pexels.com/photos/14345797/pexels-photo-14345797.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1", // Placeholder image
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: cartItems.isNotEmpty
          ? Padding(
        padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
             onPressed: () {
             Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CartPage(
                  id: widget.ig_id, // Pass ig_id as a parameter
                  cartItems: cartItems,

                ),
              ),
            );
          },
          child: const Text('View Cart'),
        ),
      )
          : null,
    );
  }
}
