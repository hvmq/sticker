class Category {
  final String id;
  final String name;
  final String imagePath;
  final double price;

  const Category({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.price,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'].toString(),
      name: json['name'] as String,
      imagePath: json['image_path'] as String,
      price: double.tryParse(json['price'].toString()) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_path': imagePath,
      'price': price,
    };
  }
}