class AccountModel {
  final int accountId;
  final String accountNumber;
  final double accountBalance;
  final int customerId;
  final String status;

  AccountModel({
    required this.accountId,
    required this.accountNumber,
    required this.accountBalance,
    required this.customerId,
    required this.status,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      accountId: json['account_id'],
      accountNumber: json['account_number'],
      // API returns 0, so we ensure it's a double
      accountBalance: (json['account_balance'] as num).toDouble(),
      customerId: json['customer_id'],
      status: json['status'],
    );
  }
}
