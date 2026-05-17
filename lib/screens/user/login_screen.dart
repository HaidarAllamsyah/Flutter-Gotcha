import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/menu_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../admin/admin_main_screen.dart';
import 'user_main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    if (!mounted) return;
    if (success) {
      final user = authProvider.currentUser!;
      context.read<MenuProvider>().listenMenus();
      if (user.isAdmin) {
        context.read<OrderProvider>().listenAllOrders();
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const AdminMainScreen()));
      } else {
        context.read<CartProvider>().listenCart(user.userId);
        context.read<OrderProvider>().listenUserOrders(user.userId);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const UserMainScreen()));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(authProvider.errorMessage),
        backgroundColor: const Color(0xFFE63946),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            height: MediaQuery.of(context).size.height * 0.45,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.3)),
                            ),
                            child: const Center(
                              child: Text('🍵', style: TextStyle(fontSize: 38)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text('Matchacih',
                              style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -1)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text('Sip the Green Goodness',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Card form
                  SlideTransition(
                    position: _slideAnim,
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Selamat Datang!',
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1B1B1B))),
                              const SizedBox(height: 4),
                              const Text('Masuk untuk melanjutkan',
                                  style: TextStyle(
                                      fontSize: 13, color: Color(0xFF9E9E9E))),
                              const SizedBox(height: 24),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: const Icon(Icons.email_outlined,
                                      color: Color(0xFF2D6A4F), size: 20),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                  filled: true,
                                  fillColor: const Color(0xFFF8F9F4),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty)
                                    return 'Email wajib diisi';
                                  if (!v.contains('@'))
                                    return 'Format email tidak valid';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(Icons.lock_outlined,
                                      color: Color(0xFF2D6A4F), size: 20),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        size: 20,
                                        color: const Color(0xFF9E9E9E)),
                                    onPressed: () => setState(() =>
                                        _obscurePassword = !_obscurePassword),
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                  filled: true,
                                  fillColor: const Color(0xFFF8F9F4),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty)
                                    return 'Password wajib diisi';
                                  if (v.length < 6)
                                    return 'Password minimal 6 karakter';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2D6A4F),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14)),
                                    elevation: 0,
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5))
                                      : const Text('Masuk',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Demo accounts
                  SlideTransition(
                    position: _slideAnim,
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9F4),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFB7E4C7)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(children: [
                              Text('🔑', style: TextStyle(fontSize: 14)),
                              SizedBox(width: 6),
                              Text('Akun Demo',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: Color(0xFF2D6A4F))),
                              SizedBox(width: 4),
                              Text('(tap untuk isi otomatis)',
                                  style: TextStyle(
                                      fontSize: 11, color: Color(0xFF9E9E9E))),
                            ]),
                            const SizedBox(height: 10),
                            _demoTile('Admin', 'admin@resto.com', 'admin123',
                                const Color(0xFF2D6A4F)),
                            const SizedBox(height: 8),
                            _demoTile('User', 'user@resto.com', 'user123',
                                const Color(0xFF52B788)),
                          ],
                        ),
                      ),
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

  Widget _demoTile(String role, String email, String pass, Color color) {
    return GestureDetector(
      onTap: () {
        _emailController.text = email;
        _passwordController.text = pass;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(6)),
            child: Text(role,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Text('$email / $pass',
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF4A4A4A)))),
          Icon(Icons.north_west_rounded, size: 14, color: color),
        ]),
      ),
    );
  }
}