import 'package:flutter/material.dart';
import 'cart_item.dart';

class selectedItemDetails extends StatelessWidget {
  final CartItem cartItem;

  const selectedItemDetails({super.key,  required this.cartItem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(cartItem.name),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                cartItem.imageUrl.isNotEmpty
                    ? cartItem.imageUrl
                    : 'https://cdn.pixabay.com/photo/2017/03/19/20/19/ball-2157465_640.png', // Fallback image
                height: 200,
                width: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.image_not_supported, size: 150);
                },
              ),
              const SizedBox(height: 20),
              Text(
                cartItem.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Company: ${cartItem.company}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                'Opening Stock: ${cartItem.openingStock}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),

              Text(
                'Rate: ₹${cartItem.rate.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                'Quantity: ${cartItem.quantity}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Back to Cart'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
