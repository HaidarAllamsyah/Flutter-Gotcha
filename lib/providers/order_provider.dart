import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';
import '../models/cart_item_model.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';

class OrderProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<OrderModel> _orders = [];
  bool _isLoading = false;
  bool _isAdmin = false;

  // Simpan status sebelumnya untuk deteksi perubahan
  final Map<String, String> _previousStatuses = {};

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;

  void listenAllOrders() {
    _isAdmin = true;
    _firestoreService.getAllOrders().listen((list) {
      _orders = List.from(list);
      notifyListeners();
    });
  }

  void listenUserOrders(String userId) {
    _isAdmin = false;
    _firestoreService.getUserOrders(userId).listen((list) {
      // Deteksi perubahan status untuk notifikasi
      for (final order in list) {
        final prevStatus = _previousStatuses[order.orderId];
        if (prevStatus != null &&
            prevStatus != order.status &&
            !_isAdmin) {
          // Status berubah → tampilkan notifikasi
          NotificationService.showStatusNotification(
            orderNumber: order.orderId.substring(0, 6).toUpperCase(),
            statusLabel: order.statusLabel,
            statusIcon: order.statusIcon,
            color: Color(order.statusColorValue),
          );
        }
        _previousStatuses[order.orderId] = order.status;
      }

      _orders = List.from(list);
      notifyListeners();
    });
  }

  Future<bool> placeOrder({
    required UserModel user,
    required List<CartItemModel> items,
    required double totalPrice,
    required double deliveryFee,
    required String note,
    required String orderType,
    String paymentMethod = 'QRIS',
    String? pickupTime,
    String? deliveryAddress,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      for (var item in items) {
        await _firestoreService.updateStock(item.menuId, -item.quantity);
      }

      final order = OrderModel(
        orderId: '',
        userId: user.userId,
        userName: user.name,
        items: items.map((i) => i.toMap()).toList(),
        totalPrice: totalPrice,
        deliveryFee: deliveryFee,
        note: note,
        status: 'pending',
        orderType: orderType,
        paymentMethod: paymentMethod,
        pickupTime: pickupTime,
        deliveryAddress: deliveryAddress,
        createdAt: DateTime.now(),
      );

      await _firestoreService.addOrder(order);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> updateStatus(String orderId, String status) async {
    await _firestoreService.updateOrderStatus(orderId, status);
  }

  Future<void> cancelOrder(String orderId) async {
    await _firestoreService.cancelOrder(orderId);
  }
}
