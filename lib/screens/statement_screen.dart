import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:pranayfunds/models/transaction_model.dart';
import 'package:pranayfunds/services/api_service.dart';

class StatementScreen extends StatefulWidget {
  final int accountId;
  const StatementScreen({super.key, required this.accountId});

  @override
  State<StatementScreen> createState() => _StatementScreenState();
}

class _StatementScreenState extends State<StatementScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<TransactionModel>> _transactionsFuture;
  Map<String, String> _currentFilters = {};
  String _filterLabel = "All Transactions"; // Default to showing all

  @override
  void initState() {
    super.initState();
    _fetchTransactions(); // Fetch all transactions initially
  }

  void _fetchTransactions() {
    setState(() {
      _transactionsFuture = _apiService.getTransactions(widget.accountId,
          filters: _currentFilters);
    });
  }

  // --- FILTERING LOGIC ---
  void _applyFilterAll() {
    _currentFilters = {}; // Empty filter fetches all
    _filterLabel = "All Transactions";
    _fetchTransactions();
  }

  void _applyFilterThisMonth() {
    final now = DateTime.now();
    _currentFilters = {'month': DateFormat('yyyy-MM').format(now)};
    _filterLabel = "This Month";
    _fetchTransactions();
  }

  void _applyFilterByYear(int year) {
    _currentFilters = {'year': year.toString()};
    _filterLabel = "Year: $year";
    _fetchTransactions();
  }

  void _applyFilterByDateRange(DateTimeRange range) {
    _currentFilters = {
      'from': DateFormat('yyyy-MM-dd').format(range.start),
      'to': DateFormat('yyyy-MM-dd').format(range.end),
    };
    _filterLabel =
        "${DateFormat.yMMMd().format(range.start)} - ${DateFormat.yMMMd().format(range.end)}";
    _fetchTransactions();
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Filter Transactions",
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.clear_all),
              title: const Text("All Transactions"),
              onTap: () {
                Navigator.pop(context);
                _applyFilterAll();
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text("This Month"),
              onTap: () {
                Navigator.pop(context);
                _applyFilterThisMonth();
              },
            ),
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text("This Year"),
              onTap: () {
                Navigator.pop(context);
                _applyFilterByYear(DateTime.now().year);
              },
            ),
            ListTile(
              leading: const Icon(Icons.date_range),
              title: const Text("Custom Date Range"),
              onTap: () async {
                Navigator.pop(context);
                final range = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (range != null) {
                  _applyFilterByDateRange(range);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Statement")),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ActionChip(
              avatar: const Icon(Icons.filter_list),
              label: Text(_filterLabel),
              onPressed: _showFilterModal,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<TransactionModel>>(
              future: _transactionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  // --- NEW EXPRESSIVE EMPTY STATE ---
                  return _buildEmptyState();
                }

                final transactions = snapshot.data!;
                return ListView.separated(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: transactions.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return _buildTransactionCard(transaction);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// A beautiful widget to show when no transactions are found.
  Widget _buildEmptyState() {
    final illustration = '''
    <svg width="150" height="150" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8zm-1-13h2v6h-2zm0 8h2v2h-2z" fill="#B0BEC5"/>
    <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8z" fill="none"/>
    <path d="M11 7h2v6h-2zm0 8h2v2h-2z" fill="#78909C"/>
    </svg>
    ''';
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.string(illustration),
          const SizedBox(height: 16),
          Text(
            "No Transactions Found",
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "Try selecting a different filter\nor date range.",
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// An updated transaction tile wrapped in a styled Card.
  Widget _buildTransactionCard(TransactionModel transaction) {
    final isCredit = transaction.transactionType == 'credit';
    final formatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color:
                Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        title: Text(isCredit ? 'Credit' : 'Debit',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle:
            Text(DateFormat.yMMMd().format(transaction.transactionDateTime)),
        trailing: Text(
          formatter.format(transaction.amount),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isCredit ? Colors.green.shade700 : Colors.red.shade700,
          ),
        ),
      ),
    );
  }
}
