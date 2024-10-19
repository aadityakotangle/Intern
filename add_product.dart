import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'product.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' as html;
import 'dart:convert';

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  String _category = 'Product'; // Default to "Product"
  String? _imagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _category,
              items: [
                DropdownMenuItem(child: Text('Product'), value: 'Product'),
                DropdownMenuItem(child: Text('Accessory'), value: 'Accessory'),
              ],
              onChanged: (value) {
                setState(() {
                  _category = value!;
                });
              },
              decoration: InputDecoration(labelText: 'Category'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Product Image'),
            ),
            SizedBox(height: 20),
            _imagePath != null
                ? (kIsWeb ? Image.memory(base64Decode(_imagePath!.split(',').last))
                : Image.file(File(_imagePath!)))
                : Text('No image selected'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProduct,
              child: Text('Save Product'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    if (kIsWeb) {
      final picker = html.FileUploadInputElement()..accept = 'image/*';
      picker.click();

      picker.onChange.listen((event) {
        final file = picker.files?.first;
        final reader = html.FileReader();

        reader.readAsDataUrl(file!);
        reader.onLoadEnd.listen((event) {
          setState(() {
            _imagePath = reader.result as String; // Base64 string
          });
        });
      });
    } else {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imagePath = pickedFile.path;
        });
      }
    }
  }

  Future<void> _saveProduct() async {
    final name = _nameController.text;
    final price = double.tryParse(_priceController.text) ?? 0.0;

    if (name.isEmpty || price == 0 || _imagePath == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please fill all fields')));
      return;
    }

    final newProduct = Product(
      name: name,
      price: price,
      imagePath: _imagePath!,
      category: _category, // Providing the category here
    );

    final prefs = await SharedPreferences.getInstance();
    final productsString = prefs.getString('products') ?? '[]';
    final productList = (jsonDecode(productsString) as List)
        .map((e) => Product.fromJson(e))
        .toList();

    productList.add(newProduct);

    await prefs.setString('products', jsonEncode(productList));

    Navigator.pop(context);
  }
}
