import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';

class UserOrderDetailScreen extends StatelessWidget {
  final OrderModel order;
  const UserOrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final color = Color(order.statusColorValue);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D6A4F),
        foregroundColor: Colors.white,
        title: Text(
            'Order #${order.orderId.substring(0, 6).toUpperCase()}',
            style: const TextStyle(fontWeight: FontWeight.w800)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Row(children: [
                Text(order.statusEmoji,
                    style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.statusLabel,
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: color,
                              fontSize: 16)),
                      Text(
                        DateFormat('dd MMM yyyy, HH:mm')
                            .format(order.createdAt),
                        style: const TextStyle(
                            color: Color(0xFF9E9E9E), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                // Badge tipe pesanan
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: order.isPickup
                        ? const Color(0xFF4895EF).withOpacity(0.15)
                        : const Color(0xFF9B5DE5).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    order.isPickup ? '🏃 Pick Up' : '🛵 Delivery',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: order.isPickup
                            ? const Color(0xFF4895EF)
                            : const Color(0xFF9B5DE5)),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 12),

            // Info pickup/delivery
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.isPickup
                        ? '🏃 Informasi Pick Up'
                        : '🛵 Informasi Delivery',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1B1B1B)),
                  ),
                  const SizedBox(height: 8),
                  if (order.isPickup && order.pickupTime != null)
                    _detailRow(Icons.access_time_rounded,
                        'Waktu Ambil', order.pickupTime!),
                  if (order.isDelivery &&
                      order.deliveryAddress != null) ...[
                    _detailRow(Icons.location_on_rounded, 'Alamat',
                        order.deliveryAddress!),
                    if (order.deliveryFee > 0)
                      _detailRow(
                        Icons.delivery_dining_rounded,
                        'Ongkir',
                        'Rp ${order.deliveryFee.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                      ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Item pesanan
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Item Pesanan',
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: Color(0xFF1B1B1B))),
                  const Divider(height: 20),
                  ...order.items.map((item) {
                    final customParts = <String>[];
                    if (item['matchaGrade'] != null)
                      customParts.add(item['matchaGrade']);
                    if (item['matchaLevel'] != null)
                      customParts.add('Lvl ${item['matchaLevel']}');
                    if (item['sugarLevel'] != null &&
                        item['sugarLevel'] != 'normal')
                      customParts.add('${item['sugarLevel']} sugar');
                    if (item['iceLevel'] != null &&
                        item['iceLevel'] != 'normal')
                      customParts.add('${item['iceLevel']} ice');

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                  '${item['name']} x${item['quantity']}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1B1B1B))),
                              if (customParts.isNotEmpty)
                                Text(customParts.join(' · '),
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF9E9E9E))),
                              Text(
                                'Rp ${item['price'].toStringAsFixed(0)} / item',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF9E9E9E)),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Rp ${(item['price'] * item['quantity']).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2D6A4F))),
                      ]),
                    );
                  }),
                  const Divider(height: 20),
                  if (order.deliveryFee > 0) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Ongkir',
                            style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF9E9E9E))),
                        Text(
                          'Rp ${order.deliveryFee.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                          style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF9E9E9E))),
                      ],
                    ),
                    const SizedBox(height: 6),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Bayar',
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: Color(0xFF1B1B1B))),
                      Text(
                        'Rp ${order.grandTotal.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: Color(0xFF2D6A4F))),
                    ],
                  ),
                ],
              ),
            ),

            // Catatan
            if (order.note.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.note_outlined,
                        color: Color(0xFFF4A261)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Catatan',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1B1B1B))),
                          const SizedBox(height: 4),
                          Text(order.note,
                              style: const TextStyle(
                                  color: Color(0xFF4A4A4A))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Batalkan pesanan (hanya jika pending)
            if (order.status == 'pending') ...[
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE63946),
                    side: const BorderSide(color: Color(0xFFE63946)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        title: const Text('Batalkan Pesanan?'),
                        content: const Text(
                            'Yakin ingin membatalkan pesanan ini?'),
                        actions: [
                          TextButton(
                              onPressed: () =>
                                  Navigator.pop(context, false),
                              child: const Text('Tidak')),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFFE63946),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(10))),
                            onPressed: () =>
                                Navigator.pop(context, true),
                            child: const Text('Ya, Batalkan'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true && context.mounted) {
                      await context
                          .read<OrderProvider>()
                          .cancelOrder(order.orderId);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text('Pesanan dibatalkan.'),
                          backgroundColor: Color(0xFFE63946),
                          behavior: SnackBarBehavior.floating,
                        ));
                        Navigator.pop(context);
                      }
                    }
                  },
                  child: const Text('Batalkan Pesanan',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        Icon(icon, size: 16, color: const Color(0xFF9E9E9E)),
        const SizedBox(width: 6),
        Text('$label: ',
            style: const TextStyle(
                fontSize: 12, color: Color(0xFF9E9E9E))),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B1B1B))),
        ),
      ]),
    );
  }
}