import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pranayfunds/models/account_model.dart';
import 'package:pranayfunds/models/transaction_model.dart';
import 'package:pranayfunds/models/user_model.dart';
import 'package:pranayfunds/services/api_service.dart';

class HomeScreen extends StatefulWidget {
  final UserModel user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Map<String, dynamic>> _dashboardData;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _dashboardData = _fetchDashboardData();
  }

  /// Fetches account and transaction data, and corrects the balance if necessary.
  Future<Map<String, dynamic>> _fetchDashboardData() async {
    if (kDebugMode) {
      print(
          "--- 📊 [HomeScreen] Fetching dashboard data for customerId: ${widget.user.customerId} ---");
    }
    try {
      AccountModel account =
          await _apiService.getAccountDetails(widget.user.customerId);
      final transactions = await _apiService.getTransactions(account.accountId);

      // --- FIX FOR ACCOUNT BALANCE ---
      // If the account balance is 0 but there are transactions, use the latest transaction's balance.
      if (account.accountBalance == 0 && transactions.isNotEmpty) {
        if (kDebugMode) {
          print(
              "--- 🛠️ [HomeScreen] Account balance is 0. Correcting from latest transaction. ---");
        }
        // Sort transactions by date to find the most recent one
        transactions.sort(
            (a, b) => b.transactionDateTime.compareTo(a.transactionDateTime));
        final latestBalance =
            double.tryParse(transactions.first.balanceAfter) ?? 0.0;

        // Create a new AccountModel with the corrected balance
        account = AccountModel(
          accountId: account.accountId,
          accountNumber: account.accountNumber,
          accountBalance: latestBalance, // Use the corrected balance
          customerId: account.customerId,
          status: account.status,
        );
      }

      if (kDebugMode) {
        print(
            "--- ✅ [HomeScreen] Data fetching complete. Final balance: ${account.accountBalance} ---");
      }
      return {'account': account, 'transactions': transactions};
    } catch (e) {
      if (kDebugMode) {
        print("--- 🚨 [HomeScreen] Error fetching dashboard data: $e ---");
      }
      return Future.error(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('Welcome, ${widget.user.customerName.split(' ')[0]}!'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dashboardData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Failed to load data: ${snapshot.error}'),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No data available.'));
          }

          final AccountModel account = snapshot.data!['account'];
          final List<TransactionModel> transactions =
              snapshot.data!['transactions'];

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _dashboardData = _fetchDashboardData();
              });
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                _buildPortfolioCard(context, account.accountBalance),
                const SizedBox(height: 24),
                _buildQuickActions(context), // <-- NEW QUICK ACTIONS
                const SizedBox(height: 24),
                _buildSectionHeader(context, 'Recent Transactions'),
                const SizedBox(height: 8),
                _buildTransactionsList(transactions),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPortfolioCard(BuildContext context, double balance) {
    final formatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Balance',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer),
            ),
            const SizedBox(height: 8),
            Text(
              formatter.format(balance),
              style: GoogleFonts.lato(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer),
            ),
          ],
        ),
      ),
    );
  }

  // --- NEW WIDGET FOR QUICK ACTIONS ---
  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _actionButton(context, Icons.add_card_outlined, 'Add Funds', () {}),
        _actionButton(context, Icons.outbox_rounded, 'Withdraw', () {}),
        _actionButton(context, Icons.receipt_long_outlined, 'Statement', () {}),
      ],
    );
  }

  Widget _actionButton(BuildContext context, IconData icon, String label,
      VoidCallback onPressed) {
    return Column(
      children: [
        FilledButton.tonal(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
          ),
          child: Icon(icon, size: 28),
        ),
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
  // --- END OF NEW WIDGETS ---

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTransactionsList(List<TransactionModel> transactions) {
    if (transactions.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: Text('No recent transactions.')),
        ),
      );
    }
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
            color:
                Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount:
            transactions.length > 5 ? 5 : transactions.length, // Show max 5
        separatorBuilder: (context, index) =>
            const Divider(height: 1, indent: 16, endIndent: 16),
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          final isCredit = transaction.transactionType == 'credit';
          final formatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

          return ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor:
                  (isCredit ? Colors.green : Colors.red).withOpacity(0.1),
              child: Icon(
                isCredit
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded,
                color: isCredit ? Colors.green.shade700 : Colors.red.shade700,
              ),
            ),
            title: Text(
              isCredit ? 'Credit' : 'Debit',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
                DateFormat.yMMMd().format(transaction.transactionDateTime)),
            trailing: Text(
              formatter.format(transaction.amount),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isCredit ? Colors.green.shade700 : Colors.red.shade700,
              ),
            ),
          );
        },
      ),
    );
  }
}
