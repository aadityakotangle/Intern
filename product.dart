class Product {
  final String name;
  final double price;
  final String imagePath;
  final String category; // Either 'Product' or 'Accessory'

  Product({required this.name, required this.price, required this.imagePath, required this.category});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'],
      price: json['price'],
      imagePath: json['imagePath'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'imagePath': imagePath,
      'category': category,
    };
  }
}
