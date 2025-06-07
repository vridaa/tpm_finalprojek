import 'package:flutter/material.dart';
import 'package:gift_bouqet/service/productService.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/productModel.dart';
import '../auth/login.dart';
import 'product_form_page.dart'; // Import the new product form page

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  String? _username;
  List<Product> _products = [];
  bool _isLoading = true;
  String? _errorMessage;
  final String _defaultProductImage =
      'https://storage.googleapis.com/gift_bouqet/assets/produk/produk-default.jpg';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadProducts();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username');
    });
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final products = await ProductService.getAllProducts();
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    bool confirm =
        await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text(
                  "Konfirmasi Logout",
                  style: GoogleFonts.merriweather(),
                ),
                content: Text(
                  "Apakah Anda yakin ingin keluar?",
                  style: GoogleFonts.openSans(),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(
                      "Batal",
                      style: GoogleFonts.openSans(color: Colors.grey),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(
                      "Logout",
                      style: GoogleFonts.openSans(color: Colors.pink.shade100),
                    ),
                  ),
                ],
              ),
        ) ??
        false;

    if (confirm) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  void _navigateToAddProduct() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProductFormPage()),
    ).then((result) {
      if (result == true) {
        _loadProducts(); // Refresh products after adding/editing
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Dashboard", style: GoogleFonts.playfairDisplay()),
        backgroundColor: const Color(0xffFFFFFF),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddProduct,
        backgroundColor: Colors.pink.shade100,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/logo.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Selamat Datang, ${_username ?? 'Admin'}!",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff233743),
                ),
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_errorMessage != null)
                Center(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              else
                Expanded(
                  child:
                      _products.isEmpty
                          ? Center(
                            child: Text(
                              "Tidak ada produk",
                              style: GoogleFonts.openSans(fontSize: 18),
                            ),
                          )
                          : ListView.builder(
                            itemCount: _products.length,
                            itemBuilder: (context, index) {
                              final product = _products[index];
                              return _buildProductCard(context, product);
                            },
                          ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Product Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(product.imageUrl ?? _defaultProductImage),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.nama,
                    style: GoogleFonts.merriweather(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Rp ${product.price.toStringAsFixed(0)}", // Format price without decimals
                    style: GoogleFonts.openSans(
                      fontSize: 16,
                      color: Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.category,
                    style: GoogleFonts.openSans(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            // Action Buttons
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ProductFormPage(
                            product: product,
                          ), // Pass product for editing
                    ),
                  ).then((result) {
                    if (result == true) {
                      _loadProducts(); // Refresh products after editing
                    }
                  });
                } else if (value == 'delete') {
                  _confirmDeleteProduct(product.produkID!);
                }
              },
              itemBuilder:
                  (BuildContext context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteProduct(int productId) async {
    bool confirm =
        await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text("Hapus Produk", style: GoogleFonts.merriweather()),
                content: Text(
                  "Apakah Anda yakin ingin menghapus produk ini?",
                  style: GoogleFonts.openSans(),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text("Batal", style: GoogleFonts.openSans()),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(
                      "Hapus",
                      style: GoogleFonts.openSans(color: Colors.red),
                    ),
                  ),
                ],
              ),
        ) ??
        false;

    if (confirm) {
      try {
        await ProductService.deleteProduct(productId);
        _loadProducts();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Produk berhasil dihapus")));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menghapus produk: ${e.toString()}")),
        );
      }
    }
  }
}

// Placeholder for Add Product Page - You'll need to implement this
class AddProductPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tambah Produk")),
      body: Center(child: Text("Form untuk menambah produk baru")),
    );
  }
}
