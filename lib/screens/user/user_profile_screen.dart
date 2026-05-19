import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../services/firestore_service.dart';
import '../user/login_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _isEditingName = false;
  final _nameController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveName(BuildContext context) async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      final user = context.read<AuthProvider>().currentUser!;
      await FirestoreService().updateUserName(user.userId, newName);
      await context.read<AuthProvider>().loadCurrentUser();

      if (context.mounted) {
        setState(() {
          _isEditingName = false;
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Nama berhasil diperbarui!'),
          backgroundColor: Color(0xFF6B7D1F),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (context.mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal memperbarui: $e'),
          backgroundColor: const Color(0xFFE63946),
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final orders = context.watch<OrderProvider>().orders;

    final totalOrders = orders.length;
    final completedOrders =
        orders.where((o) => o.status == 'completed').length;
    final pendingOrders = orders
        .where((o) =>
            o.status == 'pending' || o.status == 'processing')
        .length;
    final totalSpent = orders
        .where((o) => o.status == 'completed')
        .fold(0.0, (sum, o) => sum + o.grandTotal);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F4),
      body: CustomScrollView(
        slivers: [
          // AppBar dengan avatar
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xFF6B7D1F),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1B4332), Color(0xFF6B7D1F)],
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
                              color: Colors.white.withOpacity(0.5),
                              width: 2),
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
                      // Nama (bisa diedit)
                      _isEditingName
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 60),
                              child: Row(children: [
                                Expanded(
                                  child: TextField(
                                    controller: _nameController,
                                    autofocus: true,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white),
                                    decoration: const InputDecoration(
                                      border: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.white54),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.white54),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.white,
                                            width: 2),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _isSaving
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2))
                                    : GestureDetector(
                                        onTap: () =>
                                            _saveName(context),
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.2),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                              Icons.check_rounded,
                                              color: Colors.white,
                                              size: 18),
                                        ),
                                      ),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () => setState(
                                      () => _isEditingName = false),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close_rounded,
                                        color: Colors.white, size: 18),
                                  ),
                                ),
                              ]),
                            )
                          : GestureDetector(
                              onTap: () {
                                _nameController.text =
                                    user?.name ?? '';
                                setState(() => _isEditingName = true);
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Text(
                                    user?.name ?? 'Pelanggan',
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius:
                                          BorderRadius.circular(6),
                                    ),
                                    child: const Icon(
                                        Icons.edit_rounded,
                                        color: Colors.white70,
                                        size: 14),
                                  ),
                                ],
                              ),
                            ),
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
                    child: Row(children: [
                      _statItem('Total Order', '$totalOrders', Icons.shopping_bag_outlined),
                      _divider(),
                      _statItem('Selesai', '$completedOrders', Icons.check_circle_outline_rounded),
                      _divider(),
                      _statItem('Aktif', '$pendingOrders', Icons.history_rounded),
                    ]),
                  ),
                  const SizedBox(height: 12),

                  // Total pengeluaran
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6B7D1F), Color(0xFFB7D64A)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(children: [
                      const Icon(Icons.monetization_on_outlined,
                          size: 28, color: Colors.white),
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
                    ]),
                  ),
                  const SizedBox(height: 20),

                  const Text('Informasi Akun',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1B1B1B))),
                  const SizedBox(height: 10),

                  _infoTile(
                    icon: Icons.person_rounded,
                    label: 'Nama',
                    value: user?.name ?? '-',
                    color: const Color(0xFF6B7D1F),
                    onTap: () {
                      _nameController.text = user?.name ?? '';
                      setState(() => _isEditingName = true);
                    },
                    trailing: const Icon(Icons.edit_rounded,
                        size: 16, color: Color(0xFF9E9E9E)),
                  ),
                  _infoTile(
                    icon: Icons.email_rounded,
                    label: 'Email',
                    value: user?.email ?? '-',
                    color: const Color(0xFFB7D64A),
                  ),
                  _infoTile(
                    icon: Icons.verified_user_rounded,
                    label: 'Role',
                    value: 'Pelanggan Matchacih',
                    color: const Color(0xFFA9B388),
                  ),

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
                                borderRadius:
                                    BorderRadius.circular(20)),
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
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFE63946),
                        side: const BorderSide(
                            color: Color(0xFFE63946)),
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
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

  Widget _statItem(String label, String value, IconData icon) {
    return Expanded(
      child: Column(children: [
        Icon(icon, size: 22, color: const Color(0xFF6B7D1F)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1B1B1B))),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: Color(0xFF9E9E9E))),
      ]),
    );
  }

  Widget _divider() {
    return Container(
        width: 1, height: 50, color: const Color(0xFFE8EDE9));
  }

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Row(children: [
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
          Expanded(
            child: Column(
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
          ),
          if (trailing != null) trailing,
        ]),
      ),
    );
  }
}