class MenuModel {
  final String menuId;
  final String name;
  final double price;
  final String category;
  int stock;
  final String description;
  final String imageBase64;
  final String imagePath; // untuk assets lokal

  MenuModel({
    required this.menuId,
    required this.name,
    required this.price,
    required this.category,
    required this.stock,
    required this.description,
    this.imageBase64 = '',
    this.imagePath = '',
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
    };
  }

  bool get isAvailable => stock > 0;

  // Apakah menu ini minuman (bisa dapat kustomisasi matcha)
  bool get isDrink => category == 'drink';
}