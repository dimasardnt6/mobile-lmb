import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lmb_online/services/auth/auth_controller.dart';
import 'package:lmb_online/views/pengemudi/dashboard_pengemudi.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController authController = AuthController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool obscureText = true;
  bool isLoading = false;

  void _togglePasswordVisibility() {
    setState(() {
      obscureText = !obscureText;
    });
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    String username = usernameController.text;
    String password = passwordController.text;

    try {
      var response = await authController.login(username, password);
      print(response);

      setState(() {
        isLoading = false;
      });

      if (response.code == 200 && response.status == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardPengemudi()),
        );
      } else {
        String errorMessage = response.message;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$errorMessage"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      // Jika terjadi error pada saat koneksi atau parsing response
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Terjadi kesalahan. Periksa koneksi internet Anda."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: SafeArea(
                child: Column(
                  children: [
                    Container(
                      color: const Color.fromARGB(255, 229, 240, 255),
                      child: SvgPicture.asset(
                        'assets/images/ic_login_top.svg',
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Image.asset(
                      'assets/images/ic_logo_damri_light.png',
                      width: 130,
                    ),

                    // Form Login
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 30,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Input NIK
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'NIK',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: usernameController,
                              validator:
                                  (value) =>
                                      value!.isEmpty
                                          ? "NIK tidak boleh kosong"
                                          : null,
                              decoration: const InputDecoration(
                                hintText: 'Masukkan NIK',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                ),
                                prefixIcon: Icon(Icons.credit_card),
                              ),
                            ),

                            const SizedBox(height: 15),

                            // Input Password
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Kata Sandi',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: passwordController,
                              obscureText: obscureText,
                              validator:
                                  (value) =>
                                      value!.isEmpty
                                          ? "Kata Sandi tidak boleh kosong"
                                          : null,
                              decoration: InputDecoration(
                                hintText: 'Masukkan Kata Sandi',
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                ),
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  onPressed: _togglePasswordVisibility,
                                  icon: Icon(
                                    obscureText
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 30),
                            // Button Login
                            ElevatedButton(
                              onPressed: isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1A447F),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              child:
                                  isLoading
                                      ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                      : const Text(
                                        'Login',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: double.infinity,
                        height: 230,
                        color: const Color(0xFFE5F0FF),
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            SvgPicture.asset(
                              'assets/images/ic_login_bottom_2.svg',
                              width: MediaQuery.of(context).size.width,
                              fit: BoxFit.cover,
                            ),
                            Opacity(
                              opacity: 0.8,
                              child: SvgPicture.asset(
                                'assets/images/ic_login_bottom_1.svg',
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
