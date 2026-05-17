import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _filter = 'all';

  final List<Map<String, String>> _filters = [
    {'value': 'all', 'label': 'Semua'},
    {'value': 'pending', 'label': 'Pending'},
    {'value': 'processed', 'label': 'Diproses'},
    {'value': 'completed', 'label': 'Selesai'},
    {'value': 'cancelled', 'label': 'Dibatalkan'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _filters.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _filter = _filters[_tabController.index]['value']!);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending': return const Color(0xFFF4A261);
      case 'processed': return const Color(0xFF4895EF);
      case 'completed': return const Color(0xFF52B788);
      default: return const Color(0xFFE63946);
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending': return 'Pending';
      case 'processed': return 'Diproses';
      case 'completed': return 'Selesai';
      default: return 'Dibatalkan';
    }
  }

  String _statusEmoji(String status) {
    switch (status) {
      case 'pending': return '⏳';
      case 'processed': return '👨‍🍳';
      case 'completed': return '✅';
      default: return '❌';
    }
  }

  List<OrderModel> _filtered(List<OrderModel> orders) {
    if (_filter == 'all') return orders;
    return orders.where((o) => o.status == _filter).toList();
  }

  void _showOrderDetail(BuildContext context, OrderModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        maxChildSize: 0.92,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: const Color(0xFFE8EDE9),
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                // Header
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order #${order.orderId.substring(0, 6).toUpperCase()}',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1B1B1B)),
                            ),
                            Text(
                              DateFormat('dd MMM yyyy, HH:mm')
                                  .format(order.createdAt),
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF9E9E9E)),
                            ),
                          ]),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _statusColor(order.status)
                              .withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${_statusEmoji(order.status)} ${_statusLabel(order.status)}',
                          style: TextStyle(
                              color: _statusColor(order.status),
                              fontWeight: FontWeight.w700,
                              fontSize: 13),
                        ),
                      ),
                    ]),
                const SizedBox(height: 12),
                // Pelanggan
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9F4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(children: [
                    const Text('👤', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Pelanggan',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF9E9E9E))),
                          Text(order.userName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1B1B1B))),
                        ]),
                  ]),
                ),
                if (order.note.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFFF4A261).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: const Color(0xFFF4A261)
                              .withOpacity(0.3)),
                    ),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('📝',
                              style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Text(order.note,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF4A4A4A)))),
                        ]),
                  ),
                ],
                const SizedBox(height: 16),
                const Text('Item Pesanan',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: Color(0xFF1B1B1B))),
                const SizedBox(height: 8),
                ...order.items.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Row(children: [
                              const Text('🍵',
                                  style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 8),
                              Text('${item['name']} x${item['quantity']}',
                                  style: const TextStyle(
                                      color: Color(0xFF1B1B1B),
                                      fontWeight: FontWeight.w500)),
                            ]),
                            Text(
                              'Rp ${(item['price'] * item['quantity']).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2D6A4F)),
                            ),
                          ]),
                    )),
                const Divider(height: 24),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total',
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: Color(0xFF1B1B1B))),
                      Text(
                        'Rp ${order.totalPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: Color(0xFF2D6A4F)),
                      ),
                    ]),
                const SizedBox(height: 20),
                if (order.status == 'pending' ||
                    order.status == 'processed') ...[
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D6A4F),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        final nextStatus = order.status == 'pending'
                            ? 'processed'
                            : 'completed';
                        await context
                            .read<OrderProvider>()
                            .updateStatus(order.orderId, nextStatus);
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: Text(
                        order.status == 'pending'
                            ? '👨‍🍳  Proses Pesanan'
                            : '✅  Selesaikan Pesanan',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allOrders = context.watch<OrderProvider>().orders;
    final orders = _filtered(allOrders);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F4),
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xFF2D6A4F),
            title: const Text('Pesanan Masuk',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 20)),
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 13),
              unselectedLabelStyle:
                  const TextStyle(fontWeight: FontWeight.w500),
              tabAlignment: TabAlignment.start,
              tabs: _filters.map((f) => Tab(text: f['label'])).toList(),
            ),
          ),
        ],
        body: orders.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD8F3DC),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: const Center(
                          child:
                              Text('🧾', style: TextStyle(fontSize: 48))),
                    ),
                    const SizedBox(height: 16),
                    const Text('Tidak ada pesanan',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1B1B1B))),
                    const SizedBox(height: 6),
                    const Text('Pesanan akan muncul di sini',
                        style: TextStyle(
                            fontSize: 13, color: Color(0xFF9E9E9E))),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: orders.length,
                itemBuilder: (_, i) {
                  final order = orders[i];
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: Duration(milliseconds: 200 + (i * 50)),
                    builder: (_, val, child) => Opacity(
                      opacity: val,
                      child: Transform.translate(
                        offset: Offset(0, 16 * (1 - val)),
                        child: child,
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () => _showOrderDetail(context, order),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 2))
                          ],
                        ),
                        child: Column(children: [
                          // Status header
                          Container(
                            padding: const EdgeInsets.fromLTRB(
                                14, 10, 14, 10),
                            decoration: BoxDecoration(
                              color: _statusColor(order.status)
                                  .withOpacity(0.08),
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16)),
                            ),
                            child: Row(children: [
                              Text(_statusEmoji(order.status),
                                  style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Order #${order.orderId.substring(0, 6).toUpperCase()}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      color: Color(0xFF1B1B1B)),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _statusColor(order.status),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                    _statusLabel(order.status),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700)),
                              ),
                            ]),
                          ),
                          // Body
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                                14, 10, 14, 12),
                            child: Row(children: [
                              Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(order.userName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF1B1B1B))),
                                      const SizedBox(height: 2),
                                      Text(
                                        order.items
                                            .map((i) =>
                                                '${i['name']} x${i['quantity']}')
                                            .join(', '),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF9E9E9E)),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        DateFormat('dd MMM, HH:mm')
                                            .format(order.createdAt),
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF9E9E9E)),
                                      ),
                                    ]),
                              ),
                              Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Rp ${order.totalPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                          color: Color(0xFF2D6A4F)),
                                    ),
                                    const SizedBox(height: 4),
                                    const Icon(
                                        Icons.chevron_right_rounded,
                                        color: Color(0xFFCCCCCC),
                                        size: 20),
                                  ]),
                            ]),
                          ),
                        ]),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}