import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pranayfunds/configs/app_config.dart';

class MobileOtpScreen extends StatefulWidget {
  const MobileOtpScreen({super.key});

  @override
  State<MobileOtpScreen> createState() => _MobileOtpScreenState();
}

class _MobileOtpScreenState extends State<MobileOtpScreen> {
  final _mobileController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isLoading = false;
  bool _otpSent = false;

  Future<void> _checkMobileAndSendOtp() async {
    final mobile = _mobileController.text.trim();
    if (mobile.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please enter a valid 10-digit mobile number')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Trying to avoid 302 redirects by removing .php extension if server has RewriteRules
      // If this fails, we might need to revert to .php or fix server config
      final url = Uri.parse('${AppConfig.baseUrl}/customers/check_mobile');

      final response = await http.post(
        url,
        headers: {'X-API-KEY': AppConfig.apiKey},
        body: {'mobile_number': mobile},
      ).timeout(const Duration(seconds: 10));

      if (kDebugMode) {
        print(
            'Check Mobile Response: ${response.statusCode} - ${response.body}');
      }

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['status'] == 'success') {
          if (body['exists'] == true) {
            final status = body['customer_status'];
            if (status == 'pending') {
              // LOGIC: Go directly to Pending Screen
              Navigator.pushNamedAndRemoveUntil(
                  context, '/pending_approval', (route) => false);
            } else {
              _handleExistingUser(status);
            }
          } else {
            // New User -> Send OTP (Dummy)
            setState(() {
              _otpSent = true;
            });
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('OTP Sent: 123456 (Dummy)')));
          }
        } else {
          // Fallback if API returns error status
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(body['message'] ?? 'Unknown API error')));
        }
      } else {
        // If 404/302/500
        throw Exception('Server failed with ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleExistingUser(String status) {
    if (status == 'active') {
      _showDialog('Account Exists',
          'This mobile number is already registered. Please login.');
    } else if (status == 'rejected') {
      _showDialog('Application Rejected',
          'Your previous application was rejected. Please contact support.');
    } else {
      _showDialog('Status: $status', 'Your account is currently $status.');
    }
  }

  void _verifyOtp() {
    final otp = _otpController.text.trim();
    // BYPASS: Allow ANY OTP for now
    if (otp.isNotEmpty) {
      Navigator.pushNamed(context, '/register',
          arguments: _mobileController.text.trim());
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please enter OTP')));
    }
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(ctx); // Close dialog
                if (title == 'Account Exists') {
                  Navigator.pop(context); // Go back to login
                }
              },
              child: const Text('OK'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verification')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Mobile Verification',
              style: GoogleFonts.poppins(
                  fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your mobile number to check status or register.',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
            const SizedBox(height: 32),

            // Mobile Field
            TextFormField(
              controller: _mobileController,
              decoration: const InputDecoration(
                labelText: 'Mobile Number',
                prefixIcon: Icon(Icons.phone_android),
                border: OutlineInputBorder(),
              ),
              readOnly: _otpSent,
              keyboardType: TextInputType.phone,
              maxLength: 10,
            ),

            // OTP Field (Visible only after sending)
            if (_otpSent) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _otpController,
                decoration: const InputDecoration(
                  labelText: 'Enter OTP',
                  prefixIcon: Icon(Icons.lock_clock),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),
            ],

            const SizedBox(height: 32),

            FilledButton(
              onPressed: _isLoading
                  ? null
                  : (_otpSent ? _verifyOtp : _checkMobileAndSendOtp),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text(_otpSent ? 'Verify & Continue' : 'Get OTP'),
            )
          ],
        ),
      ),
    );
  }
}
