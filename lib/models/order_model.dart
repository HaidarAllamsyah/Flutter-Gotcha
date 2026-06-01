import 'package:flutter/material.dart';

class OrderModel {
  final String orderId;
  final String userId;
  final String userName;
  final List<Map<String, dynamic>> items;
  final double totalPrice;
  final double deliveryFee;
  final String note;
  String status;
  final String orderType;
  final String paymentMethod;
  final String? pickupTime;
  final String? deliveryAddress;
  final DateTime createdAt;

  OrderModel({
    required this.orderId,
    required this.userId,
    required this.userName,
    required this.items,
    required this.totalPrice,
    this.deliveryFee = 0,
    required this.note,
    required this.status,
    required this.orderType,
    this.paymentMethod = 'QRIS',
    this.pickupTime,
    this.deliveryAddress,
    required this.createdAt,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      orderId: id,
      userId: (map['userId'] ?? '').toString(),
      userName: (map['userName'] ?? '').toString(),
      items: List<Map<String, dynamic>>.from(map['items'] ?? []),
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      deliveryFee: (map['deliveryFee'] ?? 0).toDouble(),
      note: (map['note'] ?? '').toString(),
      status: (map['status'] ?? 'pending').toString(),
      orderType: (map['orderType'] ?? 'pickup').toString(),
      paymentMethod: (map['paymentMethod'] ?? 'QRIS').toString(),
      pickupTime: map['pickupTime']?.toString(),
      deliveryAddress: map['deliveryAddress']?.toString(),
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'items': items,
      'totalPrice': totalPrice,
      'deliveryFee': deliveryFee,
      'note': note,
      'status': status,
      'orderType': orderType,
      'paymentMethod': paymentMethod,
      'pickupTime': pickupTime,
      'deliveryAddress': deliveryAddress,
      'createdAt': createdAt,
      'updatedAt': DateTime.now(),
    };
  }

  int get totalItems =>
      items.fold(0, (sum, item) => sum + (item['quantity'] as int));

  double get grandTotal => totalPrice + deliveryFee;

  bool get isPickup => orderType == 'pickup';
  bool get isDelivery => orderType == 'delivery';

  // Status flow pickup: pending → processing → ready → completed
  // Status flow delivery: pending → processing → on_delivery → completed
  // Bisa dibatalkan (cancelled) dari status pending

  String get statusLabel {
    if (isPickup) {
      switch (status) {
        case 'pending': return 'Menunggu Konfirmasi';
        case 'processing': return 'Sedang Diproses';
        case 'ready': return 'Siap Diambil';
        case 'completed': return 'Sudah Diambil';
        case 'cancelled': return 'Dibatalkan';
        default: return status;
      }
    } else {
      switch (status) {
        case 'pending': return 'Menunggu Konfirmasi';
        case 'processing': return 'Sedang Diproses';
        case 'on_delivery': return 'Dalam Pengiriman';
        case 'completed': return 'Telah Diantar';
        case 'cancelled': return 'Dibatalkan';
        default: return status;
      }
    }
  }

  IconData get statusIcon {
    switch (status) {
      case 'pending': return Icons.hourglass_empty_rounded;
      case 'processing': return Icons.soup_kitchen_outlined;
      case 'ready': return Icons.check_circle_outline_rounded;
      case 'on_delivery': return Icons.delivery_dining_outlined;
      case 'completed': return Icons.done_all_rounded;
      case 'cancelled': return Icons.cancel_outlined;
      default: return Icons.receipt_long_outlined;
    }
  }

  // Warna status
  static const Map<String, int> statusColors = {
    'pending': 0xFFF4A261,
    'processing': 0xFF4895EF,
    'ready': 0xFFB7D64A,
    'on_delivery': 0xFF9B5DE5,
    'completed': 0xFF6B7D1F,
    'cancelled': 0xFFE63946,
  };

  int get statusColorValue =>
      statusColors[status] ?? statusColors['pending']!;

  // Next status untuk admin
  String? get nextStatus {
    if (isPickup) {
      switch (status) {
        case 'pending': return 'processing';
        case 'processing': return 'ready';
        case 'ready': return 'completed';
        default: return null;
      }
    } else {
      switch (status) {
        case 'pending': return 'processing';
        case 'processing': return 'on_delivery';
        case 'on_delivery': return 'completed';
        default: return null;
      }
    }
  }

  String? get nextStatusLabel {
    if (isPickup) {
      switch (status) {
        case 'pending': return 'Proses Pesanan';
        case 'processing': return 'Tandai Siap Diambil';
        case 'ready': return 'Pesanan Sudah Diambil';
        default: return null;
      }
    } else {
      switch (status) {
        case 'pending': return 'Proses Pesanan';
        case 'processing': return 'Kirim ke Kurir';
        case 'on_delivery': return 'Konfirmasi Sudah Diantar';
        default: return null;
      }
    }
  }
}
