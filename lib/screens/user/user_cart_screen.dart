import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import 'user_checkout_screen.dart';
import '../../utils/app_router.dart';

class UserCartScreen extends StatelessWidget {
  const UserCartScreen({super.key});

  IconData _categoryIcon(String name) {
    final n = name.toLowerCase();
    if (n.contains('latte') || n.contains('frappe') ||
        n.contains('matcha') || n.contains('milk') ||
        n.contains('americano')) return Icons.local_cafe_outlined;
    if (n.contains('cake') || n.contains('pancake') ||
        n.contains('ice cream')) return Icons.cake_outlined;
    return Icons.cookie_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F4),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xFF6B7D1F),
            title: const Text('Keranjang',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 20)),
            actions: [
              if (cart.items.isNotEmpty)
                TextButton(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        title: const Text('Kosongkan Keranjang'),
                        content: const Text(
                            'Yakin ingin mengosongkan semua item?'),
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
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Kosongkan'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) await cart.clearCart();
                  },
                  child: const Text('Hapus Semua',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 13)),
                ),
            ],
          ),
          cart.items.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F1E7),
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: const Center(
                            child: Icon(Icons.shopping_bag_outlined,
                                size: 48, color: Color(0xFF6B7D1F)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('Keranjang Kosong',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1B1B1B))),
                        const SizedBox(height: 6),
                        const Text(
                            'Tambahkan menu favoritmu dulu yuk!',
                            style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF9E9E9E))),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding:
                      const EdgeInsets.fromLTRB(16, 16, 16, 120),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        final item = cart.items[i];
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration:
                              Duration(milliseconds: 200 + (i * 60)),
                          builder: (_, val, child) => Opacity(
                            opacity: val,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - val)),
                              child: child,
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                    color:
                                        Colors.black.withOpacity(0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2))
                              ],
                            ),
                            child: Row(
                              children: [
                                // Emoji
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFF3F1E7),
                                        Color(0xFFA9B388)
                                      ],
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(14),
                                  ),
                                  child: Center(
                                    child: Icon(
                                        _categoryIcon(item.name),
                                        size: 26,
                                        color: const Color(0xFF6B7D1F)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(item.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                              color: Color(0xFF1B1B1B))),
                                      const SizedBox(height: 2),
                                      // Kustomisasi
                                      if (item.customizationLabel
                                          .isNotEmpty)
                                        Container(
                                          margin: const EdgeInsets.only(
                                              bottom: 4),
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF6B7D1F)
                                                .withOpacity(0.08),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            item.customizationLabel,
                                            style: const TextStyle(
                                                fontSize: 10,
                                                color: Color(0xFF6B7D1F),
                                                fontWeight:
                                                    FontWeight.w600),
                                          ),
                                        ),
                                      Text(
                                        'Rp ${item.pricePerItem.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} / item',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF9E9E9E)),
                                      ),
                                    ],
                                  ),
                                ),
                                // Qty controls
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Rp ${item.totalPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 13,
                                          color: Color(0xFF6B7D1F)),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(children: [
                                      _qtyBtn(
                                        icon: Icons.remove_rounded,
                                        onTap: () => cart.updateQuantity(
                                            i, item.quantity - 1),
                                        color: const Color(0xFFE63946),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets
                                            .symmetric(horizontal: 10),
                                        child: Text('${item.quantity}',
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight:
                                                    FontWeight.w800,
                                                color:
                                                    Color(0xFF1B1B1B))),
                                      ),
                                      _qtyBtn(
                                        icon: Icons.add_rounded,
                                        onTap: () => cart.updateQuantity(
                                            i, item.quantity + 1),
                                        color: const Color(0xFF6B7D1F),
                                      ),
                                    ]),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: cart.items.length,
                    ),
                  ),
                ),
        ],
      ),
      bottomSheet: cart.items.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, -4))
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Pembayaran',
                          style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9E9E9E))),
                      Text(
                        'Rp ${cart.totalPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF6B7D1F)),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const UserCheckoutScreen())),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B7D1F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: const Text('Checkout',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _qtyBtn(
      {required IconData icon,
      required VoidCallback onTap,
      required Color color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}