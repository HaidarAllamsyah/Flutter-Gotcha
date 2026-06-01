import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/menu_model.dart';
import '../models/order_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── MENU ───────────────────────────────────────────

  Stream<List<MenuModel>> getMenus() {
    return _db.collection('menus').snapshots().map((snap) =>
        snap.docs.map((d) => MenuModel.fromMap(d.data(), d.id)).toList());
  }

  Future<void> addMenu(MenuModel menu) async {
    await _db.collection('menus').add({
      ...menu.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateMenu(MenuModel menu) async {
    await _db.collection('menus').doc(menu.menuId).update(menu.toMap());
  }

  Future<void> deleteMenu(String menuId) async {
    await _db.collection('menus').doc(menuId).delete();
  }

  Future<void> updateStock(String menuId, int delta) async {
    final doc = await _db.collection('menus').doc(menuId).get();
    final currentStock = doc.data()?['stock'] ?? 0;
    final newStock = currentStock + delta;
    await _db
        .collection('menus')
        .doc(menuId)
        .update({'stock': newStock < 0 ? 0 : newStock});
  }

  // ─── CART ───────────────────────────────────────────

  Stream<List<Map<String, dynamic>>> getCart(String userId) {
    return _db.collection('carts').doc(userId).snapshots().map((snap) {
      if (!snap.exists) return [];
      final data = snap.data();
      if (data == null || data['items'] == null) return [];
      return List<Map<String, dynamic>>.from(data['items']);
    });
  }

  Future<void> updateCart(
      String userId, List<Map<String, dynamic>> items) async {
    await _db.collection('carts').doc(userId).set({'items': items});
  }

  Future<void> clearCart(String userId) async {
    await _db.collection('carts').doc(userId).set({'items': []});
  }

  // ─── ORDERS ─────────────────────────────────────────

  Stream<List<OrderModel>> getAllOrders() {
    return _db.collection('orders').snapshots().map((snap) {
      final list =
          snap.docs.map((d) => OrderModel.fromMap(d.data(), d.id)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Stream<List<OrderModel>> getUserOrders(String userId) {
    return _db
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) {
      final list =
          snap.docs.map((d) => OrderModel.fromMap(d.data(), d.id)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<void> addOrder(OrderModel order) async {
    await _db.collection('orders').add({
      ...order.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _db.collection('orders').doc(orderId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> cancelOrder(String orderId) async {
    await _db.collection('orders').doc(orderId).update({
      'status': 'cancelled',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ─── SEEDER ─────────────────────────────────────────

  Future<void> seedMenusIfEmpty() async {
    const String dataVersion = 'gotcha_v7';
    const String legacyDataVersion = 'matcha'
        'cih_v7';
    final prefs = await SharedPreferences.getInstance();
    final savedVersion = prefs.getString('data_version');
    if (savedVersion == legacyDataVersion) {
      await prefs.setString('data_version', dataVersion);
      return;
    }
    if (savedVersion == dataVersion) return;

    final oldMenus = await _db.collection('menus').get();
    for (var doc in oldMenus.docs) {
      await doc.reference.delete();
    }
    final oldOrders = await _db.collection('orders').get();
    for (var doc in oldOrders.docs) {
      await doc.reference.delete();
    }
    final oldCarts = await _db.collection('carts').get();
    for (var doc in oldCarts.docs) {
      await doc.reference.delete();
    }

    final List<Map<String, dynamic>> menus = [
      // ── MINUMAN ──
      {
        'name': 'Matcha Original',
        'price': 13000.0,
        'category': 'drink',
        'stock': 20,
        'description':
            'Perpaduan matcha segar dengan susu pilihan. Rasa klasik yang tidak pernah mengecewakan.',
        'imageBase64': '',
        'imagePath': 'assets/images/menu/matcha_original.jpeg',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Matcha Yakult',
        'price': 15000.0,
        'category': 'drink',
        'stock': 20,
        'description':
            'Kombinasi unik matcha dengan yakult yang menyegarkan. Asam manis yang bikin nagih.',
        'imageBase64': '',
        'imagePath': 'assets/images/menu/matcha_yakult.jpeg',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Matcha Taro',
        'price': 15000.0,
        'category': 'drink',
        'stock': 18,
        'description':
            'Matcha bertemu taro dalam satu gelas. Paduan warna dan rasa yang memanjakan.',
        'imageBase64': '',
        'imagePath': 'assets/images/menu/matcha_taro.jpeg',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Matcha Grape',
        'price': 15000.0,
        'category': 'drink',
        'stock': 18,
        'description':
            'Matcha dengan sentuhan rasa anggur yang segar dan susu creamy.',
        'imageBase64': '',
        'imagePath': 'assets/images/menu/matcha_grape.jpeg',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Matcha Cloud',
        'price': 16000.0,
        'category': 'drink',
        'stock': 15,
        'description':
            'Matcha lembut dengan susu dan topping es krim vanilla. Ringan seperti awan.',
        'imageBase64': '',
        'imagePath': 'assets/images/menu/matcha_cloud.jpeg',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Matcha Blueberry',
        'price': 18000.0,
        'category': 'drink',
        'stock': 15,
        'description':
            'Matcha berpadu dengan rasa blueberry dan selai blueberry asli. Manis berwarna cantik.',
        'imageBase64': '',
        'imagePath': 'assets/images/menu/matcha_blueberry.jpeg',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Matcha Choco',
        'price': 18000.0,
        'category': 'drink',
        'stock': 15,
        'description':
            'Dua rasa favorit dalam satu gelas — matcha dan coklat. Kaya rasa, kaya sensasi.',
        'imageBase64': '',
        'imagePath': 'assets/images/menu/matcha_choco.jpeg',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Matchaku Strawberry',
        'price': 18000.0,
        'category': 'drink',
        'stock': 15,
        'description':
            'Matcha dengan rasa strawberry dan selai strawberry asli. Segar, manis, dan instagramable.',
        'imageBase64': '',
        'imagePath': 'assets/images/menu/matcha_strawberry.jpeg',
        'createdAt': FieldValue.serverTimestamp(),
      },
      // ── SNACK ──
      {
        'name': 'Matcha Tiramisu',
        'price': 16000.0,
        'category': 'snack',
        'stock': 12,
        'description':
            'Kue tiramisu lembut dengan krim dan taburan bubuk matcha premium di atasnya.',
        'imageBase64': '',
        'imagePath': 'assets/images/menu/matcha_tiramisu.jpeg',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Matcha Soufflé',
        'price': 20000.0,
        'category': 'snack',
        'stock': 10,
        'description':
            'Pancake soufflé super lembut, mochi daifuku kenyal, selai strawberry, dan es krim.',
        'imageBase64': '',
        'imagePath': 'assets/images/menu/matcha_souffle.jpeg',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Matcha Mille Crepe',
        'price': 17000.0,
        'category': 'snack',
        'stock': 10,
        'description':
            'Kue dadar berlapis dengan krim matcha lembut dan taburan bubuk matcha premium.',
        'imageBase64': '',
        'imagePath': 'assets/images/menu/matcha_mille_crepe.jpeg',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Matcha Basque',
        'price': 19000.0,
        'category': 'snack',
        'stock': 8,
        'description':
            'Kue keju panggang ala Basque dengan matcha premium. Luar gelap, dalam creamy.',
        'imageBase64': '',
        'imagePath': 'assets/images/menu/matcha_basque.jpeg',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Matcha Pudding',
        'price': 16000.0,
        'category': 'snack',
        'stock': 12,
        'description': 'Puding dengan cream matcha. Dingin menyegarkan.',
        'imageBase64': '',
        'imagePath': 'assets/images/menu/matcha_pudding.jpeg',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Matcha Brownie',
        'price': 13000.0,
        'category': 'snack',
        'stock': 15,
        'description':
            'Brownies panggang dengan cita rasa matcha yang kuat. Renyah di luar, lembut di dalam.',
        'imageBase64': '',
        'imagePath': 'assets/images/menu/matcha_brownie.jpeg',
        'createdAt': FieldValue.serverTimestamp(),
      },
      // ── MAKANAN ──
      {
        'name': 'Matcha Chicken curry',
        'price': 24000.0,
        'category': 'food',
        'stock': 10,
        'description':
            'Nasi hangat dengan chicken katsu crispy disiram saus matcha creamy yang gurih.',
        'imageBase64': '',
        'imagePath': 'assets/images/menu/matcha_chicken_curry.jpeg',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Matcha Macaroon',
        'price': 26000.0,
        'category': 'food',
        'stock': 8,
        'description':
            'Udon kenyal dengan saus cream matcha and smoked beef. Fusion Jepang yang menggugah.',
        'imageBase64': '',
        'imagePath': 'assets/images/menu/matcha_macaroon.jpeg',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Matcha Omurice',
        'price': 25000.0,
        'category': 'food',
        'stock': 10,
        'description':
            'Nasi goreng butter dibungkus telur omelette lembut dengan saus matcha cream di atas.',
        'imageBase64': '',
        'imagePath': 'assets/images/menu/matcha_omurice.jpeg',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Matcha Burger',
        'price': 24000.0,
        'category': 'food',
        'stock': 10,
        'description':
            'Roti bun matcha dengan beef patty juicy, cheese melt, dan saus mayo matcha spesial.',
        'imageBase64': '',
        'imagePath': 'assets/images/menu/matcha_burger.jpeg',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Matcha Ramen',
        'price': 21000.0,
        'category': 'food',
        'stock': 12,
        'description':
            'Mie goreng homemade dengan saus savory matcha, telur, dan sayuran segar pilihan.',
        'imageBase64': '',
        'imagePath': 'assets/images/menu/matcha_ramen.jpeg',
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (var menu in menus) {
      await _db.collection('menus').add(menu);
    }

    await prefs.setString('data_version', dataVersion);
  }

  // ─── USER ────────────────────────────────────────────

  Future<void> updateUserName(String userId, String newName) async {
    await _db.collection('users').doc(userId).update({'name': newName});
  }

  Future<void> updateUserProfileImage(
      String userId, String profileImageBase64) async {
    await _db.collection('users').doc(userId).update({
      'profileImageBase64': profileImageBase64,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
