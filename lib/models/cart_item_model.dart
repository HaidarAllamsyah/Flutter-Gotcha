class CartItemModel {
  final String menuId;
  final String name;
  final double basePrice;
  int quantity;

  // Kustomisasi minuman
  final String matchaGrade;    // 'culinary', 'premium', 'ceremonial'
  final int matchaLevel;       // 1-5
  final String sugarLevel;     // 'less', 'normal', 'extra'
  final String iceLevel;       // 'less', 'normal', 'extra'

  CartItemModel({
    required this.menuId,
    required this.name,
    required this.basePrice,
    this.quantity = 1,
    this.matchaGrade = 'culinary',
    this.matchaLevel = 3,
    this.sugarLevel = 'normal',
    this.iceLevel = 'normal',
  });

  // Harga tambahan berdasarkan grade
  double get gradeExtra {
    switch (matchaGrade) {
      case 'ceremonial': return 8000;
      case 'premium': return 4000;
      default: return 0;
    }
  }

  // Harga tambahan gula
  double get sugarExtra {
    return sugarLevel == 'extra' ? 2000 : 0;
  }

  // Harga per item (sudah include extra)
  double get pricePerItem => basePrice + gradeExtra + sugarExtra;

  // Total harga
  double get totalPrice => pricePerItem * quantity;

  // Konversi ke Map untuk disimpan ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'menuId': menuId,
      'name': name,
      'price': pricePerItem,
      'basePrice': basePrice,
      'quantity': quantity,
      'matchaGrade': matchaGrade,
      'matchaLevel': matchaLevel,
      'sugarLevel': sugarLevel,
      'iceLevel': iceLevel,
    };
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      menuId: map['menuId'] ?? '',
      name: map['name'] ?? '',
      basePrice: (map['basePrice'] ?? map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 1,
      matchaGrade: map['matchaGrade'] ?? 'culinary',
      matchaLevel: map['matchaLevel'] ?? 3,
      sugarLevel: map['sugarLevel'] ?? 'normal',
      iceLevel: map['iceLevel'] ?? 'normal',
    );
  }

  // Label ringkas untuk ditampilkan
  String get customizationLabel {
    final parts = <String>[];
    parts.add(_gradeLabel());
    parts.add('Lvl $matchaLevel');
    if (sugarLevel != 'normal') parts.add(_sugarLabel());
    if (iceLevel != 'normal') parts.add(_iceLabel());
    return parts.join(' · ');
  }

  String _gradeLabel() {
    switch (matchaGrade) {
      case 'ceremonial': return 'Ceremonial';
      case 'premium': return 'Premium';
      default: return 'Culinary';
    }
  }

  String _sugarLabel() {
    switch (sugarLevel) {
      case 'less': return 'Less Sugar';
      case 'extra': return 'Extra Sugar +2k';
      default: return 'Normal Sugar';
    }
  }

  String _iceLabel() {
    switch (iceLevel) {
      case 'less': return 'Less Ice';
      case 'extra': return 'Extra Ice';
      default: return 'Normal Ice';
    }
  }
}