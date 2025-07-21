class TransactionModel {
  final int transactionId;
  final String transactionType; // "credit" or "debit"
  final DateTime transactionDateTime;
  final int amount;
  final String? balanceAfter; // Can be null for pending transactions
  final String status; // e.g., "pending", "posted"

  TransactionModel({
    required this.transactionId,
    required this.transactionType,
    required this.transactionDateTime,
    required this.amount,
    required this.status,
    this.balanceAfter,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      transactionId: json['transaction_id'],
      transactionType: json['transaction_type'],
      transactionDateTime: DateTime.parse(json['transaction_datetime']),
      amount: json['amount'],
      balanceAfter: json['balance_after'],
      status: json['status'],
    );
  }
}
