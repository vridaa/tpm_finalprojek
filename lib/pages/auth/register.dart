import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/services.dart';
import 'package:gift_bouqet/pages/user/homepage.dart';
import 'package:image_picker/image_picker.dart';

import '../../common/custom_form_button.dart';
import '../../common/custom_input_field.dart';
import '../../common/page_header.dart';
import '../../common/page_heading.dart';
import '../../model/userModel.dart';
import '../../service/local_storage_service.dart';
import '../../service/userService.dart';
import 'login.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  File? _profileImage;
  String? _imageError;
  final _signupFormKey = GlobalKey<FormState>();
  final UserService _userService = UserService();
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passConfirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passConfirmController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (_signupFormKey.currentState!.validate()) {
      if (_imageError != null) return;

      setState(() => _isLoading = true);

      try {
        final RegisterRequest registerRequest = RegisterRequest(
          username: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          passwordConfirmation: _passConfirmController.text,
        );

        debugPrint('Sending RegisterRequest: ${registerRequest.toJson()}');

        final authResponse = await _userService.register(registerRequest);

        // Save user data and token
        await LocalStorageService().saveAuthToken(authResponse.data!.token!);
        await LocalStorageService().saveUserData(authResponse.data!.user!);

        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Registrasi berhasil!')));

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
        );
      } catch (e) {
        if (!mounted) return;
        debugPrint('Registration error: ${e.toString()}');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFFFFF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _signupFormKey,
            child: Column(
              children: [
                const PageHeader(),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xffe9f3e3),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      const PageHeading(title: 'Sign-up'),
                      const SizedBox(height: 16),

                      CustomInputField(
                        controller: _nameController,
                        labelText: 'Nama Lengkap',
                        hintText: 'Masukkan nama lengkap',
                        isDense: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      CustomInputField(
                        controller: _emailController,
                        labelText: 'Email',
                        hintText: 'Masukkan email',
                        isDense: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email wajib diisi';
                          }
                          if (!EmailValidator.validate(value)) {
                            return 'Format email tidak valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      CustomInputField(
                        controller: _passwordController,
                        labelText: 'Password',
                        hintText: 'Buat password',
                        isDense: true,
                        obscureText: true,
                        suffixIcon: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password wajib diisi';
                          }
                          if (value.length < 8) {
                            return 'Password minimal 8 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      CustomInputField(
                        controller: _passConfirmController,
                        labelText: 'Konfirmasi Password',
                        hintText: 'Ulangi password',
                        isDense: true,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Konfirmasi password wajib diisi';
                          }
                          if (value != _passwordController.text) {
                            return 'Password tidak cocok';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 22),
                      CustomFormButton(
                        innerText: _isLoading ? 'Mendaftarkan...' : 'Daftar',
                        onPressed: _isLoading ? null : _handleSignup,
                      ),
                      const SizedBox(height: 18),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Sudah punya akun? ',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xff939393),
                            ),
                          ),
                          GestureDetector(
                            onTap:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginPage(),
                                  ),
                                ),
                            child: const Text(
                              'Masuk',
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xff748288),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
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
}
