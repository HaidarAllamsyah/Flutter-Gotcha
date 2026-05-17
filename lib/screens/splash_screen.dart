import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/menu_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../theme/app_theme.dart';
import 'user/login_screen.dart';
import 'admin/admin_main_screen.dart';
import 'user/user_main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _scaleAnim = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenAndNavigate();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _listenAndNavigate() {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isInitializing) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        _navigate(authProvider);
      });
      return;
    }
    authProvider.addListener(() {
      if (!authProvider.isInitializing && mounted) {
        Future.delayed(const Duration(milliseconds: 800), () {
          _navigate(authProvider);
        });
      }
    });
  }

  void _navigate(AuthProvider authProvider) {
    if (!mounted) return;
    if (authProvider.isLoggedIn) {
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
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primary,
              Color(0xFF1B4332),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo placeholder
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '🍵',
                          style: const TextStyle(fontSize: 52),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Matchacih',
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Sip the Green Goodness',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        color: Colors.white.withOpacity(0.7),
                        strokeWidth: 2.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}