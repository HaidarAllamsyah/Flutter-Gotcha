import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/cart_item_model.dart';
import '../../models/user_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';

class UserQrisPaymentScreen extends StatefulWidget {
  final UserModel user;
  final List<CartItemModel> items;
  final double totalPrice;
  final double deliveryFee;
  final String note;
  final String orderType;
  final String? pickupTime;
  final String? deliveryAddress;

  const UserQrisPaymentScreen({
    super.key,
    required this.user,
    required this.items,
    required this.totalPrice,
    required this.deliveryFee,
    required this.note,
    required this.orderType,
    this.pickupTime,
    this.deliveryAddress,
  });

  @override
  State<UserQrisPaymentScreen> createState() => _UserQrisPaymentScreenState();
}

class _UserQrisPaymentScreenState extends State<UserQrisPaymentScreen> {
  static const String _qrisAssetPath = 'assets/images/qris/Gotcha.png';
  bool _isSubmitting = false;
  int _countdown = 15;
  Timer? _timer;
  bool _showSuccess = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        _timer?.cancel();
        _handlePaymentSuccess();
      }
    });
  }

  Future<void> _handlePaymentSuccess() async {
    setState(() {
      _showSuccess = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    _confirmPayment();
  }

  double get _grandTotal => widget.totalPrice + widget.deliveryFee;

  Future<void> _confirmPayment() async {
    setState(() => _isSubmitting = true);

    final orderProvider = context.read<OrderProvider>();
    final cart = context.read<CartProvider>();

    final success = await orderProvider.placeOrder(
      user: widget.user,
      items: widget.items,
      totalPrice: widget.totalPrice,
      deliveryFee: widget.deliveryFee,
      note: widget.note,
      orderType: widget.orderType,
      paymentMethod: 'QRIS',
      pickupTime: widget.pickupTime,
      deliveryAddress: widget.deliveryAddress,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Gagal membuat pesanan. Coba lagi.'),
        backgroundColor: Color(0xFFE63946),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    await cart.clearCart();
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(widget.orderType == 'pickup'
          ? 'Pembayaran berhasil! Pesanan masuk dan siap diproses.'
          : 'Pembayaran berhasil! Pesanan delivery masuk.'),
      backgroundColor: const Color(0xFF6B7D1F),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 3),
    ));

    Navigator.of(context)
      ..pop()
      ..pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B7D1F),
        foregroundColor: Colors.white,
        title: const Text('Pembayaran QRIS',
            style: TextStyle(fontWeight: FontWeight.w800)),
        elevation: 0,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: _showSuccess
            ? _buildSuccessAnimation()
            : _buildPaymentContent(),
      ),
    );
  }

  Widget _buildSuccessAnimation() {
    return Center(
      key: const ValueKey('successAnimation'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 800),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF6B7D1F),
                  size: 140,
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Pembayaran Berhasil!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1B1B1B),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pesanan Anda sedang diproses',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF9E9E9E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentContent() {
    return SingleChildScrollView(
      key: const ValueKey('paymentContent'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(children: [
              const Icon(Icons.qr_code_2_rounded,
                  size: 36, color: Color(0xFF6B7D1F)),
              const SizedBox(height: 8),
              const Text('Scan QRIS',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1B1B1B))),
              const SizedBox(height: 4),
              const Text('Gunakan aplikasi pembayaran favorit kamu',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
              const SizedBox(height: 18),
              AspectRatio(
                aspectRatio: 1,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9F4),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE8EDE9)),
                  ),
                  child: Image.asset(
                    _qrisAssetPath,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: const Color(0xFFE8EDE9)),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.qr_code_2_rounded,
                                size: 96, color: Color(0xFF6B7D1F)),
                            SizedBox(height: 10),
                            Text('Taruh barcode di sini',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1B1B1B))),
                            SizedBox(height: 4),
                            Text('assets/images/qris/qris.png',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF9E9E9E))),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(children: [
              _priceRow('Subtotal', widget.totalPrice),
              if (widget.deliveryFee > 0) ...[
                const SizedBox(height: 6),
                _priceRow('Ongkos Kirim', widget.deliveryFee),
              ],
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Bayar',
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: Color(0xFF1B1B1B))),
                  Text(
                    _formatCurrency(_grandTotal),
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        color: Color(0xFF6B7D1F)),
                  ),
                ],
              ),
            ]),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8EDE9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF6B7D1F),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Menunggu Pembayaran... 00:${_countdown.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF6B7D1F),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF9E9E9E))),
        Text(_formatCurrency(amount),
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: Color(0xFF4A4A4A))),
      ],
    );
  }

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }
}
