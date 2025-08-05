class TransactionModel {
  final int transactionId;
  final String transactionType;
  final DateTime transactionDateTime;
  final double amount; // <-- FIX: Changed from int to double
  final String? balanceAfter;
  final String status;

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
      amount: (json['amount'] as num).toDouble(),
      balanceAfter: json['balance_after'],
      status: json['status'],
    );
  }
}
