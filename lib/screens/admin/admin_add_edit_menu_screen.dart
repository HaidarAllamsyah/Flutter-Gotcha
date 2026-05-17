import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/menu_model.dart';
import '../../providers/menu_provider.dart';

class AdminAddEditMenuScreen extends StatefulWidget {
  final MenuModel? menu;
  const AdminAddEditMenuScreen({super.key, this.menu});

  @override
  State<AdminAddEditMenuScreen> createState() => _AdminAddEditMenuScreenState();
}

class _AdminAddEditMenuScreenState extends State<AdminAddEditMenuScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _descController = TextEditingController();
  final _imageUrlController = TextEditingController();

  String _selectedCategory = 'drink';
  String _imageBase64 = '';
  bool _isLoading = false;

  bool get isEdit => widget.menu != null;

  final List<Map<String, String>> _categories = [
    {'value': 'drink', 'label': '🍵 Minuman'},
    {'value': 'food', 'label': '🍱 Makanan'},
    {'value': 'snack', 'label': '🍰 Snack'},
  ];

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _nameController.text = widget.menu!.name;
      _priceController.text = widget.menu!.price.toStringAsFixed(0);
      _stockController.text = widget.menu!.stock.toString();
      _descController.text = widget.menu!.description;
      _selectedCategory = widget.menu!.category;
      _imageBase64 = widget.menu!.imageBase64;
      _imageUrlController.text = widget.menu!.imageUrl;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
      maxHeight: 600,
      imageQuality: 70,
    );
    if (picked == null) return;
    final bytes = await File(picked.path).readAsBytes();
    final base64Str = 'data:image/jpeg;base64,${base64Encode(bytes)}';
    setState(() {
      _imageBase64 = base64Str;
      _imageUrlController.clear(); // hapus URL jika upload foto
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final menu = MenuModel(
      menuId: isEdit ? widget.menu!.menuId : '',
      name: _nameController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      category: _selectedCategory,
      stock: int.parse(_stockController.text.trim()),
      description: _descController.text.trim(),
      imageBase64: _imageBase64,
      imageUrl: _imageUrlController.text.trim(),
      imagePath: '',
    );

    try {
      if (isEdit) {
        await context.read<MenuProvider>().updateMenu(menu);
      } else {
        await context.read<MenuProvider>().addMenu(menu);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isEdit
              ? '${menu.name} berhasil diperbarui!'
              : '${menu.name} berhasil ditambahkan!'),
          backgroundColor: const Color(0xFF2D6A4F),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal menyimpan: $e'),
          backgroundColor: const Color(0xFFE63946),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildImagePreview() {
    if (_imageBase64.isNotEmpty) {
      return Stack(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Image.memory(
            Uri.parse(_imageBase64).data!.contentAsBytes(),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(children: [
                Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                SizedBox(width: 4),
                Text('Ganti Foto',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
        ),
      ]);
    }

    if (_imageUrlController.text.isNotEmpty) {
      return Stack(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: CachedNetworkImage(
            imageUrl: _imageUrlController.text,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            placeholder: (_, __) => const Center(
                child: CircularProgressIndicator(color: Color(0xFF2D6A4F))),
            errorWidget: (_, __, ___) => const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image_rounded,
                      color: Color(0xFF9E9E9E), size: 32),
                  Text('URL tidak valid',
                      style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(children: [
                Icon(Icons.photo_library_rounded,
                    color: Colors.white, size: 14),
                SizedBox(width: 4),
                Text('Upload Foto',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
        ),
      ]);
    }

    // Empty state
    return GestureDetector(
      onTap: _pickImage,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF2D6A4F).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.add_photo_alternate_rounded,
                size: 28, color: Color(0xFF2D6A4F)),
          ),
          const SizedBox(height: 10),
          const Text('Tap untuk upload foto dari galeri',
              style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 13)),
          const Text('atau isi URL gambar di bawah',
              style: TextStyle(color: Color(0xFFCCCCCC), fontSize: 11)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D6A4F),
        foregroundColor: Colors.white,
        title: Text(isEdit ? 'Edit Menu' : 'Tambah Menu',
            style: const TextStyle(fontWeight: FontWeight.w800)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Preview gambar
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                      color: const Color(0xFF2D6A4F).withOpacity(0.3),
                      width: 1.5),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: _buildImagePreview(),
              ),
              const SizedBox(height: 10),

              // Field URL gambar
              _buildField(
                controller: _imageUrlController,
                label: 'URL Gambar (opsional)',
                hint: 'https://images.unsplash.com/...',
                icon: Icons.link_rounded,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 4),
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text(
                  '* Upload foto dari galeri ATAU isi URL gambar',
                  style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)),
                ),
              ),
              const SizedBox(height: 14),

              _buildField(
                controller: _nameController,
                label: 'Nama Menu',
                hint: 'Contoh: Matcha Latte',
                icon: Icons.restaurant_menu_rounded,
                validator: (v) => v!.isEmpty ? 'Nama menu wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              _buildField(
                controller: _priceController,
                label: 'Harga (Rp)',
                hint: 'Contoh: 13000',
                icon: Icons.payments_rounded,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v!.isEmpty) return 'Harga wajib diisi';
                  if (double.tryParse(v) == null) return 'Harga tidak valid';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Kategori
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE8EDE9)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.category_rounded,
                        color: Color(0xFF2D6A4F), size: 20),
                    labelText: 'Kategori',
                    contentPadding: EdgeInsets.zero,
                  ),
                  items: _categories
                      .map((c) => DropdownMenuItem(
                            value: c['value'],
                            child: Text(c['label']!),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v!),
                ),
              ),
              const SizedBox(height: 12),

              _buildField(
                controller: _stockController,
                label: 'Stok',
                hint: 'Contoh: 20',
                icon: Icons.inventory_2_rounded,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v!.isEmpty) return 'Stok wajib diisi';
                  if (int.tryParse(v) == null) return 'Stok tidak valid';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Deskripsi
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE8EDE9)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: TextFormField(
                  controller: _descController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi',
                    hintText: 'Deskripsikan menu ini...',
                    prefixIcon: Icon(Icons.description_rounded,
                        color: Color(0xFF2D6A4F), size: 20),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 0, vertical: 14),
                  ),
                  validator: (v) => v!.isEmpty ? 'Deskripsi wajib diisi' : null,
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D6A4F),
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
                      : Text(isEdit ? 'Simpan Perubahan' : 'Tambah Menu',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8EDE9)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF2D6A4F), size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 0, vertical: 14),
        ),
        validator: validator,
      ),
    );
  }
}
