import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
import 'package:pranayfunds/configs/app_config.dart';
import 'package:pranayfunds/models/user_model.dart';
import 'package:pranayfunds/services/storage_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final StorageService _storageService = StorageService();
  Map<String, String>? _lastUser;
  bool _isLoadingLastUser = true;

  @override
  void initState() {
    super.initState();
    _loadLastUser();
  }

  Future<void> _loadLastUser() async {
    try {
      final user = await _storageService.getLastUser();
      setState(() {
        _lastUser = user;
        _isLoadingLastUser = false;
      });
    } on PlatformException catch (e) {
      // This catch block handles the specific error you encountered.
      // It can happen on hot restarts. We'll treat it as no user being saved.
      if (kDebugMode) {
        print("Failed to load last user from storage (PlatformException): $e");
        print(
            "This is often safe to ignore on hot restart. Proceeding without a saved user.");
      }
      setState(() {
        _lastUser = null;
        _isLoadingLastUser = false;
      });
    } catch (e) {
      // Catch any other unexpected errors
      if (kDebugMode) {
        print("An unexpected error occurred while loading last user: $e");
      }
      setState(() {
        _lastUser = null;
        _isLoadingLastUser = false;
      });
    }
  }

  void _onChangeUser() {
    _storageService.clearLastUser();
    setState(() {
      _lastUser = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isLoadingLastUser
            ? const Center(child: CircularProgressIndicator())
            : _lastUser != null
                ? WelcomeBackScreen(
                    customerName: _lastUser!['customerName']!,
                    username: _lastUser!['username']!,
                    onChangeUser: _onChangeUser,
                  )
                : FullLoginScreen(
                    onLoginSuccess: (user) {
                      _storageService.saveLastUser(
                          user.username, user.customerName);
                      Navigator.pushReplacementNamed(context, '/home',
                          arguments: user);
                    },
                  ),
      ),
    );
  }
}

// --- WELCOME BACK SCREEN ---
class WelcomeBackScreen extends StatefulWidget {
  final String customerName;
  final String username;
  final VoidCallback onChangeUser;

  const WelcomeBackScreen({
    super.key,
    required this.customerName,
    required this.username,
    required this.onChangeUser,
  });

  @override
  State<WelcomeBackScreen> createState() => _WelcomeBackScreenState();
}

class _WelcomeBackScreenState extends State<WelcomeBackScreen> {
  final _mpinController = TextEditingController();
  final LocalAuthentication _auth = LocalAuthentication();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Optionally trigger biometric auth on screen load
    // _authenticateWithBiometrics();
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: 'Please authenticate to log in',
        options: const AuthenticationOptions(biometricOnly: true),
      );
      if (didAuthenticate) {
        _login(isBiometric: true);
      }
    } on PlatformException catch (e) {
      // Handle error (e.g., user has no biometrics set up)
      print(e);
    }
  }

  Future<void> _login({bool isBiometric = false}) async {
    if (!isBiometric && _mpinController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit MPIN')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // --- This is a simplified login flow for the "Welcome Back" screen ---
    // In a real app, you might have a different endpoint that accepts a session token or biometric proof.
    // For now, we'll re-use the full login flow but with the known username.
    try {
      final findUserUrl = Uri.parse(
          '${AppConfig.baseUrl}/user_accounts/list?query=${widget.username}');
      final findUserResponse =
          await http.get(findUserUrl, headers: {'X-API-KEY': AppConfig.apiKey});
      final findUserBody = jsonDecode(findUserResponse.body);

      if (findUserResponse.statusCode == 200 &&
          findUserBody['status'] == 'success' &&
          (findUserBody['data'] as List).isNotEmpty) {
        final user = UserModel.fromJson(findUserBody['data'][0]);
        // Here you would typically validate the MPIN against a server endpoint
        // For now, we assume it's correct and navigate home.
        Navigator.pushReplacementNamed(context, '/home', arguments: user);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Login failed.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('An error occurred: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              child: Text(
                widget.customerName.isNotEmpty ? widget.customerName[0] : 'U',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Welcome back, ${widget.customerName.split(' ')[0]}!',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.username,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _mpinController,
              maxLength: 6,
              obscureText: true,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 12),
              decoration: InputDecoration(
                labelText: 'Enter MPIN',
                counterText: '',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _login(),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Login'),
              ),
            ),
            const SizedBox(height: 16),
            IconButton(
              onPressed: _authenticateWithBiometrics,
              icon: Icon(Icons.fingerprint,
                  size: 48, color: Theme.of(context).colorScheme.primary),
              tooltip: 'Login with Biometrics',
            ),
            const Spacer(),
            TextButton(
              onPressed: widget.onChangeUser,
              child: const Text('Not you? Change user'),
            ),
          ],
        ),
      ),
    );
  }
}

// --- FULL LOGIN SCREEN (for first time or changed user) ---
class FullLoginScreen extends StatefulWidget {
  final Function(UserModel) onLoginSuccess;
  const FullLoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<FullLoginScreen> createState() => _FullLoginScreenState();
}

class _FullLoginScreenState extends State<FullLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _mpinController = TextEditingController();
  bool _isMpinVisible = false;
  bool _isLoading = false;

  Future<void> _login() async {
    if (_isLoading || !_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final findUserUrl = Uri.parse(
          '${AppConfig.baseUrl}/user_accounts/list?query=${_usernameController.text}');
      final findUserResponse =
          await http.get(findUserUrl, headers: {'X-API-KEY': AppConfig.apiKey});

      if (!mounted) return;
      final findUserBody = jsonDecode(findUserResponse.body);

      if (findUserResponse.statusCode == 200 &&
          findUserBody['status'] == 'success' &&
          (findUserBody['data'] as List).isNotEmpty) {
        final user = UserModel.fromJson(findUserBody['data'][0]);
        widget.onLoginSuccess(user);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('User not found.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('An error occurred: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // This UI is mostly the same as your previous login screen
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SvgPicture.asset('lib/images/logo.svg', height: 120),
              const SizedBox(height: 24),
              Text('Sign In',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Enter your credentials to continue',
                  textAlign: TextAlign.center,
                  style:
                      GoogleFonts.poppins(fontSize: 16, color: Colors.black54)),
              const SizedBox(height: 48),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                          labelText: 'Username or Mobile',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12))),
                      validator: (v) =>
                          v!.isEmpty ? 'Please enter username' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _mpinController,
                      obscureText: !_isMpinVisible,
                      maxLength: 6,
                      decoration: InputDecoration(
                        labelText: 'MPIN',
                        prefixIcon: const Icon(Icons.lock_outline),
                        counterText: '',
                        suffixIcon: IconButton(
                          icon: Icon(_isMpinVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined),
                          onPressed: () =>
                              setState(() => _isMpinVisible = !_isMpinVisible),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) =>
                          v!.length < 6 ? 'MPIN must be 6 digits' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
