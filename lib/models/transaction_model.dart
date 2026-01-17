class TransactionModel {
  final int transactionId;
  final String transactionType;
  final DateTime transactionDateTime;
  final double amount;
  final String? balanceAfter;
  final String status;
  final String? reference;
  final String? narration;
  final String? channel;

  TransactionModel({
    required this.transactionId,
    required this.transactionType,
    required this.transactionDateTime,
    required this.amount,
    required this.status,
    this.balanceAfter,
    this.reference,
    this.narration,
    this.channel,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      transactionId: json['transaction_id'],
      transactionType: json['transaction_type'],
      transactionDateTime: DateTime.parse(json['transaction_datetime']),
      amount: (json['amount'] as num).toDouble(),
      balanceAfter: json['balance_after'],
      status: json['status'],
      reference: json['reference'],
      narration: json['narration'],
      channel: json['channel'],
    );
  }
}
