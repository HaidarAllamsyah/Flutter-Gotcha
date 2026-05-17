class OrderModel {
  final String orderId;
  final String userId;
  final String userName;
  final List<Map<String, dynamic>> items;
  final double totalPrice;
  final double deliveryFee;
  final String note;
  String status;
  final String orderType; // 'pickup' atau 'delivery'
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
}