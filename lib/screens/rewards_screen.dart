import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pranayfunds/models/reward_wallet_model.dart';
import 'package:pranayfunds/models/user_model.dart';
import 'package:pranayfunds/services/api_service.dart';

class RewardsScreen extends StatefulWidget {
  final UserModel user;
  const RewardsScreen({super.key, required this.user});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  final ApiService _apiService = ApiService();
  final _transferAmountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  RewardWalletModel? _wallet;
  bool _isLoading = true;
  bool _isTransferring = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchRewardWallet();
  }

  Future<void> _fetchRewardWallet() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final wallet = await _apiService.getRewardWallet(widget.user.customerId);
      setState(() {
        _wallet = wallet;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load rewards. Please try again.';
        _isLoading = false;
      });
    }
  }

  void _showTransferSheet() {
    if (_wallet == null) return;
    _transferAmountController.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Transfer to Savings',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Available Rewards: ₹${_wallet!.balance.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _transferAmountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Enter Amount',
                    prefixText: '₹ ',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Enter a valid positive amount';
                    }
                    if (amount > _wallet!.balance) {
                      return 'Insufficient reward balance';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isTransferring
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              Navigator.pop(context);
                              _transferFunds();
                            }
                          },
                    child: _isTransferring
                        ? const CircularProgressIndicator()
                        : const Text('Transfer Now'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _transferFunds() async {
    setState(() => _isTransferring = true);

    final amount = double.parse(_transferAmountController.text);

    // We need the savings account number.
    // Since we don't have it explicitly in UserModel or RewardWallet,
    // we'll assume we can pass the customer ID or reference to find it backend-side,
    // BUT the API requires 'account_number' OR 'account_id'.
    //
    // Strategy: We will First fetch the user's primary account to get the account number.
    // Or, simpler: The API 'transfer.php' takes 'account_number'.
    // Wait, the UserModel might not have account number.
    // Let's check 'getAccountDetails' in ApiService. It returns AccountModel which has accountNumber.

    String? accountNumber;
    try {
      final account =
          await _apiService.getAccountDetails(widget.user.customerId);
      accountNumber = account.accountNumber;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not find savings account: $e')),
        );
        setState(() => _isTransferring = false);
        return;
      }
    }

    if (accountNumber == null) return;

    try {
      final result = await _apiService.transferRewards(
        walletId: _wallet!.walletId,
        accountNumber: accountNumber,
        amount: amount,
      );

      if (result['status'] == 'success') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transfer successful!')),
          );
          _fetchRewardWallet(); // Refresh balance
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Transfer failed')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isTransferring = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Rewards'),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage!,
                          style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                          onPressed: _fetchRewardWallet,
                          child: const Text('Retry'))
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchRewardWallet,
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      // --- Balance Card (Updated to match Home UI) ---
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                        color: Theme.of(context).colorScheme.primaryContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reward Balance',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimaryContainer),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '₹${_wallet?.balance.toStringAsFixed(2) ?? "0.00"}',
                                style: GoogleFonts.lato(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  onPressed: _showTransferSheet,
                                  icon: const Icon(Icons.swap_horiz),
                                  label: const Text('Transfer to Savings'),
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // --- Info Section ---
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.grey[600]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Use your rewards to top up your savings account instantly. Minimum transfer amount is ₹1.00.',
                              style: TextStyle(
                                color: Colors.grey[600],
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // --- New Placeholder Cards ---
                      Row(
                        children: [
                          Expanded(
                            child: _buildComingSoonCard(
                              context,
                              'Refer and Earn',
                              Icons.person_add_alt_1_rounded,
                              Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildComingSoonCard(
                              context,
                              'Rewards & Vouchers',
                              Icons.redeem_rounded,
                              Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32), // Bottom padding
                    ],
                  ),
                ),
    );
  }

  Widget _buildComingSoonCard(
      BuildContext context, String title, IconData icon, Color color) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
        ),
      ),
      child: Container(
        height: 180,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .outlineVariant
                        .withOpacity(0.5),
                  )),
              child: Text(
                'COMING SOON',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
