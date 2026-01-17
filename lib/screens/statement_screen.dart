import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:pranayfunds/models/transaction_model.dart';
import 'package:pranayfunds/models/user_model.dart';
import 'package:pranayfunds/services/api_service.dart';

class StatementScreen extends StatefulWidget {
  final UserModel user;
  const StatementScreen({super.key, required this.user});

  @override
  State<StatementScreen> createState() => _StatementScreenState();
}

class _StatementScreenState extends State<StatementScreen> {
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();

  // Data State
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _error;

  // Filters
  Map<String, String> _currentFilters = {};
  String _filterLabel = "All Transactions";

  @override
  void initState() {
    super.initState();
    _fetchTransactions(reset: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMore) {
        _fetchTransactions(reset: false);
      }
    }
  }

  Future<void> _fetchTransactions({required bool reset}) async {
    if (reset) {
      setState(() {
        _isLoading = true;
        _error = null;
        _currentPage = 1;
        _hasMore = true;
        _transactions = [];
      });
    } else {
      setState(() {
        _isLoadingMore = true;
      });
    }

    try {
      // 1. Get account details first
      final account =
          await _apiService.getAccountDetails(widget.user.customerId);

      // 2. Fetch page
      final newTransactions = await _apiService.getTransactions(
        account.accountId,
        filters: _currentFilters,
        page: _currentPage,
      );

      setState(() {
        if (reset) {
          _transactions = newTransactions;
        } else {
          _transactions.addAll(newTransactions);
        }

        _hasMore = newTransactions.length >= 10; // Assuming page size is 10
        if (_hasMore) {
          _currentPage++;
        }
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  // --- FILTERING LOGIC ---
  void _applyFilter(Map<String, String> filter, String label) {
    _currentFilters = filter;
    _filterLabel = label;
    _fetchTransactions(reset: true);
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
                _applyFilter({}, "All Transactions");
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text("This Month"),
              onTap: () {
                Navigator.pop(context);
                final now = DateTime.now();
                _applyFilter(
                  {'month': DateFormat('yyyy-MM').format(now)},
                  "This Month",
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text("Last Month"),
              onTap: () {
                Navigator.pop(context);
                final now = DateTime.now();
                final lastMonth = DateTime(now.year, now.month - 1);
                _applyFilter(
                  {'month': DateFormat('yyyy-MM').format(lastMonth)},
                  "Last Month",
                );
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
                  _applyFilter(
                    {
                      'from': DateFormat('yyyy-MM-dd').format(range.start),
                      'to': DateFormat('yyyy-MM-dd').format(range.end),
                    },
                    "${DateFormat.yMMMd().format(range.start)} - ${DateFormat.yMMMd().format(range.end)}",
                  );
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
          // Filter Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Showing: $_filterLabel",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _showFilterModal,
                  icon: const Icon(Icons.filter_list, size: 18),
                  label: const Text("Filter"),
                )
              ],
            ),
          ),
          const Divider(height: 1),

          // List
          Expanded(
            child: _isLoading && _transactions.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _error != null && _transactions.isEmpty
                    ? Center(child: Text("Error: $_error"))
                    : _transactions.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: () async =>
                                _fetchTransactions(reset: true),
                            child: ListView.separated(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(8),
                              itemCount: _transactions.length +
                                  (_isLoadingMore ? 1 : 0),
                              separatorBuilder: (c, i) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                if (index == _transactions.length) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child:
                                          CircularProgressIndicator.adaptive(),
                                    ),
                                  );
                                }
                                return _buildTransactionCard(
                                    _transactions[index]);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final illustration = '''
    <svg width="150" height="150" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8zm-1-13h2v6h-2zm0 8h2v2h-2z" fill="#B0BEC5"/>
    </svg>
    ''';
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.string(illustration),
          Text("No Transactions",
              style: Theme.of(context).textTheme.headlineSmall),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(TransactionModel transaction) {
    final isCredit = transaction.transactionType.toLowerCase() == 'credit';
    final formatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    // Formatting Date and Time
    final dateStr = DateFormat.yMMMd().format(transaction.transactionDateTime);
    final timeStr = DateFormat.jm().format(transaction.transactionDateTime);

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isCredit
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                    color: isCredit ? Colors.green[700] : Colors.red[700],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.narration ??
                            transaction.reference ??
                            'Transaction',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$dateStr • $timeStr",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                      if (transaction.reference != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            "Ref: ${transaction.reference}",
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).colorScheme.outline,
                              fontFamily: 'Unifont', // Monospace feel for IDs
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${isCredit ? '+' : '-'} ${formatter.format(transaction.amount)}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isCredit ? Colors.green[800] : Colors.red[800],
                      ),
                    ),
                    if (transaction.balanceAfter != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          "Bal: ${transaction.balanceAfter}", // Might need currency formatting too if string is raw
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
