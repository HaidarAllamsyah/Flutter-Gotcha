import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import 'user_order_detail_screen.dart';

class UserOrderHistoryScreen extends StatefulWidget {
  const UserOrderHistoryScreen({super.key});

  @override
  State<UserOrderHistoryScreen> createState() =>
      _UserOrderHistoryScreenState();
}

class _UserOrderHistoryScreenState extends State<UserOrderHistoryScreen>
    with SingleTickerProviderStateMixin {
  String _filter = 'all';
  late TabController _tabController;

  final List<Map<String, String>> _filters = [
    {'value': 'all', 'label': 'Semua'},
    {'value': 'pending', 'label': '⏳ Pending'},
    {'value': 'processing', 'label': '👨‍🍳 Diproses'},
    {'value': 'ready', 'label': '✅ Siap Ambil'},
    {'value': 'on_delivery', 'label': '🛵 Dikirim'},
    {'value': 'completed', 'label': '🎉 Selesai'},
    {'value': 'cancelled', 'label': '❌ Batal'},
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

  List<OrderModel> _filtered(List<OrderModel> orders) {
    if (_filter == 'all') return orders;
    return orders.where((o) => o.status == _filter).toList();
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
            title: const Text('Riwayat Pesanan',
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
                  fontWeight: FontWeight.w700, fontSize: 12),
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
                        child: Text('🧾', style: TextStyle(fontSize: 48)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Belum Ada Pesanan',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1B1B1B))),
                    const SizedBox(height: 6),
                    const Text('Yuk pesan matcha favoritmu!',
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
                  final color = Color(order.statusColorValue);

                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: Duration(milliseconds: 200 + (i * 60)),
                    builder: (_, val, child) => Opacity(
                      opacity: val,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - val)),
                        child: child,
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                UserOrderDetailScreen(order: order)),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 12,
                                offset: const Offset(0, 3))
                          ],
                        ),
                        child: Column(
                          children: [
                            // Header
                            Container(
                              padding: const EdgeInsets.fromLTRB(
                                  14, 12, 14, 12),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.08),
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(18)),
                              ),
                              child: Row(
                                children: [
                                  Text(order.statusEmoji,
                                      style:
                                          const TextStyle(fontSize: 18)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '#${order.orderId.substring(0, 6).toUpperCase()}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 14,
                                              color: Color(0xFF1B1B1B)),
                                        ),
                                        Text(
                                          DateFormat('dd MMM yyyy, HH:mm')
                                              .format(order.createdAt),
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF9E9E9E)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: color,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          order.statusLabel,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      // Badge tipe pesanan
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: order.isPickup
                                              ? const Color(0xFF4895EF)
                                                  .withOpacity(0.12)
                                              : const Color(0xFF9B5DE5)
                                                  .withOpacity(0.12),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          order.isPickup
                                              ? '🏃 Pick Up'
                                              : '🛵 Delivery',
                                          style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w700,
                                              color: order.isPickup
                                                  ? const Color(0xFF4895EF)
                                                  : const Color(
                                                      0xFF9B5DE5)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Body
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  14, 10, 14, 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          order.items
                                              .map((i) =>
                                                  '${i['name']} x${i['quantity']}')
                                              .join(', '),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF4A4A4A)),
                                        ),
                                        const SizedBox(height: 2),
                                        // Info pickup/delivery
                                        if (order.isPickup &&
                                            order.pickupTime != null)
                                          Row(children: [
                                            const Icon(
                                                Icons.access_time_rounded,
                                                size: 11,
                                                color: Color(0xFF4895EF)),
                                            const SizedBox(width: 3),
                                            Text(order.pickupTime!,
                                                style: const TextStyle(
                                                    fontSize: 11,
                                                    color:
                                                        Color(0xFF4895EF))),
                                          ])
                                        else if (order.isDelivery &&
                                            order.deliveryAddress != null)
                                          Row(children: [
                                            const Icon(
                                                Icons.location_on_rounded,
                                                size: 11,
                                                color: Color(0xFF9B5DE5)),
                                            const SizedBox(width: 3),
                                            Expanded(
                                              child: Text(
                                                order.deliveryAddress!,
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontSize: 11,
                                                    color:
                                                        Color(0xFF9B5DE5)),
                                              ),
                                            ),
                                          ]),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Rp ${order.grandTotal.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                        color: Color(0xFF2D6A4F)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}