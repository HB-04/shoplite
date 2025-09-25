import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Abstract secure storage interface
/// In production, this would be implemented with flutter_secure_storage
/// For now, using SharedPreferences with basic encoding for demo purposes
abstract class SecureStorage {
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
  Future<void> deleteAll();
}

/// Implementation using SharedPreferences with basic security measures
/// Note: In production, replace with flutter_secure_storage for true security
class SecureStorageImpl implements SecureStorage {
  static const String _securePrefix = 'secure_';
  
  SharedPreferences? _prefs;
  
  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  @override
  Future<void> write(String key, String value) async {
    final secureKey = '$_securePrefix$key';
    // Basic encoding for demo (in production, use proper encryption)
    final encodedValue = base64Encode(utf8.encode(value));
    await (await prefs).setString(secureKey, encodedValue);
  }

  @override
  Future<String?> read(String key) async {
    final secureKey = '$_securePrefix$key';
    final encodedValue = (await prefs).getString(secureKey);
    
    if (encodedValue == null) return null;
    
    try {
      // Decode the value
      final decodedBytes = base64Decode(encodedValue);
      return utf8.decode(decodedBytes);
    } catch (e) {
      // If decoding fails, return null and clean up bad data
      await delete(key);
      return null;
    }
  }

  @override
  Future<void> delete(String key) async {
    final secureKey = '$_securePrefix$key';
    await (await prefs).remove(secureKey);
  }

  @override
  Future<void> deleteAll() async {
    final preferences = await prefs;
    final keys = preferences.getKeys();
    
    // Only delete keys with our secure prefix
    for (final key in keys) {
      if (key.startsWith(_securePrefix)) {
        await preferences.remove(key);
      }
    }
  }
}

/// Secure storage keys
class SecureStorageKeys {
  static const String authToken = 'auth_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
}
