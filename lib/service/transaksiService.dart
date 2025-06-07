import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/transaksiModel.dart';
import 'local_storage_service.dart';
import 'package:flutter/foundation.dart';

class TransaksiService {
  final String baseUrl =
      'https://gift-bouqet-backend-749281711221.us-central1.run.app/api/api/transaksi';

  Future<Map<String, String>> _getHeaders() async {
    final String? token = await LocalStorageService().getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Transaksi> createTransaksi(CreateTransaksiRequest request) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: await _getHeaders(),
        body: json.encode(request.toJson()),
      );

      debugPrint('Request URL: $baseUrl');
      debugPrint('Request Body: ${json.encode(request.toJson())}');
      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return Transaksi.fromJson(responseData['data']);
      } else {
        throw Exception(
          'Failed to create transaction: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Error creating transaction: $e');
      throw Exception('Error creating transaction: $e');
    }
  }
}
