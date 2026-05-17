import 'package:flutter/material.dart';
import '../models/menu_model.dart';
import '../models/cart_item_model.dart';
import '../services/firestore_service.dart';

class CartProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<CartItemModel> _items = [];
  String _userId = '';

  List<CartItemModel> get items => _items;

  double get totalPrice =>
      _items.fold(0, (sum, item) => sum + item.totalPrice);

  int get totalItems =>
      _items.fold(0, (sum, item) => sum + item.quantity);

  void listenCart(String userId) {
    _userId = userId;
    _firestoreService.getCart(userId).listen((cartItems) {
      _items = cartItems
          .map((i) => CartItemModel.fromMap(i))
          .toList();
      notifyListeners();
    });
  }

  Future<void> addToCart(MenuModel menu, {
    String matchaGrade = 'culinary',
    int matchaLevel = 3,
    String sugarLevel = 'normal',
    String iceLevel = 'normal',
    int quantity = 1,
  }) async {
    // Cek apakah item dengan kustomisasi sama sudah ada
    final idx = _items.indexWhere((i) =>
        i.menuId == menu.menuId &&
        i.matchaGrade == matchaGrade &&
        i.matchaLevel == matchaLevel &&
        i.sugarLevel == sugarLevel &&
        i.iceLevel == iceLevel);

    if (idx >= 0) {
      _items[idx].quantity += quantity;
    } else {
      _items.add(CartItemModel(
        menuId: menu.menuId,
        name: menu.name,
        basePrice: menu.price,
        quantity: quantity,
        matchaGrade: matchaGrade,
        matchaLevel: matchaLevel,
        sugarLevel: sugarLevel,
        iceLevel: iceLevel,
      ));
    }

    await _saveCart();
    notifyListeners();
  }

  Future<void> updateQuantity(int index, int qty) async {
    if (qty <= 0) {
      _items.removeAt(index);
    } else {
      _items[index].quantity = qty;
    }
    await _saveCart();
    notifyListeners();
  }

  Future<void> removeItem(int index) async {
    _items.removeAt(index);
    await _saveCart();
    notifyListeners();
  }

  Future<void> _saveCart() async {
    await _firestoreService.updateCart(
      _userId,
      _items.map((i) => i.toMap()).toList(),
    );
  }

  Future<void> clearCart() async {
    _items = [];
    await _firestoreService.clearCart(_userId);
    notifyListeners();
  }

  void reset() {
    _items = [];
    _userId = '';
    notifyListeners();
  }
}