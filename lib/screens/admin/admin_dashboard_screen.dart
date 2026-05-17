import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/menu_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/cart_provider.dart';
import '../user/login_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final menus = context.watch<MenuProvider>().menus;
    final orders = context.watch<OrderProvider>().orders;
    final user = context.watch<AuthProvider>().currentUser;

    final pendingOrders = orders.where((o) => o.status == 'pending').length;
    final completedOrders = orders.where((o) => o.status == 'completed').length;
    final processedOrders = orders.where((o) => o.status == 'processed').length;
    final totalRevenue = orders
        .where((o) => o.status == 'completed')
        .fold(0.0, (sum, o) => sum + o.totalPrice);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F4),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xFF2D6A4F),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Selamat datang,',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 13)),
                            Text(user?.name ?? 'Admin',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(children: [
                                Text('🍵', style: TextStyle(fontSize: 12)),
                                SizedBox(width: 4),
                                Text('Matchacih Admin',
                                    style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11)),
                              ]),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                title: const Text('Keluar?'),
                                content: const Text(
                                    'Yakin ingin keluar dari akun admin?'),
                                actions: [
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Batal')),
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
                                    child: const Text('Keluar'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true && context.mounted) {
                              await context.read<AuthProvider>().logout();
                              context.read<CartProvider>().reset();
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const LoginScreen()));
                            }
                          },
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.logout_rounded,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Revenue card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2D6A4F), Color(0xFF52B788)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: const Color(0xFF2D6A4F).withOpacity(0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Pendapatan',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 6),
                        Text(
                          'Rp ${totalRevenue.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'dari $completedOrders pesanan selesai',
                          style: const TextStyle(
                              color: Colors.white60, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Metric cards
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _metricCard('Total Menu', menus.length.toString(),
                          '🍵', const Color(0xFF2D6A4F)),
                      _metricCard('Pending', pendingOrders.toString(),
                          '⏳', const Color(0xFFF4A261)),
                      _metricCard('Diproses', processedOrders.toString(),
                          '👨‍🍳', const Color(0xFF4895EF)),
                      _metricCard('Selesai', completedOrders.toString(),
                          '✅', const Color(0xFF52B788)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Pesanan terbaru
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Pesanan Terbaru',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1B1B1B))),
                      if (orders.isNotEmpty)
                        Text('${orders.length} total',
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF9E9E9E))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  orders.isEmpty
                      ? Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Column(children: [
                              Text('🧾', style: TextStyle(fontSize: 40)),
                              SizedBox(height: 8),
                              Text('Belum ada pesanan',
                                  style: TextStyle(
                                      color: Color(0xFF9E9E9E),
                                      fontSize: 14)),
                            ]),
                          ),
                        )
                      : Column(
                          children: orders.take(5).map((order) {
                            Color statusColor;
                            String statusLabel;
                            String statusEmoji;
                            switch (order.status) {
                              case 'pending':
                                statusColor = const Color(0xFFF4A261);
                                statusLabel = 'Pending';
                                statusEmoji = '⏳';
                                break;
                              case 'processed':
                                statusColor = const Color(0xFF4895EF);
                                statusLabel = 'Diproses';
                                statusEmoji = '👨‍🍳';
                                break;
                              case 'completed':
                                statusColor = const Color(0xFF52B788);
                                statusLabel = 'Selesai';
                                statusEmoji = '✅';
                                break;
                              default:
                                statusColor = const Color(0xFFE63946);
                                statusLabel = 'Dibatalkan';
                                statusEmoji = '❌';
                            }
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
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
                              child: Row(children: [
                                Text(statusEmoji,
                                    style: const TextStyle(fontSize: 24)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(order.userName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                              color: Color(0xFF1B1B1B))),
                                      Text(
                                        '${order.totalItems} item • Rp ${order.totalPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF9E9E9E)),
                                      ),
                                      Text(
                                        DateFormat('dd MMM, HH:mm')
                                            .format(order.createdAt),
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF9E9E9E)),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(statusLabel,
                                      style: TextStyle(
                                          color: statusColor,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700)),
                                ),
                              ]),
                            );
                          }).toList(),
                        ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard(
      String label, String value, String emoji, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: color)),
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF9E9E9E))),
            ],
          ),
        ],
      ),
    );
  }
}