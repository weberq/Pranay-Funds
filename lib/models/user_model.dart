// lib/models/user_model.dart

class UserModel {
  final int userId;
  final int customerId;
  final String customerName;
  final String username;

  UserModel({
    required this.userId,
    required this.customerId,
    required this.customerName,
    required this.username,
  });

  // A factory constructor to easily create a UserModel from the API's JSON response
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'],
      customerId: json['customer_id'],
      customerName:
          json['customer_name'] ?? 'Valued Customer', // Provide a fallback name
      username: json['username'].toString(),
    );
  }
}
