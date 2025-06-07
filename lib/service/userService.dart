import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/userModel.dart';
import 'package:http_parser/http_parser.dart'; // untuk MIME type
import 'package:mime/mime.dart'; // untuk deteksi MIME type
class UserService {
  static const String _baseUrl = 'https://gift-bouqet-backend-749281711221.us-central1.run.app/api/auth';

  // Helper ambil headers dengan token
  static Future<Map<String, String>> _getHeaders({bool jsonContentType = true}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final headers = <String, String>{};

    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    if (jsonContentType) {
      headers['Content-Type'] = 'application/json';
    }

    return headers;
  }

  // ✅ REGISTER
  Future<UserModel> register(RegisterRequest request) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(request.toJson()),
    );

    final jsonResponse = json.decode(response.body);

    if (response.statusCode == 201) {
      return UserModel.fromJson(jsonResponse);
    } else {
      throw Exception(jsonResponse['message'] ?? 'Register gagal');
    }
  }

  // ✅ LOGIN
  Future<UserModel> login(LoginRequest request) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(request.toJson()),
    );

    final jsonResponse = json.decode(response.body);

    if (response.statusCode == 200) {
      // simpan token ke SharedPreferences
      final token = jsonResponse['data']?['token'];
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
      }
      return UserModel.fromJson(jsonResponse);
    } else {
      throw Exception(jsonResponse['message'] ?? 'Login gagal');
    }
  }

  // ✅ GET PROFILE
  static Future<UserModel> getProfile() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/profile'),
      headers: headers,
    );

    final jsonResponse = json.decode(response.body);

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonResponse);
    } else {
      throw Exception(jsonResponse['message'] ?? 'Gagal mengambil profil');
    }
  }

  // ✅ UPDATE PROFILE TANPA GAMBAR
  static Future<UserModel> updateProfile(User user) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$_baseUrl/profile'),
      headers: headers,
      body: json.encode(user.toJsonForUpdate()),
    );

    final jsonResponse = json.decode(response.body);

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonResponse);
    } else {
      throw Exception(jsonResponse['message'] ?? 'Gagal update profil');
    }
  }

  // ✅ UPDATE PROFILE DENGAN GAMBAR
  static Future<UserModel> updateProfileWithImage(User user, File imageFile) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final uri = Uri.parse('$_baseUrl/profile');

    final request = http.MultipartRequest('PUT', uri)
      ..headers['Authorization'] = 'Bearer $token';

    // Tambahkan field teks
    user.toJsonForUpdate().forEach((key, value) {
      if (value != null) request.fields[key] = value.toString();
    });

    // Tambahkan file gambar
    if (imageFile.existsSync()) {
      final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
      final mimeParts = mimeType.split('/');
      request.files.add(await http.MultipartFile.fromPath(
        'profilePicture', // field name dari backend
        imageFile.path,
        contentType: MediaType(mimeParts[0], mimeParts[1]),
      ));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final jsonResponse = json.decode(response.body);

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonResponse);
    } else {
      throw Exception(jsonResponse['message'] ?? 'Gagal update profil dengan gambar');
    }
  }

  // ✅ DELETE USER
  static Future<UserModel> deleteUser() async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse("$_baseUrl/profile"),
      headers: headers,
    );

    final jsonResponse = json.decode(response.body);

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonResponse);
    } else {
      throw Exception(jsonResponse['message'] ?? 'Gagal menghapus akun');
    }
  }
}
