import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../user/login_screen.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final orders = context.watch<OrderProvider>().orders;

    final totalOrders = orders.length;
    final completedOrders =
        orders.where((o) => o.status == 'completed').length;
    final pendingOrders =
        orders.where((o) => o.status == 'pending').length;
    final totalSpent = orders
        .where((o) => o.status == 'completed')
        .fold(0.0, (sum, o) => sum + o.totalPrice);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F4),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      // Avatar
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withOpacity(0.5), width: 2),
                        ),
                        child: Center(
                          child: Text(
                            user?.name.isNotEmpty == true
                                ? user!.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(user?.name ?? 'Pelanggan',
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(user?.email ?? '',
                          style: const TextStyle(
                              fontSize: 13, color: Colors.white70)),
                    ],
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
                  // Statistik
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 2))
                      ],
                    ),
                    child: Row(
                      children: [
                        _statItem('Total Order', '$totalOrders', '🛍️'),
                        _divider(),
                        _statItem('Selesai', '$completedOrders', '✅'),
                        _divider(),
                        _statItem('Pending', '$pendingOrders', '⏳'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Total spent
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2D6A4F), Color(0xFF52B788)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Text('💰', style: TextStyle(fontSize: 28)),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total Pengeluaran',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                            Text(
                              'Rp ${totalSpent.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Pengaturan Akun',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1B1B1B))),
                  const SizedBox(height: 10),
                  // Menu items
                  _profileMenu(Icons.person_outlined, 'Nama', user?.name ?? '-',
                      const Color(0xFF2D6A4F)),
                  _profileMenu(Icons.email_outlined, 'Email',
                      user?.email ?? '-', const Color(0xFF52B788)),
                  _profileMenu(Icons.verified_user_outlined, 'Role',
                      'Pelanggan', const Color(0xFFB7E4C7)),
                  const SizedBox(height: 20),
                  // Logout
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            title: const Text('Keluar?'),
                            content: const Text(
                                'Yakin ingin keluar dari akun ini?'),
                            actions: [
                              TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Batal')),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFE63946),
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
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFE63946),
                        side: const BorderSide(color: Color(0xFFE63946)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Keluar dari Akun',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, String emoji) {
    return Expanded(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1B1B1B))),
          Text(label,
              style:
                  const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
        width: 1, height: 50, color: const Color(0xFFE8EDE9));
  }

  Widget _profileMenu(
      IconData icon, String label, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF9E9E9E))),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B1B1B))),
            ],
          ),
        ],
      ),
    );
  }
}