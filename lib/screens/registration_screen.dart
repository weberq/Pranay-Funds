import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pranayfunds/configs/app_config.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _mpinController = TextEditingController();
  final _referralController = TextEditingController();
  final _dobController = TextEditingController();

  bool _isLoading = false;
  bool _isMpinVisible = false;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final mobileArgs = ModalRoute.of(context)?.settings.arguments as String?;
      if (mobileArgs != null) {
        _mobileController.text = mobileArgs;
      }
      _isInitialized = true;
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('${AppConfig.baseUrl}/customers/update');
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'X-API-KEY': AppConfig.apiKey,
            },
            body: jsonEncode({
              // -- Required by UI --
              'first_name': _firstNameController.text.trim(),
              'last_name': _lastNameController.text.trim(),
              'email': _emailController.text.trim(),
              'mobile_number': _mobileController.text.trim(),
              'requested_pin': _mpinController.text.trim(),
              'referral_code': _referralController.text.trim(),
              'status': 'pending',

              // -- Defaults for other schema fields (to prevent missing index errors) --
              'middle_name': null,
              'date_of_birth': _dobController.text.trim().isEmpty
                  ? null
                  : _dobController.text.trim(),
              'gender': null,
              'nationality': 'Indian',
              'alt_phone': null,
              'address_line1': null,
              'address_line2': null,
              'city': null,
              'state': null,
              'country': 'India',
              'pin_code': null,
              'id_type': null,
              'id_number': null,
              'kyc_status': 'pending',
              'risk_rating': 'low',
              'customer_segment': 'retail',
              'branch_id': '1', // Default branch
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print('Registration Response Status: ${response.statusCode}');
        print('Registration Response Body: ${response.body}');
      }

      dynamic body;
      try {
        body = jsonDecode(response.body);
      } catch (e) {
        throw Exception('Invalid server response: ${response.body}');
      }

      if (response.statusCode == 200 && body['status'] == 'success') {
        if (!mounted) return;
        _showSuccessDialog(body['message']);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(body['message'] ?? 'Registration failed')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog(String message) {
    // Navigate directly to Pending Screen on success
    Navigator.pushNamedAndRemoveUntil(
        context, '/pending_approval', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Account Registration')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Join Pranay Funds',
                  style: GoogleFonts.poppins(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Fill in your details to get started',
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _firstNameController,
                        decoration: _inputDecoration(
                            'First Name', Icons.person_outline),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _lastNameController,
                        decoration:
                            _inputDecoration('Last Name', Icons.person_outline),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dobController,
                  readOnly: true,
                  decoration:
                      _inputDecoration('Date of Birth', Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2000),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      _dobController.text =
                          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                    }
                  },
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration('Email', Icons.email_outlined),
                  validator: (v) => v!.contains('@') ? null : 'Invalid email',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _mobileController,
                  readOnly: true, // Locked as it was verified in Step 1
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  decoration:
                      _inputDecoration('Mobile Number', Icons.phone_android),
                  validator: (v) =>
                      v!.length == 10 ? null : 'Invalid mobile number',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _mpinController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  obscureText: !_isMpinVisible,
                  decoration: _inputDecoration(
                          'Create 6-digit MPIN', Icons.lock_outline)
                      .copyWith(
                    counterText: '',
                    suffixIcon: IconButton(
                      icon: Icon(_isMpinVisible
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () =>
                          setState(() => _isMpinVisible = !_isMpinVisible),
                    ),
                  ),
                  validator: (v) =>
                      v!.length == 6 ? null : 'MPIN must be 6 digits',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _referralController,
                  decoration: _inputDecoration(
                      'Referral Code (Optional)', Icons.card_giftcard),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 50,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _register,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Submit for Approval'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
