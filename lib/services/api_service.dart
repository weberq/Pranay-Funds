import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pranayfunds/configs/app_config.dart';
import 'package:pranayfunds/models/account_model.dart';
import 'package:pranayfunds/models/transaction_model.dart';

class ApiService {
  final String _baseUrl = AppConfig.baseUrl;
  final String _apiKey = AppConfig.apiKey;

  /// Helper to log requests and responses
  void _logApiCall(String endpoint, http.Response response) {
    if (kDebugMode) {
      print('--- 📞 API Call: $endpoint ---');
      print('URL: ${response.request?.url}');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('---------------------------------');
    }
  }

  Future<AccountModel> getAccountDetails(int customerId) async {
    final url = Uri.parse('$_baseUrl/accounts/list?customer_id=$customerId');
    final response = await http.get(url, headers: {'X-API-KEY': _apiKey});

    _logApiCall('/accounts/list', response);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body['status'] == 'success' && body['data'] != null) {
        // --- FIX IS HERE ---
        // API returns a list, even for a single customer. We take the first element.
        final List<dynamic> accountData = body['data'];
        if (accountData.isNotEmpty) {
          return AccountModel.fromJson(accountData.first);
        }
      }
    }
    throw Exception(
        'Failed to load account details for customer ID: $customerId');
  }

  Future<List<TransactionModel>> getTransactions(int accountId) async {
    final url = Uri.parse('$_baseUrl/transactions/list?account_id=$accountId');
    final response = await http.get(url, headers: {'X-API-KEY': _apiKey});

    _logApiCall('/transactions/list', response);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body['status'] == 'success' && body['data'] != null) {
        final List<dynamic> transactionData = body['data'];
        return transactionData
            .map((json) => TransactionModel.fromJson(json))
            .toList();
      }
    }
    throw Exception('Failed to load transactions for account ID: $accountId');
  }
}
