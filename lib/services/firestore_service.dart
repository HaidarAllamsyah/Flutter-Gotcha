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
    // Ganti angka versi ini setiap kali mau reset data
    const String dataVersion = 'matchacih_v2';

    final prefs = await SharedPreferences.getInstance();
    final savedVersion = prefs.getString('data_version');

    // Jika versi sama, skip seeder
    if (savedVersion == dataVersion) return;

    // Hapus semua menu lama
    final oldMenus = await _db.collection('menus').get();
    for (var doc in oldMenus.docs) {
      await doc.reference.delete();
    }

// Hapus semua orders lama
    final oldOrders = await _db.collection('orders').get();
    for (var doc in oldOrders.docs) {
      await doc.reference.delete();
    }

// Hapus semua carts lama
    final oldCarts = await _db.collection('carts').get();
    for (var doc in oldCarts.docs) {
      await doc.reference.delete();
    }

    // Isi menu baru
    final List<Map<String, dynamic>> sampleMenus = [
      // ── MINUMAN ──
      {
        'name': 'Avocado Matcha',
        'price': 15000.0,
        'category': 'drink',
        'stock': 20,
        'description': 'Minuman matcha dengan rasa alpukat',
        'imageBase64': '',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Matcha Latte',
        'price': 28000.0,
        'category': 'drink',
        'stock': 20,
        'description':
            'Espresso matcha premium dicampur susu segar, lembut dan creamy dengan aroma matcha yang kuat.',
        'imageBase64': '',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Matcha Frappe',
        'price': 32000.0,
        'category': 'drink',
        'stock': 15,
        'description':
            'Minuman matcha dingin blended dengan es dan whipped cream, segar dan manis.',
        'imageBase64': '',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Iced Matcha Americano',
        'price': 25000.0,
        'category': 'drink',
        'stock': 20,
        'description':
            'Matcha grade A dicampur air dingin dan es, rasa matcha murni tanpa susu.',
        'imageBase64': '',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Matcha Milk Tea',
        'price': 27000.0,
        'category': 'drink',
        'stock': 18,
        'description':
            'Teh susu dengan bubuk matcha pilihan, ada pilihan dengan boba atau polos.',
        'imageBase64': '',
        'createdAt': FieldValue.serverTimestamp(),
      },
      // ── MAKANAN ──
      {
        'name': 'Matcha Lava Cake',
        'price': 35000.0,
        'category': 'food',
        'stock': 10,
        'description':
            'Kue coklat hangat dengan isian matcha cair yang meleleh, disajikan dengan es krim vanilla.',
        'imageBase64': '',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Matcha Pancake Stack',
        'price': 38000.0,
        'category': 'food',
        'stock': 8,
        'description':
            'Tumpukan pancake matcha fluffy dengan butter dan matcha syrup, sarapan favorit.',
        'imageBase64': '',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Matcha Ice Cream',
        'price': 22000.0,
        'category': 'food',
        'stock': 15,
        'description':
            'Es krim matcha premium dengan rasa autentik Jepang, tersedia 1 atau 2 scoop.',
        'imageBase64': '',
        'createdAt': FieldValue.serverTimestamp(),
      },
      // ── SNACK ──
      {
        'name': 'Matcha Cookie Box',
        'price': 20000.0,
        'category': 'snack',
        'stock': 12,
        'description':
            'Kotak berisi 6 cookies matcha renyah dengan white chocolate chips.',
        'imageBase64': '',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Matcha Donut',
        'price': 18000.0,
        'category': 'snack',
        'stock': 10,
        'description':
            'Donut glazed matcha dengan taburan bubuk matcha di atasnya, lembut dan harum.',
        'imageBase64': '',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Matcha Mochi',
        'price': 15000.0,
        'category': 'snack',
        'stock': 20,
        'description': 'Mochi kenyal isi pasta matcha manis, 3 pcs per porsi.',
        'imageBase64': '',
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (var menu in sampleMenus) {
      await _db.collection('menus').add(menu);
    }

    // Simpan versi baru
    await prefs.setString('data_version', dataVersion);
  }
}
