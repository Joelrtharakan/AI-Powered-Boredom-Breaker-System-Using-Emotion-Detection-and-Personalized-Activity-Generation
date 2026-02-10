import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/api_client.dart';
import 'main_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    setState(() => _isLoading = true);

    // Basic Validation
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    try {
      // Create Dio instance (or use ApiClient, but we need custom login endpoint handling perhaps)
      // Assuming straightforward login endpoint: POST /auth/token
      // But based on App.jsx from previous context, the endpoint is likely /auth/token or similar.
      // Let's check backend if possible, or assume standard /auth/token form data or JSON.
      // I'll use a mocked "success" if username is 'test' for now OR try to hit the backend if I knew the endpoint.
      // Based on previous chats, it's FastAPI. Likely OAuth2PasswordRequestForm or similar.
      // Let's try to hit http://localhost:8000/auth/token with username/password.

      /* 
       * REAL IMPLEMENTATION:
       * final dio = ApiClient().client;
       * final response = await dio.post('/auth/token', data: {'username': _emailController.text, 'password': _passwordController.text});
       * // Store token...
       */

      // For now, to "fix" the issue of "random letters logging in", I will enforce a mock check or attempt a real call.
      // User asked to connect to DB/SQLite. That means Real Auth.

      final dio = ApiClient().client;
      // Backend expects JSON body
      final data = {
        'email': _emailController.text,
        'password': _passwordController.text,
      };

      final response = await dio.post('/auth/login', data: data);

      if (response.statusCode == 200) {
        // Success
        if (response.data['access_token'] != null) {
          ApiClient.token = response.data['access_token'];
        }

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainLayout()),
          );
        }
      } else {
        throw Exception("Invalid credentials");
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Login Failed: ${e.toString()}")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome Back",
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Sign in to continue your journey.",
                style: GoogleFonts.inter(fontSize: 16, color: Colors.white54),
              ),

              const SizedBox(height: 48),

              // Email Field
              _buildTextField("Email", Icons.email_outlined, _emailController),
              const SizedBox(height: 24),
              // Password Field
              _buildTextField(
                "Password",
                Icons.lock_outline,
                _passwordController,
                isPassword: true,
              ),

              const SizedBox(height: 40),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          "Login",
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: () {
                    // TODO: Navigate to Register
                  },
                  child: RichText(
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: GoogleFonts.inter(color: Colors.white54),
                      children: [
                        TextSpan(
                          text: "Sign Up",
                          style: GoogleFonts.inter(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    IconData icon,
    TextEditingController controller, {
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.white38),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
