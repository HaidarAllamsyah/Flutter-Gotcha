import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import 'admin_dashboard_screen.dart';
import 'admin_menu_screen.dart';
import 'admin_orders_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pendingCount = context
        .watch<OrderProvider>()
        .orders
        .where((o) => o.status == 'pending')
        .length;

    final screens = [
      const AdminDashboardScreen(),
      const AdminMenuScreen(),
      const AdminOrdersScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(0, Icons.dashboard_rounded,
                    Icons.dashboard_outlined, 'Dashboard'),
                _navItem(1, Icons.restaurant_menu_rounded,
                    Icons.restaurant_menu_outlined, 'Menu'),
                _navItemBadge(2, Icons.receipt_rounded,
                    Icons.receipt_outlined, 'Pesanan', pendingCount),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(
      int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF2D6A4F).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isActive ? activeIcon : inactiveIcon,
                color: isActive
                    ? const Color(0xFF2D6A4F)
                    : const Color(0xFF9E9E9E),
                size: 24),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight:
                        isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive
                        ? const Color(0xFF2D6A4F)
                        : const Color(0xFF9E9E9E))),
          ],
        ),
      ),
    );
  }

  Widget _navItemBadge(int index, IconData activeIcon,
      IconData inactiveIcon, String label, int badge) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF2D6A4F).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(children: [
              Icon(isActive ? activeIcon : inactiveIcon,
                  color: isActive
                      ? const Color(0xFF2D6A4F)
                      : const Color(0xFF9E9E9E),
                  size: 24),
              if (badge > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                        color: Color(0xFFE63946),
                        shape: BoxShape.circle),
                    child: Center(
                      child: Text('$badge',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
            ]),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight:
                        isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive
                        ? const Color(0xFF2D6A4F)
                        : const Color(0xFF9E9E9E))),
          ],
        ),
      ),
    );
  }
}