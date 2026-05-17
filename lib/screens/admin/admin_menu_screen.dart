import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/menu_provider.dart';
import '../../models/menu_model.dart';
import 'admin_add_edit_menu_screen.dart';

class AdminMenuScreen extends StatefulWidget {
  const AdminMenuScreen({super.key});

  @override
  State<AdminMenuScreen> createState() => _AdminMenuScreenState();
}

class _AdminMenuScreenState extends State<AdminMenuScreen> {
  String _selectedCategory = 'all';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  final List<Map<String, String>> _categories = [
    {'value': 'all', 'label': 'Semua'},
    {'value': 'drink', 'label': '🍵 Minuman'},
    {'value': 'food', 'label': '🍰 Makanan'},
    {'value': 'snack', 'label': '🍪 Snack'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _menuEmoji(String category) {
    switch (category) {
      case 'drink': return '🍵';
      case 'food': return '🍰';
      case 'snack': return '🍪';
      default: return '✨';
    }
  }

  String _categoryLabel(String cat) {
    switch (cat) {
      case 'food': return 'Makanan';
      case 'drink': return 'Minuman';
      case 'snack': return 'Snack';
      default: return cat;
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = context.watch<MenuProvider>();
    List<MenuModel> menus = menuProvider.getByCategory(_selectedCategory);

    if (_searchQuery.isNotEmpty) {
      menus = menus
          .where((m) =>
              m.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F4),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xFF2D6A4F),
            title: const Text('Manajemen Menu',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 20)),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AdminAddEditMenuScreen()),
                  ),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add_rounded,
                        color: Colors.white, size: 22),
                  ),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                children: [
                  // Search
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
                        hintText: 'Cari menu...',
                        hintStyle: const TextStyle(
                            color: Color(0xFF9E9E9E), fontSize: 14),
                        prefixIcon: const Icon(Icons.search_rounded,
                            color: Color(0xFF2D6A4F), size: 20),
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
                  const SizedBox(height: 12),
                  // Filter
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
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          menuProvider.isLoading
              ? const SliverFillRemaining(
                  child: Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF2D6A4F))))
              : menus.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🍵',
                                style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 12),
                            const Text('Tidak ada menu',
                                style: TextStyle(
                                    color: Color(0xFF9E9E9E),
                                    fontSize: 15)),
                          ],
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) {
                            final menu = menus[i];
                            return TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: 1),
                              duration:
                                  Duration(milliseconds: 200 + (i * 50)),
                              builder: (_, val, child) => Opacity(
                                opacity: val,
                                child: Transform.translate(
                                  offset: Offset(0, 16 * (1 - val)),
                                  child: child,
                                ),
                              ),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
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
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(children: [
                                    // Foto/Emoji
                                    Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFD8F3DC),
                                            Color(0xFFB7E4C7)
                                          ],
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(14),
                                      ),
                                      child: menu.imageBase64.isEmpty
                                          ? Center(
                                              child: Text(
                                                  _menuEmoji(
                                                      menu.category),
                                                  style: const TextStyle(
                                                      fontSize: 30)))
                                          : ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      14),
                                              child: Image.memory(
                                                Uri.parse(menu.imageBase64)
                                                    .data!
                                                    .contentAsBytes(),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(menu.name,
                                              style: const TextStyle(
                                                  fontWeight:
                                                      FontWeight.w700,
                                                  fontSize: 14,
                                                  color:
                                                      Color(0xFF1B1B1B))),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Rp ${menu.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                                            style: const TextStyle(
                                                color: Color(0xFF2D6A4F),
                                                fontWeight: FontWeight.w700,
                                                fontSize: 13),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 3),
                                              decoration: BoxDecoration(
                                                color: const Color(
                                                        0xFF2D6A4F)
                                                    .withOpacity(0.08),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        6),
                                              ),
                                              child: Text(
                                                  _categoryLabel(
                                                      menu.category),
                                                  style: const TextStyle(
                                                      fontSize: 10,
                                                      color:
                                                          Color(0xFF2D6A4F),
                                                      fontWeight:
                                                          FontWeight.w600)),
                                            ),
                                            const SizedBox(width: 6),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 3),
                                              decoration: BoxDecoration(
                                                color: menu.stock == 0
                                                    ? const Color(0xFFE63946)
                                                        .withOpacity(0.1)
                                                    : const Color(0xFF52B788)
                                                        .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        6),
                                              ),
                                              child: Text(
                                                menu.stock == 0
                                                    ? 'Habis'
                                                    : 'Stok: ${menu.stock}',
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: menu.stock == 0
                                                        ? const Color(
                                                            0xFFE63946)
                                                        : const Color(
                                                            0xFF52B788),
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                          ]),
                                        ],
                                      ),
                                    ),
                                    // Actions
                                    Column(children: [
                                      GestureDetector(
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  AdminAddEditMenuScreen(
                                                      menu: menu)),
                                        ),
                                        child: Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF4895EF)
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: const Icon(
                                              Icons.edit_rounded,
                                              color: Color(0xFF4895EF),
                                              size: 18),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      GestureDetector(
                                        onTap: () => _confirmDelete(
                                            context,
                                            menu,
                                            context.read<MenuProvider>()),
                                        child: Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE63946)
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: const Icon(
                                              Icons.delete_rounded,
                                              color: Color(0xFFE63946),
                                              size: 18),
                                        ),
                                      ),
                                    ]),
                                  ]),
                                ),
                              ),
                            );
                          },
                          childCount: menus.length,
                        ),
                      ),
                    ),
        ],
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, MenuModel menu, MenuProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Menu?'),
        content: Text('Yakin ingin menghapus "${menu.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE63946),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            onPressed: () async {
              Navigator.pop(context);
              await provider.deleteMenu(menu.menuId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('Menu berhasil dihapus'),
                  backgroundColor: const Color(0xFFE63946),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ));
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}