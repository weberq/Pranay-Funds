class RewardWalletModel {
  final int walletId;
  final int customerId;
  final double balance;
  final String status;
  final String? createdAt;
  final String? updatedAt;
  final String customerName;

  RewardWalletModel({
    required this.walletId,
    required this.customerId,
    required this.balance,
    required this.status,
    this.createdAt,
    this.updatedAt,
    required this.customerName,
  });

  factory RewardWalletModel.fromJson(Map<String, dynamic> json) {
    return RewardWalletModel(
      walletId: int.parse(json['wallet_id'].toString()),
      customerId: int.parse(json['customer_id'].toString()),
      // Handle potential string or int/double inputs for balance
      balance: double.tryParse(json['balance'].toString()) ?? 0.0,
      status: json['status'] ?? 'active',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      customerName: json['customer_name'] ?? '',
    );
  }
}
