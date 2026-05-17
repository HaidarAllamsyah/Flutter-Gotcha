class MenuModel {
  final String menuId;
  final String name;
  final double price;
  final String category;
  int stock;
  final String description;
  final String imageBase64;
  final String imagePath;
  final String imageUrl; // ← gambar dari internet

  MenuModel({
    required this.menuId,
    required this.name,
    required this.price,
    required this.category,
    required this.stock,
    required this.description,
    this.imageBase64 = '',
    this.imagePath = '',
    this.imageUrl = '',
  });

  factory MenuModel.fromMap(Map<String, dynamic> map, String id) {
    return MenuModel(
      menuId: id,
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      category: map['category'] ?? 'food',
      stock: map['stock'] ?? 0,
      description: map['description'] ?? '',
      imageBase64: map['imageBase64'] ?? '',
      imagePath: map['imagePath'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'category': category,
      'stock': stock,
      'description': description,
      'imageBase64': imageBase64,
      'imagePath': imagePath,
      'imageUrl': imageUrl,
    };
  }

  bool get isAvailable => stock > 0;
  bool get isDrink => category == 'drink';

  // Prioritas: base64 (upload admin) → imageUrl (internet) → imagePath (assets) → emoji
  bool get hasImage =>
      imageBase64.isNotEmpty || imageUrl.isNotEmpty || imagePath.isNotEmpty;
}