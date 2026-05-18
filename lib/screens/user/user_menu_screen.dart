import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../providers/menu_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/menu_model.dart';
import '../../widgets/shimmer_loading.dart';
import 'package:flutter/services.dart';

class UserMenuScreen extends StatefulWidget {
  final VoidCallback? onGoToCart;
  const UserMenuScreen({super.key, this.onGoToCart});

  @override
  State<UserMenuScreen> createState() => _UserMenuScreenState();
}

class _UserMenuScreenState extends State<UserMenuScreen>
    with SingleTickerProviderStateMixin {
  String _selectedCategory = 'all';
  String _searchQuery = '';
  final _searchController = TextEditingController();
  late AnimationController _animController;

  // Banner
  final PageController _bannerController = PageController();
  int _currentBanner = 0;
  Timer? _bannerTimer;

  final List<Map<String, dynamic>> _banners = [
    {
      'title': 'Selamat Datang di Matchacih! 🍵',
      'subtitle': 'Nikmati matcha premium dengan harga terjangkau',
      'color1': const Color(0xFF1B4332),
      'color2': const Color(0xFF2D6A4F),
      'emoji': '🍵',
    },
    {
      'title': 'New! Matcha Cloud ☁️',
      'subtitle': 'Es krim vanilla + matcha = surga di mulut',
      'color1': const Color(0xFF2D6A4F),
      'color2': const Color(0xFF52B788),
      'emoji': '☁️',
    },
    {
      'title': 'Kustomisasi Matchamu ✨',
      'subtitle': 'Pilih grade, kadar, gula, dan es sesuai selera',
      'color1': const Color(0xFF52B788),
      'color2': const Color(0xFF95D5B2),
      'emoji': '✨',
    },
  ];

  final List<Map<String, String>> _categories = [
    {'value': 'all', 'label': '✨ Semua'},
    {'value': 'drink', 'label': '🍵 Minuman'},
    {'value': 'food', 'label': '🍰 Makanan'},
    {'value': 'snack', 'label': '🍪 Snack'},
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animController.forward();

    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_bannerController.hasClients) {
        final next = (_currentBanner + 1) % _banners.length;
        _bannerController.animateToPage(
          next,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animController.dispose();
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  List<MenuModel> _filteredMenus(List<MenuModel> menus) {
    return menus.where((m) {
      final matchCategory =
          _selectedCategory == 'all' || m.category == _selectedCategory;
      final matchSearch = _searchQuery.isEmpty ||
          m.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchCategory && matchSearch;
    }).toList();
  }

  void _openDetail(BuildContext context, MenuModel menu, CartProvider cart) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MenuDetailSheet(menu: menu, cart: cart),
    );
  }

  String _menuEmoji(String category) {
    switch (category) {
      case 'drink': return '🍵';
      case 'food': return '🍱';
      case 'snack': return '🍰';
      default: return '✨';
    }
  }

  String _categoryLabel(String category) {
    switch (category) {
      case 'drink': return 'Minuman';
      case 'food': return 'Makanan';
      case 'snack': return 'Snack';
      default: return category;
    }
  }

  Widget _buildMenuImage(MenuModel menu, {BorderRadius? borderRadius}) {
    Widget imageWidget;

    if (menu.imageBase64.isNotEmpty) {
      imageWidget = Image.memory(
        Uri.parse(menu.imageBase64).data!.contentAsBytes(),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    } else if (menu.imageUrl.isNotEmpty) {
      imageWidget = CachedNetworkImage(
        imageUrl: menu.imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (_, __) => _imagePlaceholder(menu.category),
        errorWidget: (_, __, ___) => _imagePlaceholder(menu.category),
      );
    } else {
      imageWidget = _imagePlaceholder(menu.category);
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius, child: imageWidget);
    }
    return imageWidget;
  }

  Widget _imagePlaceholder(String category) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD8F3DC), Color(0xFF95D5B2)],
        ),
      ),
      child: Center(
        child: Text(_menuEmoji(category),
            style: const TextStyle(fontSize: 48)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = context.watch<MenuProvider>();
    final cartProvider = context.watch<CartProvider>();
    final menus = _filteredMenus(menuProvider.menus);
    final user = context.read<AuthProvider>().currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F4),
      body: CustomScrollView(
        slivers: [
          // AppBar
          SliverAppBar(
            expandedHeight: 130,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF2D6A4F),
            automaticallyImplyLeading: false,
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
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Halo, ${user?.name ?? 'Pelanggan'} 👋',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13),
                            ),
                            const Text(
                              'Matchacih',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => widget.onGoToCart?.call(),
                          child: Stack(children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                  Icons.shopping_bag_outlined,
                                  color: Colors.white,
                                  size: 22),
                            ),
                            if (cartProvider.totalItems > 0)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE63946),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${cartProvider.totalItems}',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                          ]),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Search + Banner + Filter
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                children: [
                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2))
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: 'Cari minuman atau makanan...',
                        hintStyle: const TextStyle(
                            color: Color(0xFF9E9E9E), fontSize: 14),
                        prefixIcon: const Icon(Icons.search_rounded,
                            color: Color(0xFF2D6A4F), size: 22),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded,
                                    size: 18, color: Color(0xFF9E9E9E)),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                })
                            : null,
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Banner Carousel
                  SizedBox(
                    height: 130,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        PageView.builder(
                          controller: _bannerController,
                          onPageChanged: (i) =>
                              setState(() => _currentBanner = i),
                          itemCount: _banners.length,
                          itemBuilder: (_, i) {
                            final banner = _banners[i];
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    banner['color1'] as Color,
                                    banner['color2'] as Color,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Stack(
                                children: [
                                  // Emoji bg besar
                                  Positioned(
                                    right: 16,
                                    top: 0,
                                    bottom: 0,
                                    child: Center(
                                      child: Text(
                                        banner['emoji'] as String,
                                        style: TextStyle(
                                            fontSize: 64,
                                            color: Colors.white
                                                .withOpacity(0.18)),
                                      ),
                                    ),
                                  ),
                                  // Teks
                                  Padding(
                                    padding: const EdgeInsets.all(18),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          banner['title'] as String,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800,
                                              height: 1.3),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          banner['subtitle'] as String,
                                          style: TextStyle(
                                              color: Colors.white
                                                  .withOpacity(0.85),
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        // Page indicator
                        Positioned(
                          bottom: 10,
                          child: SmoothPageIndicator(
                            controller: _bannerController,
                            count: _banners.length,
                            effect: const WormEffect(
                              dotWidth: 6,
                              dotHeight: 6,
                              spacing: 4,
                              dotColor: Colors.white38,
                              activeDotColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Filter chips
                  SizedBox(
                    height: 38,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (_, i) {
                        final cat = _categories[i];
                        final isSelected =
                            _selectedCategory == cat['value'];
                        return GestureDetector(
                          onTap: () => setState(
                              () => _selectedCategory = cat['value']!),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF2D6A4F)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF2D6A4F)
                                    : const Color(0xFFE8EDE9),
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                          color: const Color(0xFF2D6A4F)
                                              .withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2))
                                    ]
                                  : [],
                            ),
                            child: Text(cat['label']!,
                                style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF4A4A4A),
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    fontSize: 13)),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Grid menu
          menuProvider.isLoading
    ? SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        sliver: SliverGrid(
          delegate: SliverChildBuilderDelegate(
            (_, __) => const MenuCardShimmer(),
            childCount: 6,
          ),
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.72,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
        ),
      )
              : menus.isEmpty
                  ? const SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('🍵', style: TextStyle(fontSize: 48)),
                            SizedBox(height: 12),
                            Text('Menu tidak ditemukan',
                                style: TextStyle(
                                    color: Color(0xFF9E9E9E),
                                    fontSize: 15)),
                          ],
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding:
                          const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration:
                                Duration(milliseconds: 300 + (i * 50)),
                            builder: (_, val, child) => Opacity(
                              opacity: val,
                              child: Transform.translate(
                                offset: Offset(0, 20 * (1 - val)),
                                child: child,
                              ),
                            ),
                            child: _menuCard(
                                context, menus[i], cartProvider),
                          ),
                          childCount: menus.length,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                      ),
                    ),
        ],
      ),
    );
  }

  Widget _menuCard(
      BuildContext context, MenuModel menu, CartProvider cart) {
    return GestureDetector(
      onTap: () => _openDetail(context, menu, cart),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  // Gambar dengan AspectRatio 1:1
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(18)),
                    child: SizedBox.expand(
                      child: _buildMenuImage(menu),
                    ),
                  ),
                  // Overlay stok habis
                  if (!menu.isAvailable)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(18)),
                        child: Container(
                          color: Colors.black.withOpacity(0.5),
                          child: const Center(
                            child: Text('Habis',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16)),
                          ),
                        ),
                      ),
                    ),
                  // Badge kategori
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_categoryLabel(menu.category),
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2D6A4F))),
                    ),
                  ),
                  // Badge custom (khusus minuman)
                  if (menu.isDrink)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D6A4F),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('✨ Custom',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ),
                    ),
                ],
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(menu.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: Color(0xFF1B1B1B))),
                  const SizedBox(height: 2),
                  Text(
                    'Rp ${menu.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                    style: const TextStyle(
                        color: Color(0xFF2D6A4F),
                        fontWeight: FontWeight.w700,
                        fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: menu.isAvailable
                        ? () => _openDetail(context, menu, cart)
                        : null,
                    child: Container(
                      height: 34,
                      decoration: BoxDecoration(
                        color: menu.isAvailable
                            ? const Color(0xFF2D6A4F)
                            : const Color(0xFFE8EDE9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          menu.isAvailable
                              ? (menu.isDrink
                                  ? '✨ Pilih & Custom'
                                  : '+ Keranjang')
                              : 'Habis',
                          style: TextStyle(
                              color: menu.isAvailable
                                  ? Colors.white
                                  : const Color(0xFF9E9E9E),
                              fontSize: 11,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── DETAIL + KUSTOMISASI BOTTOM SHEET ──────────────────────────────────────

class _MenuDetailSheet extends StatefulWidget {
  final MenuModel menu;
  final CartProvider cart;
  const _MenuDetailSheet({required this.menu, required this.cart});

  @override
  State<_MenuDetailSheet> createState() => _MenuDetailSheetState();
}

class _MenuDetailSheetState extends State<_MenuDetailSheet>
    with SingleTickerProviderStateMixin {
  int _qty = 1;
  late AnimationController _controller;
  late Animation<Offset> _slideAnim;

  String _matchaGrade = 'culinary';
  double _matchaLevel = 3;
  String _sugarLevel = 'normal';
  String _iceLevel = 'normal';

  final _grades = [
    {
      'value': 'culinary',
      'label': 'Culinary',
      'desc': 'Rasa kuat & earthy',
      'extra': '+Rp 0',
      'emoji': '🌿',
    },
    {
      'value': 'premium',
      'label': 'Premium',
      'desc': 'Seimbang & creamy',
      'extra': '+Rp 4.000',
      'emoji': '⭐',
    },
    {
      'value': 'ceremonial',
      'label': 'Ceremonial',
      'desc': 'Lembut & autentik',
      'extra': '+Rp 8.000',
      'emoji': '👑',
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _gradeExtra {
    switch (_matchaGrade) {
      case 'ceremonial': return 8000;
      case 'premium': return 4000;
      default: return 0;
    }
  }

  double get _sugarExtra => _sugarLevel == 'extra' ? 2000 : 0;
  double get _pricePerItem => widget.menu.price + _gradeExtra + _sugarExtra;
  double get _totalPrice => _pricePerItem * _qty;

  String _menuEmoji(String category) {
    switch (category) {
      case 'drink': return '🍵';
      case 'food': return '🍱';
      case 'snack': return '🍰';
      default: return '✨';
    }
  }

  String _matchaLevelLabel(double val) {
    switch (val.round()) {
      case 1: return 'Sangat Ringan';
      case 2: return 'Ringan';
      case 3: return 'Sedang';
      case 4: return 'Kuat';
      case 5: return 'Sangat Kuat';
      default: return 'Sedang';
    }
  }

  Widget _buildMenuImage() {
    final menu = widget.menu;
    Widget imageWidget;

    if (menu.imageBase64.isNotEmpty) {
      imageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.memory(
          Uri.parse(menu.imageBase64).data!.contentAsBytes(),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    } else if (menu.imageUrl.isNotEmpty) {
      imageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: CachedNetworkImage(
          imageUrl: menu.imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          placeholder: (_, __) => Center(
              child: Text(_menuEmoji(menu.category),
                  style: const TextStyle(fontSize: 70))),
          errorWidget: (_, __, ___) => Center(
              child: Text(_menuEmoji(menu.category),
                  style: const TextStyle(fontSize: 70))),
        ),
      );
    } else {
      imageWidget = Center(
          child: Text(_menuEmoji(menu.category),
              style: const TextStyle(fontSize: 70)));
    }

    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFD8F3DC), Color(0xFF95D5B2)],
        ),
      ),
      child: imageWidget,
    );
  }

  @override
  Widget build(BuildContext context) {
    final menu = widget.menu;
    final isDrink = menu.isDrink;

    return SlideTransition(
      position: _slideAnim,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: DraggableScrollableSheet(
          initialChildSize: isDrink ? 0.92 : 0.65,
          maxChildSize: 0.95,
          minChildSize: isDrink ? 0.6 : 0.4,
          expand: false,
          builder: (_, scrollController) => SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EDE9),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                _buildMenuImage(),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(menu.name,
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1B1B1B))),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: menu.isAvailable
                                  ? const Color(0xFFD8F3DC)
                                  : const Color(0xFFFFE5E5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              menu.isAvailable
                                  ? 'Stok: ${menu.stock}'
                                  : 'Habis',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: menu.isAvailable
                                      ? const Color(0xFF2D6A4F)
                                      : const Color(0xFFE63946)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rp ${menu.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2D6A4F)),
                      ),
                      const SizedBox(height: 8),
                      Text(menu.description,
                          style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF4A4A4A),
                              height: 1.5)),

                      if (isDrink) ...[
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 12),

                        // Grade Matcha
                        const Text('Grade Matcha',
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: Color(0xFF1B1B1B))),
                        const SizedBox(height: 4),
                        const Text(
                            'Pilih kualitas matcha yang kamu inginkan',
                            style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF9E9E9E))),
                        const SizedBox(height: 10),
                        ...(_grades.map((grade) {
                          final isSelected =
                              _matchaGrade == grade['value'];
                          return GestureDetector(
                            onTap: () => setState(() =>
                                _matchaGrade = grade['value'] as String),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF2D6A4F)
                                        .withOpacity(0.06)
                                    : const Color(0xFFF8F9F4),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF2D6A4F)
                                      : const Color(0xFFE8EDE9),
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Row(children: [
                                Text(grade['emoji'] as String,
                                    style:
                                        const TextStyle(fontSize: 22)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(grade['label'] as String,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13,
                                              color: isSelected
                                                  ? const Color(0xFF2D6A4F)
                                                  : const Color(
                                                      0xFF1B1B1B))),
                                      Text(grade['desc'] as String,
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF9E9E9E))),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF2D6A4F)
                                        : const Color(0xFFE8EDE9),
                                    borderRadius:
                                        BorderRadius.circular(6),
                                  ),
                                  child: Text(grade['extra'] as String,
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: isSelected
                                              ? Colors.white
                                              : const Color(0xFF9E9E9E))),
                                ),
                                if (isSelected) ...[
                                  const SizedBox(width: 6),
                                  const Icon(Icons.check_circle_rounded,
                                      color: Color(0xFF2D6A4F), size: 18),
                                ],
                              ]),
                            ),
                          );
                        })),

                        const SizedBox(height: 16),

                        // Kadar Matcha
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Kadar Matcha',
                                style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: Color(0xFF1B1B1B))),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2D6A4F)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _matchaLevelLabel(_matchaLevel),
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF2D6A4F)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(children: [
                          const Text('🌿',
                              style: TextStyle(fontSize: 14)),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: const Color(0xFF2D6A4F),
                                inactiveTrackColor:
                                    const Color(0xFFE8EDE9),
                                thumbColor: const Color(0xFF2D6A4F),
                                overlayColor: const Color(0xFF2D6A4F)
                                    .withOpacity(0.15),
                                trackHeight: 4,
                              ),
                              child: Slider(
                                value: _matchaLevel,
                                min: 1,
                                max: 5,
                                divisions: 4,
                                onChanged: (v) =>
                                    setState(() => _matchaLevel = v),
                              ),
                            ),
                          ),
                          const Text('🍵',
                              style: TextStyle(fontSize: 14)),
                        ]),
                        const Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Ringan',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF9E9E9E))),
                            Text('Kuat',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF9E9E9E))),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Gula
                        const Text('Tingkat Kemanisan',
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: Color(0xFF1B1B1B))),
                        const SizedBox(height: 10),
                        Row(children: [
                          _optionChip('🍃 Less', 'less', _sugarLevel,
                              (v) => setState(() => _sugarLevel = v),
                              sub: 'Normal'),
                          const SizedBox(width: 8),
                          _optionChip('🍬 Normal', 'normal', _sugarLevel,
                              (v) => setState(() => _sugarLevel = v)),
                          const SizedBox(width: 8),
                          _optionChip('🍭 Extra', 'extra', _sugarLevel,
                              (v) => setState(() => _sugarLevel = v),
                              sub: '+Rp 2.000'),
                        ]),

                        const SizedBox(height: 16),

                        // Es
                        const Text('Tingkat Es',
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: Color(0xFF1B1B1B))),
                        const SizedBox(height: 10),
                        Row(children: [
                          _optionChip('🌡️ Less', 'less', _iceLevel,
                              (v) => setState(() => _iceLevel = v)),
                          const SizedBox(width: 8),
                          _optionChip('🧊 Normal', 'normal', _iceLevel,
                              (v) => setState(() => _iceLevel = v)),
                          const SizedBox(width: 8),
                          _optionChip('❄️ Extra', 'extra', _iceLevel,
                              (v) => setState(() => _iceLevel = v)),
                        ]),
                      ],

                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 12),

                      // Qty + Tambah
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9F4),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: const Color(0xFFE8EDE9)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: _qty > 1
                                      ? () => setState(() => _qty--)
                                      : null,
                                  icon: const Icon(Icons.remove_rounded),
                                  color: const Color(0xFF2D6A4F),
                                  iconSize: 18,
                                ),
                                Text('$_qty',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1B1B1B))),
                                IconButton(
                                  onPressed: () =>
                                      setState(() => _qty++),
                                  icon: const Icon(Icons.add_rounded),
                                  color: const Color(0xFF2D6A4F),
                                  iconSize: 18,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: menu.isAvailable
                                  ? () async {
                                    HapticFeedback.mediumImpact();
                                      await widget.cart.addToCart(
                                        menu,
                                        matchaGrade: _matchaGrade,
                                        matchaLevel: _matchaLevel.round(),
                                        sugarLevel: _sugarLevel,
                                        iceLevel: _iceLevel,
                                        quantity: _qty,
                                      );
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text(
                                              '$_qty x ${menu.name} ditambahkan!'),
                                          backgroundColor:
                                              const Color(0xFF2D6A4F),
                                          behavior:
                                              SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      10)),
                                        ));
                                      }
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2D6A4F),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: Text(
                                'Tambah  •  Rp ${_totalPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _optionChip(
    String label,
    String value,
    String selected,
    Function(String) onTap, {
    String? sub,
  }) {
    final isSelected = selected == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF2D6A4F).withOpacity(0.08)
                : const Color(0xFFF8F9F4),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF2D6A4F)
                  : const Color(0xFFE8EDE9),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? const Color(0xFF2D6A4F)
                          : const Color(0xFF4A4A4A))),
              if (sub != null)
                Text(sub,
                    style: TextStyle(
                        fontSize: 9,
                        color: isSelected
                            ? const Color(0xFF2D6A4F)
                            : const Color(0xFF9E9E9E))),
            ],
          ),
        ),
      ),
    );
  }
}