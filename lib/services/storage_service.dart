import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _usernameKey = 'last_username';
  static const _customerNameKey = 'last_customer_name';

  /// Save the last logged-in user's details.
  Future<void> saveLastUser(String username, String customerName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, username);
    await prefs.setString(_customerNameKey, customerName);
  }

  /// Get the last logged-in user's details.
  Future<Map<String, String>?> getLastUser() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString(_usernameKey);
    final customerName = prefs.getString(_customerNameKey);

    if (username != null && customerName != null) {
      return {'username': username, 'customerName': customerName};
    }
    return null;
  }

  /// Clear the saved user details (for logout or changing user).
  Future<void> clearLastUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usernameKey);
    await prefs.remove(_customerNameKey);
  }
}
