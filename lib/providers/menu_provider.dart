import 'package:flutter/material.dart';
import '../models/menu_model.dart';
import '../services/firestore_service.dart';

class MenuProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<MenuModel> _menus = [];
  bool _isLoading = false;

  List<MenuModel> get menus => _menus;
  bool get isLoading => _isLoading;

  List<MenuModel> getByCategory(String category) {
    if (category == 'all') return _menus;
    return _menus.where((m) => m.category == category).toList();
  }

  void listenMenus() {
    _isLoading = true;
    notifyListeners();

    _firestoreService.getMenus().listen((menuList) {
      _menus = menuList;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addMenu(MenuModel menu) async {
    await _firestoreService.addMenu(menu);
  }

  Future<void> updateMenu(MenuModel menu) async {
    await _firestoreService.updateMenu(menu);
  }

  Future<void> deleteMenu(String menuId) async {
    await _firestoreService.deleteMenu(menuId);
  }
}