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
      accountId: int.tryParse(json['account_id'].toString()) ?? 0,
      accountNumber: json['account_number'].toString(),
      // API returns 0, so we ensure it's a double
      accountBalance:
          (double.tryParse(json['account_balance'].toString()) ?? 0.0),
      customerId: int.tryParse(json['customer_id'].toString()) ?? 0,
      status: json['status'] ?? 'unknown',
    );
  }
}
