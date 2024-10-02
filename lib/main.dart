import 'package:flutter/material.dart';
import 'item_detail_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Group Order Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List userData = []; // List to hold category data
  bool isLoading = true; // Loading state
  bool hasError = false; // Error state

  @override
  void initState() {
    super.initState();
    getRecord(); // Fetch categories on initialization
  }

  Future<void> getRecord() async {
    String uri = "https://swati.amisys.in/dashboard_api/view_item_group.php";

    try {
      var response = await http.get(Uri.parse(uri));
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse is List) {
          setState(() {
            userData = jsonResponse; // Assign fetched data to userData
            isLoading = false; // Update loading state to false
          });
        } else {
          setState(() {
            hasError = true; // Set error state if response is not a list
            isLoading = false; // Update loading state to false
          });
        }
      } else {
        setState(() {
          hasError = true; // Set error state for non-200 response
          isLoading = false; // Update loading state to false
        });
      }
    } catch (e) {
      print('Request error: $e');
      setState(() {
        hasError = true; // Set error state for exceptions
        isLoading = false; // Update loading state to false
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text('Dashboard'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator
          : hasError
          ? const Center(child: Text('Error fetching categories')) // Show error message
          : Padding(
        padding: const EdgeInsets.all(10.0),
        child: userData.isEmpty
            ? const Center(child: Text('No data available'))
            : GridView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: userData.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 5,
            crossAxisSpacing: 5,
            childAspectRatio: 0.6,
          ),
          itemBuilder: (context, index) {
            var item = userData[index];
            return categoryCard(
              item['name'] ?? 'No Name',
              item['ig_id'] ?? '',
            );
          },
        ),
      ),
    );
  }

  Widget categoryCard(String name, String igId) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItemDetailScreen(
              ig_id: igId, // Pass the `igId` as a string
              groupName: name, // Pass the `name` as the group name
            ),
          ),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ItemDetailScreen(
                      ig_id: igId, // Pass the correct parameters here as well
                      groupName: name,
                    ),
                  ),
                );
              },
              child: Container(
                height: 80,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/img.jpg'), // Hardcoded asset image
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
