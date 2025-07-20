import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // State variables
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed.
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- API Integration Placeholder ---
  // Replace this with your actual API call
  Future<void> _login() async {
    // 1. Validate the form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 2. Set loading state to true
    setState(() {
      _isLoading = true;
    });

    // 3. Simulate a network call
    // In a real app, you would make your HTTP request here.
    // E.g., using the http package:
    //
    // final response = await http.post(
    //   Uri.parse('https://apis-funds.xweber.in/auth'), // <-- Your real login endpoint
    //   headers: <String, String>{
    //     'Content-Type': 'application/json; charset=UTF-8',
    //     'X-API-KEY': 'YOUR_API_KEY_HERE',
    //   },
    //   body: jsonEncode(<String, String>{
    //     'email': _emailController.text,
    //     'password': _passwordController.text,
    //   }),
    // );
    await Future.delayed(const Duration(seconds: 2));

    // 4. Handle the response
    // if (response.statusCode == 200) {
    //   // On success, navigate to the home screen
    Navigator.popAndPushNamed(context, '/home');
    // } else {
    //   // On failure, show an error message
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Login failed. Please check your credentials.')),
    //   );
    // }

    // 5. Set loading state to false
    // Check if the widget is still in the tree before calling setState
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // --- UI Build Method ---
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      // Use a subtle gradient background for a premium feel
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo
                SvgPicture.asset(
                  'lib/images/logo.svg', // Use your new SVG logo
                  height: 120,
                  semanticsLabel: 'Pranay Funds Logo',
                ),
                const SizedBox(height: 24),

                // Welcome Header
                Text(
                  'Welcome Back!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1C1B1F),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to manage your funds',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 48),

                // Login Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Implement forgot password functionality
                    },
                    child: Text(
                      'Forgot Password?',
                      style:
                          GoogleFonts.poppins(color: const Color(0xFFE67E22)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Login Button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFFF39C12), // Color from your logo
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text('Login'),
                  ),
                ),
                const SizedBox(height: 48),

                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: GoogleFonts.poppins(color: Colors.black54),
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: Navigate to Sign Up screen
                      },
                      child: Text(
                        'Sign Up',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFE67E22),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
