import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pranayfunds/configs/app_config.dart';
import 'package:pranayfunds/models/account_model.dart';
import 'package:pranayfunds/models/reward_wallet_model.dart';
import 'package:pranayfunds/models/transaction_model.dart';

class ApiService {
  final String _baseUrl = AppConfig.baseUrl;
  final String _apiKey = AppConfig.apiKey;

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
        final List<dynamic> accountData = body['data'];
        if (accountData.isNotEmpty) {
          return AccountModel.fromJson(accountData.first);
        }
      }
    }
    throw Exception(
        'Failed to load account details for customer ID: $customerId');
  }

  Future<List<TransactionModel>> getTransactions(int accountId,
      {Map<String, String>? filters}) async {
    final queryParameters = {'account_id': accountId.toString()};
    if (filters != null) queryParameters.addAll(filters);
    final url = Uri.parse('$_baseUrl/transactions/list')
        .replace(queryParameters: queryParameters);
    final response = await http.get(url, headers: {'X-API-KEY': _apiKey});
    _logApiCall('/transactions/list', response);
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body['status'] == 'error' &&
          body['message'] == 'No transactions found') {
        return [];
      }
      if (body['status'] == 'success' && body['data'] != null) {
        return (body['data'] as List)
            .map((json) => TransactionModel.fromJson(json))
            .toList();
      }
      if (body['status'] == 'success') return [];
    }
    throw Exception('Failed to load transactions for account ID: $accountId');
  }

  Future<bool> submitManualTransaction({
    required String accountNumber,
    required double amount,
    required String reference,
  }) async {
    final url = Uri.parse('$_baseUrl/transactions/update');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-API-KEY': _apiKey,
      },
      body: jsonEncode({
        'account_number': accountNumber,
        'amount': amount,
        'transaction_type': 'credit',
        'reference': reference,
        'status': 'pending',
        'channel': 'mobile_app',
        'transaction_datetime': DateTime.now().toIso8601String(),
      }),
    );
    _logApiCall('/transactions/update (credit)', response);
    if (response.statusCode == 200) {
      if (response.body.trim().startsWith('{')) {
        final body = jsonDecode(response.body);
        // --- THE FIX IS HERE ---
        // A successful submission now returns a status of 'pending'.
        return body['status'] == 'pending' &&
            body.containsKey('transaction_id');
      }
    }
    return false;
  }

  Future<bool> submitWithdrawalRequest(
      {required String accountNumber, required double amount}) async {
    final url = Uri.parse('$_baseUrl/transactions/update');
    final response = await http.post(url,
        headers: {'Content-Type': 'application/json', 'X-API-KEY': _apiKey},
        body: jsonEncode({
          'account_number': accountNumber,
          'amount': amount,
          'transaction_type': 'debit',
          'status': 'pending',
          'channel': 'mobile_app',
          'transaction_datetime': DateTime.now().toIso8601String(),
        }));
    _logApiCall('/transactions/update (debit)', response);
    if (response.statusCode == 200) {
      if (response.body.trim().startsWith('{')) {
        final body = jsonDecode(response.body);
        // --- THE FIX IS HERE ---
        return body['status'] == 'pending' &&
            body.containsKey('transaction_id');
      }
    }
    return false;
  }

  Future<bool> deleteTransaction(int transactionId) async {
    final url = Uri.parse('$_baseUrl/transactions/delete?id=$transactionId');
    final response = await http.get(url, headers: {'X-API-KEY': _apiKey});
    _logApiCall('/transactions/delete', response);
    if (response.statusCode == 200) {
      if (response.body.trim().startsWith('{')) {
        return jsonDecode(response.body)['status'] == 'success';
      }
    }
    return false;
  }

  // --- REWARDS API ---

  Future<RewardWalletModel?> getRewardWallet(int customerId) async {
    final url = Uri.parse('$_baseUrl/rewards/list?custid=$customerId');
    final response = await http.get(url, headers: {'X-API-KEY': _apiKey});
    _logApiCall('/rewards/list', response);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body['status'] == 'success' && body['data'] != null) {
        return RewardWalletModel.fromJson(body['data']);
      }
    }
    return null;
  }

  Future<Map<String, dynamic>> transferRewards({
    required int walletId,
    required String accountNumber,
    required double amount,
  }) async {
    final url = Uri.parse('$_baseUrl/reward_transactions/transfer');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json', 'X-API-KEY': _apiKey},
      body: jsonEncode({
        'wallet_id': walletId,
        'account_number': accountNumber,
        'amount': amount,
        'channel': 'mobile_app',
        'reference': 'Mobile App Transfer',
      }),
    );
    _logApiCall('/reward_transactions/transfer', response);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to transfer rewards');
  }
}
