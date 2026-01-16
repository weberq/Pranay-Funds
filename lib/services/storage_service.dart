import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _usernameKey = 'last_username';
  static const _customerNameKey = 'last_customer_name';

  static const _mpinKey = 'last_mpin';

  /// Save the last logged-in user's details.
  Future<void> saveLastUser(
      String username, String customerName, String mpin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, username);
    await prefs.setString(_customerNameKey, customerName);
    await prefs.setString(_mpinKey, mpin);
  }

  /// Get the last logged-in user's details.
  Future<Map<String, String>?> getLastUser() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString(_usernameKey);
    final customerName = prefs.getString(_customerNameKey);
    final mpin = prefs.getString(_mpinKey);

    if (username != null && customerName != null) {
      return {
        'username': username,
        'customerName': customerName,
        'mpin': mpin ?? ''
      };
    }
    return null;
  }

  /// Clear the saved user details (for logout or changing user).
  Future<void> clearLastUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usernameKey);
    await prefs.remove(_customerNameKey);
    await prefs.remove(_mpinKey);
  }
}
