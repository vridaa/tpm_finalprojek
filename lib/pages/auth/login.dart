import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:gift_bouqet/pages/auth/register.dart';

import '../../common/custom_form_button.dart';
import '../../common/custom_input_field.dart';
import '../../common/page_header.dart';
import '../../common/page_heading.dart';
import '../../model/userModel.dart';
import '../../service/local_storage_service.dart';
import '../../service/userService.dart';
import '../admin/dashboard_admin.dart';
import '../user/homepage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _loginFormKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final UserService _userService = UserService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_loginFormKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final authResponse = await _userService.login(
          LoginRequest(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
        );

        // Pastikan semua data yang diperlukan ada
        if (authResponse.data?.token == null ||
            authResponse.data!.token!.isEmpty) {
          throw Exception('Invalid token received');
        }

        if (authResponse.data?.user?.id == null) {
          throw Exception('User data incomplete');
        }

        // Simpan data
        await LocalStorageService().saveAuthToken(authResponse.data!.token!);
        await LocalStorageService().saveUserData(authResponse.data!.user!);

        debugPrint('Logged in user data: ${authResponse.data!.user!.toJson()}');

        if (!mounted) return;

        // Navigasi
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    authResponse.data!.user!.role
                        ? const AdminDashboardPage()
                        : const HomePage(),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${e.toString()}')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xffFFFFFF),
      body: SafeArea(
        child: Column(
          children: [
            const PageHeader(),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xffe9f3e3),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _loginFormKey,
                    child: Column(
                      children: [
                        const PageHeading(title: 'Log-in'),
                        CustomInputField(
                          controller: _emailController,
                          labelText: 'Email',
                          hintText: 'Your email id',
                          validator: (textValue) {
                            if (textValue == null || textValue.isEmpty) {
                              return 'Email wajib diisi';
                            }
                            if (!EmailValidator.validate(textValue)) {
                              return 'Format email tidak valid';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomInputField(
                          controller: _passwordController,
                          labelText: 'Password',
                          hintText: 'Your password',
                          obscureText: true,
                          suffixIcon: true,
                          validator: (textValue) {
                            if (textValue == null || textValue.isEmpty) {
                              return 'Password wajib diisi';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        CustomFormButton(
                          innerText: _isLoading ? 'Logging in...' : 'Login',
                          onPressed: _isLoading ? null : _handleLogin,
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: size.width * 0.8,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: const Text(
                                  'Don\'t have an account? ',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black38,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap:
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => const SignupPage(),
                                      ),
                                    ),
                                child: const Text(
                                  'Sign-up',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
