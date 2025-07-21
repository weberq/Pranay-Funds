import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pranayfunds/models/account_model.dart';
import 'package:pranayfunds/models/transaction_model.dart';
import 'package:pranayfunds/services/api_service.dart';

class AddFundsScreen extends StatefulWidget {
  final AccountModel account;
  const AddFundsScreen({super.key, required this.account});

  @override
  State<AddFundsScreen> createState() => _AddFundsScreenState();
}

class _AddFundsScreenState extends State<AddFundsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  // This Future holds the list of pending deposits
  late Future<List<TransactionModel>> _pendingDepositsFuture;

  @override
  void initState() {
    super.initState();
    // Fetch the pending deposits when the screen first loads
    _fetchPendingDeposits();
  }

  /// Fetches only the credit transactions that have a 'pending' status.
  void _fetchPendingDeposits() {
    setState(() {
      _pendingDepositsFuture = _apiService
          .getTransactions(widget.account.accountId)
          .then((transactions) => transactions
              .where(
                  (t) => t.transactionType == 'credit' && t.status == 'pending')
              .toList());
    });
  }

  /// Copies the provided text to the clipboard and shows a confirmation message.
  void _copyToClipboard(String text, String fieldName) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$fieldName copied to clipboard!')),
    );
  }

  /// Validates the form and submits the new transaction to the API.
  Future<void> _submitTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final success = await _apiService.submitManualTransaction(
      accountNumber: widget.account.accountNumber,
      amount: double.parse(_amountController.text),
      reference: _referenceController.text,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        // Clear the form fields for the next entry
        _amountController.clear();
        _referenceController.clear();
        // Refresh the list of pending deposits to show the new one
        _fetchPendingDeposits();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Submission successful! Awaiting approval.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Submission failed. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Funds')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // This section will display the list of pending transactions
            _buildPendingDepositsSection(),
            const SizedBox(height: 24),
            _buildInstructionsCard(),
            const SizedBox(height: 24),
            _buildSubmissionForm(),
          ],
        ),
      ),
    );
  }

  /// Builds the UI section that displays pending deposits.
  Widget _buildPendingDepositsSection() {
    return FutureBuilder<List<TransactionModel>>(
      future: _pendingDepositsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        // If there are no pending deposits, don't show anything
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }
        final pending = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Pending Deposits",
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pending.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return _buildPendingTransactionCard(pending[index]);
              },
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  /// A styled card for displaying a single pending transaction.
  Widget _buildPendingTransactionCard(TransactionModel transaction) {
    final formatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color:
                Theme.of(context).colorScheme.outlineVariant.withOpacity(0.7)),
      ),
      child: ListTile(
        leading: const Icon(Icons.hourglass_top_rounded, color: Colors.orange),
        title: Text(formatter.format(transaction.amount),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
            'Submitted on ${DateFormat.yMMMd().format(transaction.transactionDateTime)}'),
        trailing: const Chip(label: Text('Pending')),
      ),
    );
  }

  /// The card that shows the bank details for the manual transfer.
  Widget _buildInstructionsCard() {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Step 1: Transfer Funds",
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Please transfer funds to the account below using your preferred method (UPI or Bank Transfer).",
            ),
            const Divider(height: 24),
            _buildInfoRow('A/c No.', '7613049198'),
            _buildInfoRow('IFSC Code', 'KKBK0007475'),
            _buildInfoRow('UPI ID', '9676504552@kotak811'),
            _buildInfoRow('Branch', 'KPHB (PRATIBA VIDYANIKETAN)'),
          ],
        ),
      ),
    );
  }

  /// The form where the user submits their transaction details.
  Widget _buildSubmissionForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Step 2: Submit Details",
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
            "After transferring, please fill out the form below to notify us."),
        const SizedBox(height: 16),
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount Transferred (₹)',
                  prefixIcon: Icon(Icons.currency_rupee),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Please enter an amount.';
                  if (double.tryParse(value) == null)
                    return 'Please enter a valid number.';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _referenceController,
                decoration: const InputDecoration(
                  labelText: 'Transaction Reference No.',
                  prefixIcon: Icon(Icons.receipt_long),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Please enter a reference number.';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitTransaction,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Submit for Approval'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// A helper widget for displaying a row of information with a copy button.
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins()),
          Row(
            children: [
              Text(value, style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => _copyToClipboard(value, label),
                child: Icon(Icons.copy,
                    size: 16, color: Theme.of(context).colorScheme.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
