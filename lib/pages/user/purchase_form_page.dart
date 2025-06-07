import 'package:flutter/material.dart';
import 'package:gift_bouqet/model/productModel.dart';
import 'package:gift_bouqet/service/transaksiService.dart';
import 'package:gift_bouqet/model/transaksiModel.dart';
import 'package:gift_bouqet/service/local_storage_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gift_bouqet/pages/user/shop_location_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PurchaseFormPage extends StatefulWidget {
  final Product product;

  const PurchaseFormPage({Key? key, required this.product}) : super(key: key);

  @override
  _PurchaseFormPageState createState() => _PurchaseFormPageState();
}

class _PurchaseFormPageState extends State<PurchaseFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController(text: '1');
  final _alamatController = TextEditingController();
  String _metodePembayaran = 'transfer_bank';
  bool _isLoading = false;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showSuccessNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'transaction_channel',
          'Transaction Notifications',
          channelDescription: 'Notifications for successful transactions',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: false,
        );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      0,
      'Transaksi Berhasil!',
      'Pembelian ${widget.product.nama} berhasil dilakukan.',
      platformChannelSpecifics,
      payload: 'transaction_success',
    );
  }

  Future<void> _saveNotification(String message) async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = prefs.getStringList('notifications') ?? [];
    final newNotification = '${DateTime.now().toIso8601String()}|$message';
    notifications.insert(0, newNotification); // Add to the beginning
    await prefs.setStringList('notifications', notifications);
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final totalHarga =
            widget.product.price * int.parse(_quantityController.text);
        final user = await LocalStorageService().getUserData();
        if (user == null || user.id == null) {
          throw Exception('User not logged in or user ID not found.');
        }

        final request = CreateTransaksiRequest(
          idProduk: widget.product.produkID!,
          jumlah: int.parse(_quantityController.text),
          totalHarga: totalHarga,
          metodePembayaran: _metodePembayaran,
          alamatPengiriman: _alamatController.text,
          idUser: user.id!,
        );

        await TransaksiService().createTransaksi(request);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaksi berhasil dibuat')),
        );
        _showSuccessNotification();
        _saveNotification(
          'Pembelian ${widget.product.nama} berhasil dilakukan.',
        );
        Navigator.pop(context, true);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalHarga =
        widget.product.price * int.parse(_quantityController.text);

    return Scaffold(
      appBar: AppBar(title: const Text('Buat Transaksi')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Masukkan jumlah';
                  if (int.tryParse(value) == null) return 'Jumlah tidak valid';
                  return null;
                },
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _alamatController,
                decoration: const InputDecoration(
                  labelText: 'Alamat Pengiriman',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan alamat pengiriman';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _metodePembayaran,
                decoration: const InputDecoration(
                  labelText: 'Metode Pembayaran',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'transfer_bank',
                    child: Text('Transfer Bank'),
                  ),
                  DropdownMenuItem(value: 'e_wallet', child: Text('E-Wallet')),
                  DropdownMenuItem(value: 'cod', child: Text('COD')),
                ],
                onChanged:
                    (value) => setState(() => _metodePembayaran = value!),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Pilih metode pembayaran';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Total Harga: Rp ${totalHarga.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Buat Transaksi'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ShopLocationPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Go to Store'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
