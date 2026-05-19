import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import 'package:flutter/services.dart';

class UserCheckoutScreen extends StatefulWidget {
  const UserCheckoutScreen({super.key});

  @override
  State<UserCheckoutScreen> createState() => _UserCheckoutScreenState();
}

class _UserCheckoutScreenState extends State<UserCheckoutScreen> {
  final _noteController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isLoading = false;

  // Tipe pesanan
  String _orderType = 'pickup'; // 'pickup' atau 'delivery'

  // Pickup time
  DateTime _pickupDate = DateTime.now().add(const Duration(minutes: 30));
  TimeOfDay _pickupTime = TimeOfDay.now();

  // Delivery
  double _deliveryFee = 0;
  final double _feePerKm = 2000;
  double _estimatedKm = 0;

  @override
  void dispose() {
    _noteController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  String get _formattedPickupTime {
    final date = DateFormat('dd MMM yyyy').format(_pickupDate);
    final time = _pickupTime.format(context);
    return '$date, $time';
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _pickupDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 7)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF6B7D1F),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _pickupDate = picked);
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _pickupTime,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF6B7D1F),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _pickupTime = picked);
  }

  void _calculateDeliveryFee(String address) {
    // Simulasi perhitungan jarak berdasarkan panjang alamat
    // Di produksi bisa pakai Google Maps Distance Matrix API
    if (address.trim().length < 10) {
      setState(() {
        _estimatedKm = 0;
        _deliveryFee = 0;
      });
      return;
    }
    // Simulasi: setiap 20 karakter = 1 km
    final km = (address.trim().length / 20).clamp(1.0, 15.0);
    setState(() {
      _estimatedKm = double.parse(km.toStringAsFixed(1));
      _deliveryFee = (km * _feePerKm).roundToDouble();
    });
  }

  Future<void> _placeOrder() async {
    // Validasi
    if (_orderType == 'delivery' &&
        _addressController.text.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Masukkan alamat lengkap untuk delivery'),
        backgroundColor: Color(0xFFE63946),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    setState(() => _isLoading = true);

    final cart = context.read<CartProvider>();
    final auth = context.read<AuthProvider>();
    final orderProvider = context.read<OrderProvider>();

    final pickupTimeStr = _orderType == 'pickup' ? _formattedPickupTime : null;
    final deliveryAddr =
        _orderType == 'delivery' ? _addressController.text.trim() : null;

    final success = await orderProvider.placeOrder(
      user: auth.currentUser!,
      items: List.from(cart.items),
      totalPrice: cart.totalPrice,
      deliveryFee: _orderType == 'delivery' ? _deliveryFee : 0,
      note: _noteController.text.trim(),
      orderType: _orderType,
      pickupTime: pickupTimeStr,
      deliveryAddress: deliveryAddr,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      await cart.clearCart();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_orderType == 'pickup'
            ? 'Pesanan dibuat! Ambil pada $_formattedPickupTime'
            : 'Pesanan dibuat! Segera diantarkan'),
        backgroundColor: const Color(0xFF6B7D1F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Gagal membuat pesanan. Coba lagi.'),
        backgroundColor: Color(0xFFE63946),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final grandTotal =
        cart.totalPrice + (_orderType == 'delivery' ? _deliveryFee : 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B7D1F),
        foregroundColor: Colors.white,
        title: const Text('Konfirmasi Pesanan',
            style: TextStyle(fontWeight: FontWeight.w800)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Ringkasan item ──────────────────────────────
            _sectionCard(
              title: 'Ringkasan Pesanan',
              child: Column(
                children: [
                  ...cart.items.asMap().entries.map((entry) {
                    final item = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${item.name} x${item.quantity}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1B1B1B))),
                                if (item.customizationLabel.isNotEmpty)
                                  Text(item.customizationLabel,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF9E9E9E))),
                              ],
                            ),
                          ),
                          Text(
                              'Rp ${item.totalPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF6B7D1F))),
                        ],
                      ),
                    );
                  }),
                  const Divider(height: 20),
                  _priceRow('Subtotal', cart.totalPrice),
                  if (_orderType == 'delivery') ...[
                    const SizedBox(height: 4),
                    _priceRow('Ongkos Kirim ($_estimatedKm km)', _deliveryFee),
                  ],
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Bayar',
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: Color(0xFF1B1B1B))),
                      Text(
                          'Rp ${grandTotal.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: Color(0xFF6B7D1F))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── Tipe pesanan ────────────────────────────────
            _sectionCard(
              title: 'Tipe Pesanan',
              child: Row(children: [
                Expanded(
                  child: _orderTypeBtn(
                    icon: Icons.directions_walk_rounded,
                    label: 'Pick Up',
                    subtitle: 'Ambil sendiri',
                    value: 'pickup',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _orderTypeBtn(
                    icon: Icons.delivery_dining_rounded,
                    label: 'Delivery',
                    subtitle: 'Diantar ke kamu',
                    value: 'delivery',
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 14),

            // ── Pickup: pilih waktu ─────────────────────────
            if (_orderType == 'pickup')
              _sectionCard(
                title: 'Waktu Pengambilan',
                child: Column(children: [
                  _timeSelector(
                    icon: Icons.calendar_today_rounded,
                    label: 'Tanggal',
                    value: DateFormat('dd MMM yyyy').format(_pickupDate),
                    onTap: _selectDate,
                  ),
                  const SizedBox(height: 10),
                  _timeSelector(
                    icon: Icons.access_time_rounded,
                    label: 'Jam',
                    value: _pickupTime.format(context),
                    onTap: _selectTime,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B7D1F).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(children: [
                      const Icon(Icons.check_circle_outline_rounded,
                          size: 16, color: Color(0xFF6B7D1F)),
                      const SizedBox(width: 8),
                      Text(
                        'Siap diambil: $_formattedPickupTime',
                        style: const TextStyle(
                            color: Color(0xFF6B7D1F),
                            fontWeight: FontWeight.w600,
                            fontSize: 13),
                      ),
                    ]),
                  ),
                ]),
              ),

            // ── Delivery: alamat ────────────────────────────
            if (_orderType == 'delivery')
              _sectionCard(
                title: 'Alamat Pengiriman',
                child: Column(children: [
                  TextField(
                    controller: _addressController,
                    maxLines: 3,
                    onChanged: _calculateDeliveryFee,
                    decoration: InputDecoration(
                      hintText:
                          'Masukkan alamat lengkap...\nContoh: Jl. Matcha No. 17, Surabaya',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFE8EDE9))),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFE8EDE9))),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFF6B7D1F), width: 1.5)),
                      filled: true,
                      fillColor: const Color(0xFFF8F9F4),
                    ),
                  ),
                  if (_deliveryFee > 0) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4A261).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color(0xFFF4A261).withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Estimasi $_estimatedKm km',
                            style: const TextStyle(
                                fontSize: 13, color: Color(0xFF4A4A4A)),
                          ),
                          Text(
                              'Rp ${_deliveryFee.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFF4A261))),
                        ],
                      ),
                    ),
                  ],
                ]),
              ),

            const SizedBox(height: 14),

            // ── Catatan ─────────────────────────────────────
            _sectionCard(
              title: 'Catatan (opsional)',
              child: TextField(
                controller: _noteController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Pesan khusus untuk barista...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE8EDE9))),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE8EDE9))),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: Color(0xFF6B7D1F), width: 1.5)),
                  filled: true,
                  fillColor: const Color(0xFFF8F9F4),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Tombol pesan ────────────────────────────────
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        HapticFeedback.heavyImpact();
                        _placeOrder();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B7D1F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : Text(
                        _orderType == 'pickup'
                            ? 'Pesan & Pick Up'
                            : 'Pesan & Delivery',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
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
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: Color(0xFF1B1B1B))),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _orderTypeBtn({
    required IconData icon,
    required String label,
    required String subtitle,
    required String value,
  }) {
    final isSelected = _orderType == value;
    return GestureDetector(
      onTap: () => setState(() => _orderType = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6B7D1F).withOpacity(0.08)
              : const Color(0xFFF8F9F4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF6B7D1F) : const Color(0xFFE8EDE9),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(children: [
          Icon(icon,
              size: 28,
              color: isSelected
                  ? const Color(0xFF6B7D1F)
                  : const Color(0xFF9E9E9E)),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: isSelected
                      ? const Color(0xFF6B7D1F)
                      : const Color(0xFF1B1B1B))),
          Text(subtitle,
              style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
        ]),
      ),
    );
  }

  Widget _timeSelector({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9F4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE8EDE9)),
        ),
        child: Row(children: [
          Icon(icon, color: const Color(0xFF6B7D1F), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF9E9E9E))),
                Text(value,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, color: Color(0xFF1B1B1B))),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: Color(0xFF9E9E9E), size: 20),
        ]),
      ),
    );
  }

  Widget _priceRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF9E9E9E))),
        Text(
            'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: Color(0xFF4A4A4A))),
      ],
    );
  }
}
