import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart' show MediaType;
import '../model/productModel.dart';
import 'local_storage_service.dart';

class ProductService {
  static const baseUrl =
      'https://gift-bouqet-backend-749281711221.us-central1.run.app/api/produk';

  static Future<Map<String, String>> _getHeaders() async {
    final String? token = await LocalStorageService().getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, String>> _getMultipartHeaders() async {
    final String? token = await LocalStorageService().getAuthToken();
    return {
      if (token != null) 'Authorization': 'Bearer $token',
      // Don't set Content-Type for multipart, let http package handle it
    };
  }

  static Future<List<Product>> getAllProducts() async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(baseUrl), headers: headers);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> produkList = jsonResponse['data']['produk'];
      return produkList.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to load products: ${response.statusCode} ${response.body}',
      );
    }
  }

  static Future<Product> getProductById(int id) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/$id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return Product.fromJson(jsonResponse['data']['produk']);
    } else {
      throw Exception(
        'Failed to load product: ${response.statusCode} ${response.body}',
      );
    }
  }

  static Future<Product> createProduct(
    CreateProductRequest request, {
    File? imageFile,
  }) async {
    final token = await LocalStorageService().getAuthToken();
    if (token == null) {
      throw Exception('Authentication token not found.');
    }

    try {
      var requestHttp = http.MultipartRequest('POST', Uri.parse(baseUrl));

      // Set headers
      final headers = await _getMultipartHeaders();
      requestHttp.headers.addAll(headers);

      // Add text fields
      requestHttp.fields['nama'] = request.nama;
      requestHttp.fields['price'] = request.price.toString();
      requestHttp.fields['description'] = request.description;
      requestHttp.fields['category'] = request.category;

      // Add image file if exists
      if (imageFile != null) {
        // Get the mime type
        final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
        // Ensure only main type and subtype are used, remove any parameters like '; charset=utf-8'
        final cleanMimeType = mimeType.split(';')[0];
        final mimeTypeData = cleanMimeType.split('/');

        // Ensure mimeTypeData has at least two parts, otherwise default
        final String mainType =
            mimeTypeData.isNotEmpty ? mimeTypeData[0] : 'image';
        final String subType =
            mimeTypeData.length > 1
                ? mimeTypeData[1]
                : 'jpeg'; // Default to jpeg if subtype is missing

        print('Detected MIME Type: $mimeType');
        print('Clean MIME Type: $cleanMimeType');
        print('Main Type for MediaType: $mainType');
        print('Sub Type for MediaType: $subType');

        requestHttp.files.add(
          await http.MultipartFile.fromPath(
            'image', // This should match your backend expectation
            imageFile.path,
            contentType: MediaType(mainType, subType),
          ),
        );
      }

      print('Sending request to: ${requestHttp.url}');
      print('Fields: ${requestHttp.fields}');
      print('Files: ${requestHttp.files.map((f) => f.field).toList()}');

      var streamedResponse = await requestHttp.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        return Product.fromJson(jsonResponse['data']['produk']);
      } else {
        throw Exception(
          'Failed to create product: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      print('Error in createProduct: $e');
      rethrow;
    }
  }

  static Future<Product> updateProduct(
    int id,
    CreateProductRequest request, {
    File? imageFile,
  }) async {
    final token = await LocalStorageService().getAuthToken();
    if (token == null) {
      throw Exception('Authentication token not found.');
    }

    try {
      var requestHttp = http.MultipartRequest('PUT', Uri.parse('$baseUrl/$id'));

      // Set headers
      final headers = await _getMultipartHeaders();
      requestHttp.headers.addAll(headers);

      // Add text fields
      requestHttp.fields['nama'] = request.nama;
      requestHttp.fields['price'] = request.price.toString();
      requestHttp.fields['description'] = request.description;
      requestHttp.fields['category'] = request.category;

      // Add image file if exists
      if (imageFile != null) {
        // Get the mime type
        final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
        // Ensure only main type and subtype are used, remove any parameters like '; charset=utf-8'
        final cleanMimeType = mimeType.split(';')[0];
        final mimeTypeData = cleanMimeType.split('/');

        // Ensure mimeTypeData has at least two parts, otherwise default
        final String mainType =
            mimeTypeData.isNotEmpty ? mimeTypeData[0] : 'image';
        final String subType =
            mimeTypeData.length > 1
                ? mimeTypeData[1]
                : 'jpeg'; // Default to jpeg if subtype is missing

        requestHttp.files.add(
          await http.MultipartFile.fromPath(
            'image', // This should match your backend expectation
            imageFile.path,
            contentType: MediaType(mainType, subType),
          ),
        );
      }

      print('Updating product with ID: $id');
      print('Fields: ${requestHttp.fields}');
      print('Files: ${requestHttp.files.map((f) => f.field).toList()}');

      var streamedResponse = await requestHttp.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return Product.fromJson(jsonResponse['data']['produk']);
      } else {
        throw Exception(
          'Failed to update product: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      print('Error in updateProduct: $e');
      rethrow;
    }
  }

  static Future<void> deleteProduct(int id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to delete product: ${response.statusCode} ${response.body}',
      );
    }
  }

  static Future<bool> toggleAddToCart(int produkID) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/$produkID/addcart'),
      headers: headers,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['data']['isAddcart'] ?? false;
    } else {
      throw Exception(
        'Failed to toggle add to cart: ${response.statusCode} ${response.body}',
      );
    }
  }

  static Future<List<String>> getAllCategories() async {
    try {
      final products = await getAllProducts();
      final Set<String> categories = {};
      for (var product in products) {
        categories.add(product.category);
      }
      return categories.toList();
    } catch (e) {
      print('Error getting categories: $e');
      return [];
    }
  }
}
