import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';

class UserOrderDetailScreen extends StatelessWidget {
  final OrderModel order;
  const UserOrderDetailScreen({super.key, required this.order});

  Color _statusColor(String status) {
    switch (status) {
      case 'pending': return const Color(0xFFF39C12);
      case 'processed': return const Color(0xFF3498DB);
      case 'completed': return const Color(0xFF2ECC71);
      default: return const Color(0xFFE74C3C);
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending': return 'Menunggu Konfirmasi';
      case 'processed': return 'Sedang Diproses';
      case 'completed': return 'Pesanan Selesai';
      default: return 'Dibatalkan';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2ECC71),
        foregroundColor: Colors.white,
        title: Text(
            'Order #${order.orderId.substring(0, 6).toUpperCase()}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
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
                color: _statusColor(order.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: _statusColor(order.status).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    order.status == 'completed'
                        ? Icons.check_circle
                        : order.status == 'cancelled'
                            ? Icons.cancel
                            : order.status == 'processed'
                                ? Icons.sync
                                : Icons.pending_actions,
                    color: _statusColor(order.status),
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_statusLabel(order.status),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _statusColor(order.status),
                              fontSize: 16)),
                      Text(
                          DateFormat('dd MMM yyyy, HH:mm')
                              .format(order.createdAt),
                          style: const TextStyle(
                              color: Color(0xFF7F8C8D),
                              fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Item pesanan
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Item Pesanan',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF2C3E50))),
                  const Divider(height: 20),
                  ...order.items.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(item['name'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF2C3E50))),
                                  Text(
                                      'Rp ${item['price'].toStringAsFixed(0)} x ${item['quantity']}',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF7F8C8D))),
                                ],
                              ),
                            ),
                            Text(
                                'Rp ${(item['price'] * item['quantity']).toStringAsFixed(0)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2C3E50))),
                          ],
                        ),
                      )),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF2C3E50))),
                      Text(
                          'Rp ${order.totalPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFF2ECC71))),
                    ],
                  ),
                ],
              ),
            ),
            // Catatan
            if (order.note.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.note_outlined,
                        color: Color(0xFFF39C12)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Catatan',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2C3E50))),
                          const SizedBox(height: 4),
                          Text(order.note,
                              style: const TextStyle(
                                  color: Color(0xFF7F8C8D))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            // Tombol batalkan
            if (order.status == 'pending') ...[
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE74C3C),
                    side: const BorderSide(color: Color(0xFFE74C3C)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Batalkan Pesanan'),
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
                                    const Color(0xFFE74C3C),
                                foregroundColor: Colors.white),
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Pesanan dibatalkan.'),
                            backgroundColor: Color(0xFFE74C3C),
                          ),
                        );
                        Navigator.pop(context);
                      }
                    }
                  },
                  child: const Text('Batalkan Pesanan',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}