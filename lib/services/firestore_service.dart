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
    const String dataVersion = 'matchacih_v6';
    final prefs = await SharedPreferences.getInstance();
    final savedVersion = prefs.getString('data_version');
    if (savedVersion == dataVersion) return;

    final oldMenus = await _db.collection('menus').get();
    for (var doc in oldMenus.docs) await doc.reference.delete();
    final oldOrders = await _db.collection('orders').get();
    for (var doc in oldOrders.docs) await doc.reference.delete();
    final oldCarts = await _db.collection('carts').get();
    for (var doc in oldCarts.docs) await doc.reference.delete();

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
        'imagePath': '',
        'imageUrl':
            'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=400&q=80',
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
        'imagePath': '',
        'imageUrl':
            'https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=400&q=80',
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
        'imagePath': '',
        'imageUrl':
            'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=400&q=80',
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
        'imagePath': '',
        'imageUrl':
            'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=400&q=80',
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
        'imagePath': '',
        'imageUrl':
            'https://images.unsplash.com/photo-1541167760496-1628856ab772?w=400&q=80',
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
        'imagePath': '',
        'imageUrl':
            'https://images.unsplash.com/photo-1570696516188-ade861b84a49?w=400&q=80',
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
        'imagePath': '',
        'imageUrl':
            'https://images.unsplash.com/photo-1511920170033-f8396924c348?w=400&q=80',
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
        'imagePath': '',
        'imageUrl':
            'https://images.unsplash.com/photo-1553361371-9b22f78e8b1d?w=400&q=80',
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
        'imagePath': '',
        'imageUrl':
            'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?w=400&q=80',
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
        'imagePath': '',
        'imageUrl':
            'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400&q=80',
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
        'imagePath': '',
        'imageUrl':
            'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=400&q=80',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Matcha Basque Cake',
        'price': 19000.0,
        'category': 'snack',
        'stock': 8,
        'description':
            'Kue keju panggang ala Basque dengan matcha premium. Luar gelap, dalam creamy.',
        'imageBase64': '',
        'imagePath': '',
        'imageUrl':
            'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400&q=80',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Matcha Pudding Ice Cream',
        'price': 16000.0,
        'category': 'snack',
        'stock': 12,
        'description':
            'Puding matcha segar dengan saus karamel dan es krim vanilla. Dingin menyegarkan.',
        'imageBase64': '',
        'imagePath': '',
        'imageUrl':
            'https://images.unsplash.com/photo-1497034825429-c343d7c6a68f?w=400&q=80',
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
        'imagePath': '',
        'imageUrl':
            'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=400&q=80',
        'createdAt': FieldValue.serverTimestamp(),
      },
      // ── MAKANAN ──
      {
        'name': 'Matcha Chicken Katsu Rice',
        'price': 24000.0,
        'category': 'food',
        'stock': 10,
        'description':
            'Nasi hangat dengan chicken katsu crispy disiram saus matcha creamy yang gurih.',
        'imageBase64': '',
        'imagePath': '',
        'imageUrl':
            'https://images.unsplash.com/photo-1569050467447-ce54b3bbc37d?w=400&q=80',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Matcha Carbonara Udon',
        'price': 26000.0,
        'category': 'food',
        'stock': 8,
        'description':
            'Udon kenyal dengan saus cream matcha dan smoked beef. Fusion Jepang yang menggugah.',
        'imageBase64': '',
        'imagePath': '',
        'imageUrl':
            'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400&q=80',
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
        'imagePath': '',
        'imageUrl':
            'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=400&q=80',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Matcha Curry Rice',
        'price': 26000.0,
        'category': 'food',
        'stock': 8,
        'description':
            'Nasi hangat dengan kari ayam creamy dan sentuhan matcha premium yang khas.',
        'imageBase64': '',
        'imagePath': '',
        'imageUrl':
            'https://images.unsplash.com/photo-1455619452474-d2be8b1e70cd?w=400&q=80',
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
        'imagePath': '',
        'imageUrl':
            'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&q=80',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Matcha Mie Goreng',
        'price': 21000.0,
        'category': 'food',
        'stock': 12,
        'description':
            'Mie goreng homemade dengan saus savory matcha, telur, dan sayuran segar pilihan.',
        'imageBase64': '',
        'imagePath': '',
        'imageUrl':
            'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400&q=80',
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
}
