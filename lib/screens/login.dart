import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pranayfunds/configs/app_config.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _mpinController = TextEditingController();

  bool _isMpinVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _mpinController.dispose();
    super.dispose();
  }

  /// Handles the full user login flow.
  Future<void> _login() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Step 1: Find the user by username
      final String username = _usernameController.text;
      final findUserUrl =
          Uri.parse('${AppConfig.baseUrl}/user_accounts/list?query=$username');

      _logRequest('Finding User', 'GET', findUserUrl);
      final findUserResponse =
          await http.get(findUserUrl, headers: {'X-API-KEY': AppConfig.apiKey});
      _logResponse('Finding User', findUserResponse);

      final findUserBody = jsonDecode(findUserResponse.body);
      if (findUserResponse.statusCode != 200 ||
          findUserBody['status'] != 'success' ||
          (findUserBody['data'] as List).isEmpty) {
        _showError('User not found. Please check your username.');
        return;
      }

      final userData = findUserBody['data'][0];
      final int userId = userData['user_id'];

      // Step 2: Create a session to log the user in
      final sessionUrl = Uri.parse('${AppConfig.baseUrl}/user_sessions/update');
      final sessionRequestBody = {
        "user_id": userId,
        "device_id": 42,
        "access_token": "jwt_access_placeholder",
        "refresh_token": "jwt_refresh_placeholder",
        "expires_at":
            DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
      };

      _logRequest('Creating Session', 'POST', sessionUrl,
          body: sessionRequestBody);
      final sessionResponse = await http.post(
        sessionUrl,
        headers: {
          'Content-Type': 'application/json',
          'X-API-KEY': AppConfig.apiKey
        },
        body: jsonEncode(sessionRequestBody),
      );
      _logResponse('Creating Session', sessionResponse);

      // --- 👇 ROBUST ERROR HANDLING IS HERE ---
      // Check if the response body is a valid JSON before decoding
      if (sessionResponse.body.trim().startsWith('{')) {
        final sessionResponseBody = jsonDecode(sessionResponse.body);
        if (sessionResponse.statusCode == 200 &&
            sessionResponseBody['status'] == 'success') {
          await _logAuthEvent(userId, 42);
          if (mounted) Navigator.popAndPushNamed(context, '/home');
        } else {
          final message = sessionResponseBody['message'] ??
              'Login failed due to an unknown API error.';
          _showError(message);
        }
      } else {
        // This block will now execute because of the server bug
        _showError(
            'The server returned an invalid response. Please contact support.');
        if (kDebugMode) {
          print(
              "Server response is not a valid JSON. It's likely a server-side crash.");
        }
      }
    } catch (e) {
      _logException(e);
      _showError('An unexpected error occurred. Please try again later.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Logs a security event after a successful login.
  Future<void> _logAuthEvent(int userId, int deviceId) async {
    try {
      final eventUrl = Uri.parse('${AppConfig.baseUrl}/auth_events/update');
      final eventBody = {
        "user_id": userId,
        "device_id": deviceId,
        "event_type": "login_success",
        "ip_address": "0.0.0.0",
        "user_agent": "FlutterApp/1.0",
      };
      _logRequest('Logging Auth Event', 'POST', eventUrl, body: eventBody);
      await http.post(
        eventUrl,
        headers: {
          'Content-Type': 'application/json',
          'X-API-KEY': AppConfig.apiKey
        },
        body: jsonEncode(eventBody),
      );
    } catch (e) {
      _logException(e, stage: 'Failed to log auth event');
    }
  }

  /// Displays a standardized error message at the bottom of the screen.
  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Logs the details of an HTTP request for debugging.
  void _logRequest(String stage, String method, Uri url,
      {Map<String, dynamic>? body}) {
    if (kDebugMode) {
      print('--- 🚀 $stage Request ---');
      print('URL: $url');
      print('Method: $method');
      if (body != null) {
        print('Body: ${jsonEncode(body)}');
      }
      print('--------------------------');
    }
  }

  /// Logs the details of an HTTP response for debugging.
  void _logResponse(String stage, http.Response response) {
    if (kDebugMode) {
      print('--- 📬 $stage Response ---');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('--------------------------');
    }
  }

  /// Logs exceptions for debugging.
  void _logException(Object e, {String stage = 'An Exception Occurred'}) {
    if (kDebugMode) {
      print('--- 🚨 $stage ---');
      print(e.toString());
      print('-----------------------------');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                SvgPicture.asset(
                  'lib/images/logo.svg',
                  height: 120,
                  semanticsLabel: 'Pranay Funds Logo',
                ),
                const SizedBox(height: 24),
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
                  'Enter your credentials to access your account',
                  textAlign: TextAlign.center,
                  style:
                      GoogleFonts.poppins(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 48),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _usernameController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: 'Username or Mobile',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter your username or mobile'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _mpinController,
                        obscureText: !_isMpinVisible,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        decoration: InputDecoration(
                          labelText: 'MPIN',
                          prefixIcon: const Icon(Icons.lock_outline),
                          counterText: "",
                          suffixIcon: IconButton(
                            icon: Icon(_isMpinVisible
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined),
                            onPressed: () {
                              setState(() {
                                _isMpinVisible = !_isMpinVisible;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your MPIN';
                          }
                          if (value.length < 6) {
                            return 'MPIN must be 6 digits';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {/* TODO: Implement forgot MPIN flow */},
                    child: Text('Forgot MPIN?',
                        style: GoogleFonts.poppins(
                            color: const Color(0xFFE67E22))),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF39C12),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      textStyle: GoogleFonts.poppins(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white))
                        : const Text('Login'),
                  ),
                ),
                const SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account?",
                        style: GoogleFonts.poppins(color: Colors.black54)),
                    TextButton(
                      onPressed: () {/* TODO: Navigate to Sign Up screen */},
                      child: Text(
                        'Sign Up',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFE67E22)),
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
