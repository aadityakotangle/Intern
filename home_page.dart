import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_product.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'product.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Product> products = [];
  List<Product> accessories = [];
  List<Product> filteredProducts = [];
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final productsString = prefs.getString('products') ?? '[]';
    final productList = (jsonDecode(productsString) as List)
        .map((e) => Product.fromJson(e))
        .toList();

    setState(() {
      products = productList.where((p) => p.category == 'Product').toList();
      accessories = productList.where((p) => p.category == 'Accessory').toList();
      filteredProducts = products;
    });
  }

  void _filterProducts(String query) {
    setState(() {
      filteredProducts = products
          .where((product) =>
          product.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _deleteProduct(int index, String category) async {
    setState(() {
      if (category == 'Product') {
        products.removeAt(index);
      } else {
        accessories.removeAt(index);
      }
      filteredProducts = products;
    });

    final prefs = await SharedPreferences.getInstance();
    final allProducts = products + accessories;
    prefs.setString('products', jsonEncode(allProducts));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hi-Fi Shop & Service'),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.clear : Icons.search),
            onPressed: () {
              setState(() {
                if (isSearching) {
                  searchController.clear();
                  filteredProducts = products;
                }
                isSearching = !isSearching;
              });
            },
          ),
        ],
        bottom: isSearching
            ? PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search Products...',
                border: InputBorder.none,
              ),
              onChanged: _filterProducts,
              autofocus: true,
            ),
          ),
        )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Audio shop on Rustaveli Ave 57.\nThis shop offers both products and services.',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 20),
            _buildSectionHeader('Products', products.length),
            _buildProductGrid(products, 'Product'),
            SizedBox(height: 20),
            _buildSectionHeader('Accessories', accessories.length),
            _buildProductGrid(accessories, 'Accessory'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => AddProductPage()));
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$title $count',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        TextButton(onPressed: () {}, child: Text('Show all')),
      ],
    );
  }

  Widget _buildProductGrid(List<Product> products, String category) {
    return products.isEmpty
        ? Center(child: Text('No $category Found'))
        : GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.7,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    _displayImage(products[index].imagePath),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () =>
                            _deleteProduct(index, category),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  products[index].name,
                  style: TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  '\$${products[index].price}',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Method to display the product image depending on platform
  Widget _displayImage(String imagePath) {
    if (kIsWeb) {
      return imagePath.isNotEmpty
          ? Image.memory(
        base64Decode(imagePath),
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      )
          : Icon(Icons.image, size: 50);
    } else {
      return imagePath.isNotEmpty
          ? Image.file(
        File(imagePath),
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      )
          : Icon(Icons.image, size: 50);
    }
  }
}
