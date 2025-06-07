import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // Import flutter_map
import 'package:latlong2/latlong.dart'; // Import LatLng
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher
import 'package:geolocator/geolocator.dart'; // Untuk cek izin lokasi

import '../../constants.dart'; // Import konstanta lokasi toko

class ShopLocationPage extends StatefulWidget {
  const ShopLocationPage({super.key});

  @override
  State<ShopLocationPage> createState() => _ShopLocationPageState();
}

class _ShopLocationPageState extends State<ShopLocationPage> {
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _locationError =
              'Izin lokasi ditolak. Tidak dapat menunjukkan lokasi Anda relative ke toko.';
        });
      } else if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationError =
              'Izin lokasi ditolak secara permanen. Mohon berikan izin dari pengaturan aplikasi.';
        });
      }
    }
  }

  Future<void> _launchMapsUrl(double lat, double lon) async {
    Position? currentPosition;
    try {
      currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      debugPrint('Error getting current location: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak dapat mendapatkan lokasi Anda saat ini.'),
        ),
      );
      // Continue without current location, launching map centered on shop
    }

    Uri googleMapsUrl;
    if (currentPosition != null) {
      googleMapsUrl = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&origin=${currentPosition.latitude},${currentPosition.longitude}&destination=$lat,$lon',
      );
    } else {
      // Fallback to searching for the shop if current location is not available
      googleMapsUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lon',
      );
    }

    final Uri appleMapsUrl = Uri.parse('https://maps.apple.com/?q=$lat,$lon');

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
    } else if (await canLaunchUrl(appleMapsUrl)) {
      await launchUrl(appleMapsUrl);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka aplikasi peta.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final LatLng shopLocation = LatLng(
      AppConstants.shopLatitude,
      AppConstants.shopLongitude,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lokasi Toko'),
        backgroundColor: const Color(0xff233743),
        foregroundColor: Colors.white,
      ),
      body:
          _locationError != null
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.location_off,
                        size: 50,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _locationError!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Geolocator.openAppSettings(),
                        child: const Text('Buka Pengaturan Aplikasi'),
                      ),
                    ],
                  ),
                ),
              )
              : Column(
                children: [
                  Expanded(
                    child: FlutterMap(
                      options: MapOptions(center: shopLocation, zoom: 15.0),
                      children: [
                        TileLayer(
                          // Lapisan peta dari OpenStreetMap
                          urlTemplate:
                              "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                          userAgentPackageName: 'com.example.gift_bouqet',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              width: 80.0,
                              height: 80.0,
                              point: shopLocation,
                              builder:
                                  (ctx) => const Icon(
                                    Icons.storefront,
                                    color: Colors.red,
                                    size: 40.0,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          '${AppConstants.shopName} berada di:',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Latitude: ${AppConstants.shopLatitude}, Longitude: ${AppConstants.shopLongitude}',
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed:
                              () => _launchMapsUrl(
                                shopLocation.latitude,
                                shopLocation.longitude,
                              ),
                          icon: const Icon(Icons.directions),
                          label: const Text('Dapatkan Petunjuk Arah'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff233743),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
