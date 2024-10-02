import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'cart_item.dart';
import 'cart_item.dart';

class ItemConfirmPage extends StatefulWidget {
  final String cCustid;
  final String cItemid;
  final List<CartItem> cartItems; // List of CartItem

  ItemConfirmPage({required this.cCustid, required this.cItemid,required this.cartItems});

  @override
  _ItemConfirmPageState createState() => _ItemConfirmPageState();
}

class _ItemConfirmPageState extends State<ItemConfirmPage> {
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _extra1Controller = TextEditingController();
  final TextEditingController _extra2Controller = TextEditingController();
  final TextEditingController _extra3Controller = TextEditingController();

  bool _loading = false;
  String _message = '';

  // Function to send data to the PHP backend
  Future<void> confirmItem() async {
    final String apiUrl = 'https://your-api-url/item_confirm.php'; // Replace with your actual API URL

    setState(() {
      _loading = true;
      _message = '';
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'c_custid': widget.cCustid,
          'c_itemid': widget.cItemid,
          'c_qty': _qtyController.text,
          'c_rate': _rateController.text,
          'c_extra1': _extra1Controller.text,
          'c_extra2': _extra2Controller.text,
          'c_extra3': _extra3Controller.text,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          _message = jsonResponse['message'];
        });
      } else {
        setState(() {
          _message = 'Failed to add item: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _rateController.dispose();
    _extra1Controller.dispose();
    _extra2Controller.dispose();
    _extra3Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Item'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _qtyController,
              decoration: const InputDecoration(
                labelText: 'Quantity',
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _rateController,
              decoration: const InputDecoration(
                labelText: 'Rate',
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _extra1Controller,
              decoration: const InputDecoration(
                labelText: 'Extra 1',
              ),
            ),
            TextField(
              controller: _extra2Controller,
              decoration: const InputDecoration(
                labelText: 'Extra 2',
              ),
            ),
            TextField(
              controller: _extra3Controller,
              decoration: const InputDecoration(
                labelText: 'Extra 3',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : confirmItem,
              child: _loading
                  ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
                  : const Text('Confirm'),
            ),
            const SizedBox(height: 20),
            Text(
              _message,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
