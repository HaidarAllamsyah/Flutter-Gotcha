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
    this.pickupTime,
    this.deliveryAddress,
    required this.createdAt,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      orderId: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      items: List<Map<String, dynamic>>.from(map['items'] ?? []),
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      deliveryFee: (map['deliveryFee'] ?? 0).toDouble(),
      note: map['note'] ?? '',
      status: map['status'] ?? 'pending',
      orderType: map['orderType'] ?? 'pickup',
      pickupTime: map['pickupTime'],
      deliveryAddress: map['deliveryAddress'],
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

  String get statusEmoji {
    switch (status) {
      case 'pending': return '⏳';
      case 'processing': return '👨‍🍳';
      case 'ready': return '✅';
      case 'on_delivery': return '🛵';
      case 'completed': return '🎉';
      case 'cancelled': return '❌';
      default: return '📋';
    }
  }

  // Warna status
  static const Map<String, int> statusColors = {
    'pending': 0xFFF4A261,
    'processing': 0xFF4895EF,
    'ready': 0xFF52B788,
    'on_delivery': 0xFF9B5DE5,
    'completed': 0xFF2D6A4F,
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
        case 'pending': return '👨‍🍳  Proses Pesanan';
        case 'processing': return '✅  Tandai Siap Diambil';
        case 'ready': return '🎉  Pesanan Sudah Diambil';
        default: return null;
      }
    } else {
      switch (status) {
        case 'pending': return '👨‍🍳  Proses Pesanan';
        case 'processing': return '🛵  Kirim ke Kurir';
        case 'on_delivery': return '🎉  Konfirmasi Sudah Diantar';
        default: return null;
      }
    }
  }
}