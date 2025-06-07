import 'package:flutter/material.dart';
import 'package:gift_bouqet/model/productModel.dart';
import 'package:gift_bouqet/pages/user/purchase_form_page.dart';
import 'package:gift_bouqet/service/productService.dart';
// import 'package:gift_bouqet/model/cartItemModel.dart'; // Removed
// import 'package:gift_bouqet/service/shoppingCartService.dart'; // Removed
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:async';

class DashboardUser extends StatefulWidget {
  final String username;
  const DashboardUser({super.key, required this.username});

  @override
  State<DashboardUser> createState() => _DashboardUserState();
}

class _DashboardUserState extends State<DashboardUser> {
  // Services
  final ProductService _productService = ProductService();
  // final ShoppingCartService _shoppingCartService = ShoppingCartService(); // Removed

  // Product related states
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;
  String _errorMessage = '';

  // Search and Category Filter states
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  List<String> _categories = ['All'];

  // Currency Display variables
  String _displayCurrency = 'IDR'; // Default currency to display
  final Map<String, double> _currencyExchangeRates = {
    // Exchange rates from IDR as base currency
    'IDR': 1.0,
    'USD': 0.000064, // 1 IDR = 0.000064 USD
    'EUR': 0.000059, // 1 IDR = 0.000059 EUR
    'JPY': 0.0094, // 1 IDR = 0.0094 JPY
    // Add more currencies as needed
  };
  final List<String> _availableDisplayCurrencies = [
    'IDR', 'USD', 'EUR', 'JPY', // Example currencies
  ];

  // Time Zone Conversion variables
  String _toTimeZone = 'Europe/London'; // Default to a European timezone
  DateTime? _convertedDateTime; // Use DateTime for converted time
  DateTime _currentDeviceTime =
      DateTime.now(); // To display current device time

  // New: Timer for real-time clock update
  Timer? _timer;

  // List of common time zones (4 distinct regions)
  final List<String> _timeZones = [
    'Asia/Jakarta', // WIB
    'Europe/London',
    'America/New_York',
    'Asia/Tokyo',
  ];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _searchController.addListener(_onSearchChanged);
    _updateCurrentTimeAndConvert(); // Update current time and convert on init
    // Start a timer to update current time every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateCurrentTimeAndConvert();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _timer?.cancel(); // Cancel the timer to prevent memory leaks
    super.dispose();
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  String _formatPrice(double price) {
    final double rate = _currencyExchangeRates[_displayCurrency] ?? 1.0;
    final double convertedPrice = price * rate;
    final NumberFormat formatter = NumberFormat.currency(
      locale: 'en_US', // You can change locale based on currency
      symbol: _displayCurrency == 'IDR' ? 'Rp' : _displayCurrency,
      decimalDigits: 2,
    );
    return formatter.format(convertedPrice);
  }

  void _updateCurrentTimeAndConvert() {
    setState(() {
      _currentDeviceTime = DateTime.now();
    });
    _convertTime();
  }

  void _convertTime() {
    final now = DateTime.now(); // Get current device time

    try {
      final toLocation = tz.getLocation(_toTimeZone);

      // Directly convert local time to the target time zone
      final tz.TZDateTime convertedTime = tz.TZDateTime.from(now, toLocation);

      print('DEBUG: Current Device Time (now): $now');
      print('DEBUG: Target Time Zone (_toTimeZone): $_toTimeZone');
      print('DEBUG: Converted TZDateTime: $convertedTime');

      setState(() {
        _convertedDateTime = convertedTime;
      });
    } catch (e) {
      debugPrint('Error converting time: $e');
      setState(() {
        _convertedDateTime = null;
      });
    }
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final products = await ProductService.getAllProducts();
      setState(() {
        _products = products;
        _extractCategories(products);
        _applyFilters();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load products: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _extractCategories(List<Product> products) {
    Set<String> uniqueCategories = {};
    for (var product in products) {
      uniqueCategories.add(product.category);
    }
    setState(() {
      _categories = ['All', ...uniqueCategories.toList()..sort()];
      _selectedCategory = _categories.first;
    });
  }

  void _applyFilters() {
    List<Product> tempProducts = List.from(_products);

    if (_searchController.text.isNotEmpty) {
      tempProducts =
          tempProducts.where((product) {
            return product.nama.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            );
          }).toList();
    }

    if (_selectedCategory != null && _selectedCategory != 'All') {
      tempProducts =
          tempProducts.where((product) {
            return product.category == _selectedCategory;
          }).toList();
    }

    setState(() {
      _filteredProducts = tempProducts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(
          16.0,
        ), // Outer padding for the whole screen
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome Back!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          '${widget.username}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff233743),
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.sentiment_satisfied_alt,
                      size: 40,
                      color: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
              ),
            ),

            // Search and Filter Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Find Your Bouquets',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff233743),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Search Products',
                        hintText: 'Enter product name',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Filter by Category',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      items:
                          _categories.map((String category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCategory = newValue;
                          _applyFilters();
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _displayCurrency,
                      decoration: InputDecoration(
                        labelText: 'Display Prices In',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      items:
                          _availableDisplayCurrencies.map((String currency) {
                            return DropdownMenuItem<String>(
                              value: currency,
                              child: Text(currency),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _displayCurrency = newValue!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Time Converter Section - NEW
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Time Converter',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff233743),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Current Device Time: ${DateFormat('HH:mm:ss').format(_currentDeviceTime)}',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _toTimeZone,
                      decoration: InputDecoration(
                        labelText: 'Convert To Time Zone',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      items:
                          _timeZones.map((String zone) {
                            return DropdownMenuItem<String>(
                              value: zone,
                              child: Text(zone.replaceAll('/', '/')),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _toTimeZone = newValue;
                          });
                          _convertTime();
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    _convertedDateTime != null
                        ? Text(
                          'Converted Time: ${DateFormat('HH:mm:ss').format(_convertedDateTime!)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[700],
                          ),
                        )
                        : const Text(
                          'Converted Time: N/A',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                  ],
                ),
              ),
            ),

            const Text(
              'Available Bouquets',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xff233743),
              ),
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                ? Center(child: Text(_errorMessage))
                : GridView.builder(
                  shrinkWrap:
                      true, // Important for GridView inside SingleChildScrollView
                  physics:
                      const NeverScrollableScrollPhysics(), // GridView scrolls with parent
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: _filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = _filteredProducts[index];
                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(10),
                              ),
                              child:
                                  product.imageUrl != null &&
                                          product.imageUrl!.isNotEmpty
                                      ? Image.network(
                                        product.imageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Center(
                                                  child: Icon(
                                                    Icons.broken_image,
                                                  ),
                                                ),
                                      )
                                      : const Center(
                                        child: Icon(Icons.image_not_supported),
                                      ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.nama,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatPrice(
                                    product.price,
                                  ), // Use the new formatPrice function
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => PurchaseFormPage(
                                                    product: product,
                                                  ),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xff233743,
                                          ),
                                          foregroundColor: Colors.white,
                                          minimumSize: const Size(
                                            double.infinity,
                                            36,
                                          ),
                                        ),
                                        child: const Text('Buy'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
          ],
        ),
      ),
    );
  }
}
