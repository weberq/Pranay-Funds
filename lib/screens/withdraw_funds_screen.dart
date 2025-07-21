import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pranayfunds/models/account_model.dart';
import 'package:pranayfunds/models/transaction_model.dart';
import 'package:pranayfunds/services/api_service.dart';

class WithdrawFundsScreen extends StatefulWidget {
  final AccountModel account;
  const WithdrawFundsScreen({super.key, required this.account});

  @override
  State<WithdrawFundsScreen> createState() => _WithdrawFundsScreenState();
}

class _WithdrawFundsScreenState extends State<WithdrawFundsScreen> {
  final ApiService _apiService = ApiService();
  Future<TransactionModel?>? _pendingWithdrawalFuture;

  @override
  void initState() {
    super.initState();
    _checkForPendingWithdrawal();
  }

  void _checkForPendingWithdrawal() {
    setState(() {
      _pendingWithdrawalFuture = _apiService
          .getTransactions(widget.account.accountId)
          .then((transactions) {
        try {
          return transactions.firstWhere(
              (t) => t.transactionType == 'debit' && t.status == 'pending');
        } catch (e) {
          return null; // No pending withdrawal found
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Withdraw Funds')),
      body: FutureBuilder<TransactionModel?>(
        future: _pendingWithdrawalFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final pendingWithdrawal = snapshot.data;

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: pendingWithdrawal != null
                ? _buildPendingRequestUI(pendingWithdrawal)
                : _buildNewRequestForm(),
          );
        },
      ),
    );
  }

  Widget _buildPendingRequestUI(TransactionModel transaction) {
    final formatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final illustration =
        '''<svg width="150" height="150" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8zm-1-13h2v6h-2zm0 8h2v2h-2z" fill="#FFB74D"/></svg>''';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SvgPicture.string(illustration),
          const SizedBox(height: 16),
          Text('Request Pending',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'You have a pending withdrawal request of ${formatter.format(transaction.amount)} submitted on ${DateFormat.yMMMd().format(transaction.transactionDateTime)}.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Text(
            'To make a new request, you must first cancel the existing one.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: () async {
              final success = await _apiService
                  .deleteTransaction(transaction.transactionId);
              if (success) {
                _checkForPendingWithdrawal(); // Refresh the screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Withdrawal request cancelled.')),
                );
              }
            },
            child: const Text('Cancel Request'),
          ),
        ],
      ),
    );
  }

  Widget _buildNewRequestForm() {
    final _formKey = GlobalKey<FormState>();
    final _amountController = TextEditingController();
    bool _isLoading = false;

    return StatefulBuilder(
      builder: (context, setFormState) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('New Withdrawal Request',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                    'Enter the amount you wish to withdraw. The request will be sent for approval.'),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Amount to Withdraw (₹)',
                    prefixIcon: const Icon(Icons.currency_rupee),
                    border: const OutlineInputBorder(),
                    helperText:
                        'Available balance: ${NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(widget.account.accountBalance)}',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Please enter an amount.';
                    final amount = double.tryParse(value);
                    if (amount == null) return 'Please enter a valid number.';
                    if (amount > widget.account.accountBalance)
                      return 'Amount exceeds available balance.';
                    if (amount <= 0) return 'Amount must be greater than zero.';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            if (!_formKey.currentState!.validate()) return;
                            setFormState(() => _isLoading = true);
                            final success =
                                await _apiService.submitWithdrawalRequest(
                              accountNumber: widget.account.accountNumber,
                              amount: double.parse(_amountController.text),
                            );
                            if (success) {
                              _checkForPendingWithdrawal(); // Refresh to show pending status
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Request failed. Please try again.')),
                              );
                            }
                            setFormState(() => _isLoading = false);
                          },
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Submit Request'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
