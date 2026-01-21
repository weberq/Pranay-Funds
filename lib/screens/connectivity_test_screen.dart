import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pranayfunds/configs/app_config.dart';

class ConnectivityTestScreen extends StatefulWidget {
  const ConnectivityTestScreen({super.key});

  @override
  State<ConnectivityTestScreen> createState() => _ConnectivityTestScreenState();
}

class _ConnectivityTestScreenState extends State<ConnectivityTestScreen> {
  String _status = 'Tap "Run Test" start diagnostics.';
  bool _isLoading = false;

  Future<void> _runTest() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing...';
    });

    final sb = StringBuffer();

    // 1. Test Internet (Google)
    sb.writeln('1. Checking Internet (google.com)...');
    try {
      final res = await http
          .get(Uri.parse('https://google.com'))
          .timeout(const Duration(seconds: 5));
      sb.writeln('✅ Success (${res.statusCode})');
    } catch (e) {
      sb.writeln('❌ Failed: $e');
    }

    sb.writeln('\n--------------------------------\n');

    // 2. Test Local Server
    sb.writeln('2. Checking Server (${AppConfig.baseUrl})...');
    try {
      // Trying to hit a simple file or the root
      final url = Uri.parse('${AppConfig.baseUrl}/customers/update.php');
      sb.writeln('Target: $url');
      final res = await http.get(url).timeout(const Duration(seconds: 5));
      sb.writeln('✅ Connected! Status: ${res.statusCode}');
      sb.writeln(
          'Body Preview: ${res.body.substring(0, res.body.length > 50 ? 50 : res.body.length)}...');
    } catch (e) {
      sb.writeln('❌ Error: $e');
      sb.writeln('\nSUGGESTIONS:');
      if (e.toString().contains('SocketException')) {
        sb.writeln(
            '- Check if IP ${AppConfig.baseUrl.split('/')[2]} is correct.');
        sb.writeln('- DISABLE Windows Firewall.');
        sb.writeln('- Ensure Phone & PC are on SAME WiFi.');
      } else if (e.toString().contains('Timeout')) {
        sb.writeln('- Firewall is likely BLOCKING the connection.');
        sb.writeln('- DISABLE Windows Firewall.');
      }
    }

    setState(() {
      _status = sb.toString();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connection Diagnostics')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                onPressed: _isLoading ? null : _runTest,
                icon: _isLoading
                    ? const SizedBox.shrink()
                    : const Icon(Icons.network_check),
                label: Text(_isLoading ? 'Testing...' : 'Run Diagnostics'),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _status,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      color: Colors.greenAccent,
                      fontSize: 14,
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
