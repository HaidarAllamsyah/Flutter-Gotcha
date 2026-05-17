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
    {'value': 'pending', 'label': '⏳ Pending'},
    {'value': 'processing', 'label': '👨‍🍳 Diproses'},
    {'value': 'ready', 'label': '✅ Siap'},
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

  void _showOrderDetail(BuildContext context, OrderModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AdminOrderDetailSheet(order: order),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allOrders = context.watch<OrderProvider>().orders;
    final orders = _filtered(allOrders);
    final pendingCount =
        allOrders.where((o) => o.status == 'pending').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F4),
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xFF2D6A4F),
            title: Row(children: [
              const Text('Pesanan Masuk',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 20)),
              if (pendingCount > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE63946),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('$pendingCount baru',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ),
              ]
            ]),
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
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD8F3DC),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Center(
                          child: Text('🧾',
                              style: TextStyle(fontSize: 44))),
                    ),
                    const SizedBox(height: 14),
                    const Text('Tidak ada pesanan',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1B1B1B))),
                    const SizedBox(height: 4),
                    const Text('Pesanan akan muncul di sini',
                        style: TextStyle(
                            fontSize: 13, color: Color(0xFF9E9E9E))),
                  ],
                ),
              )
            : ListView.builder(
                padding:
                    const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: orders.length,
                itemBuilder: (_, i) {
                  final order = orders[i];
                  final color =
                      Color(order.statusColorValue);
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration:
                        Duration(milliseconds: 200 + (i * 50)),
                    builder: (_, val, child) => Opacity(
                      opacity: val,
                      child: Transform.translate(
                        offset: Offset(0, 16 * (1 - val)),
                        child: child,
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () =>
                          _showOrderDetail(context, order),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black
                                    .withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 2))
                          ],
                        ),
                        child: Column(children: [
                          // Header status
                          Container(
                            padding: const EdgeInsets.fromLTRB(
                                14, 10, 14, 10),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.08),
                              borderRadius:
                                  const BorderRadius.vertical(
                                      top: Radius.circular(16)),
                            ),
                            child: Row(children: [
                              Text(order.statusEmoji,
                                  style: const TextStyle(
                                      fontSize: 16)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Order #${order.orderId.substring(0, 6).toUpperCase()}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                          color: Color(0xFF1B1B1B)),
                                    ),
                                    Row(children: [
                                      // Badge tipe pesanan
                                      Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2),
                                        decoration: BoxDecoration(
                                          color: order.isPickup
                                              ? const Color(0xFF4895EF)
                                                  .withOpacity(0.15)
                                              : const Color(0xFF9B5DE5)
                                                  .withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          order.isPickup
                                              ? '🏃 Pick Up'
                                              : '🛵 Delivery',
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: order.isPickup
                                                  ? const Color(
                                                      0xFF4895EF)
                                                  : const Color(
                                                      0xFF9B5DE5)),
                                        ),
                                      ),
                                    ]),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius:
                                      BorderRadius.circular(8),
                                ),
                                child: Text(order.statusLabel,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
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
                                      // Info pickup/delivery
                                      if (order.isPickup &&
                                          order.pickupTime != null)
                                        Row(children: [
                                          const Icon(
                                              Icons.access_time_rounded,
                                              size: 12,
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
                                              size: 12,
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
                                      Text(
                                        DateFormat('dd MMM, HH:mm')
                                            .format(order.createdAt),
                                        style: const TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFF9E9E9E)),
                                      ),
                                    ]),
                              ),
                              Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Rp ${order.grandTotal.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
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

// ─── DETAIL SHEET ───────────────────────────────────────────────────────────

class _AdminOrderDetailSheet extends StatelessWidget {
  final OrderModel order;
  const _AdminOrderDetailSheet({required this.order});

  @override
  Widget build(BuildContext context) {
    final color = Color(order.statusColorValue);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                            fontSize: 12, color: Color(0xFF9E9E9E)),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${order.statusEmoji} ${order.statusLabel}',
                      style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w700,
                          fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Tipe pesanan
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: order.isPickup
                      ? const Color(0xFF4895EF).withOpacity(0.08)
                      : const Color(0xFF9B5DE5).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: order.isPickup
                        ? const Color(0xFF4895EF).withOpacity(0.2)
                        : const Color(0xFF9B5DE5).withOpacity(0.2),
                  ),
                ),
                child: Row(children: [
                  Text(order.isPickup ? '🏃' : '🛵',
                      style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.isPickup ? 'Pick Up' : 'Delivery',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: order.isPickup
                                  ? const Color(0xFF4895EF)
                                  : const Color(0xFF9B5DE5)),
                        ),
                        if (order.isPickup &&
                            order.pickupTime != null)
                          Text('Diambil: ${order.pickupTime}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF4A4A4A))),
                        if (order.isDelivery &&
                            order.deliveryAddress != null)
                          Text('Alamat: ${order.deliveryAddress}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF4A4A4A))),
                        if (order.isDelivery && order.deliveryFee > 0)
                          Text(
                            'Ongkir: Rp ${order.deliveryFee.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF4A4A4A)),
                          ),
                      ],
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 12),

              // Pelanggan
              _infoRow('👤', 'Pelanggan', order.userName),

              if (order.note.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4A261).withOpacity(0.08),
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
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Item pesanan
              const Text('Item Pesanan',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: Color(0xFF1B1B1B))),
              const SizedBox(height: 8),
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
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(children: [
                    const Text('🍵',
                        style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
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
                        ],
                      ),
                    ),
                    Text(
                      'Rp ${(item['price'] * item['quantity']).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2D6A4F)),
                    ),
                  ]),
                );
              }),

              const Divider(height: 24),

              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subtotal',
                      style: TextStyle(
                          fontSize: 13, color: Color(0xFF9E9E9E))),
                  Text(
                    'Rp ${order.totalPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF9E9E9E))),
                ],
              ),
              if (order.deliveryFee > 0) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Ongkir',
                        style: TextStyle(
                            fontSize: 13, color: Color(0xFF9E9E9E))),
                    Text(
                      'Rp ${order.deliveryFee.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF9E9E9E))),
                  ],
                ),
              ],
              const SizedBox(height: 6),
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

              const SizedBox(height: 20),

              // Tombol update status
              if (order.nextStatus != null)
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
                      await context
                          .read<OrderProvider>()
                          .updateStatus(
                              order.orderId, order.nextStatus!);
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: Text(
                      order.nextStatusLabel ?? '',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String emoji, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9F4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: Color(0xFF9E9E9E))),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B1B1B))),
        ]),
      ]),
    );
  }
}