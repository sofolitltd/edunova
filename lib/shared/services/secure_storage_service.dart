import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _keyToken = 'auth_token';
  static const _keyUserId = 'user_id';
  static const _keyUserName = 'user_name';
  static const _keyUserMobile = 'user_mobile';
  static const _keyUserVerified = 'user_verified';
  static const _keyUserStudentClass = 'user_student_class';
  static const _keyLocale = 'app_locale';
  static const _keyTheme = 'app_theme';
  static const _keyHasSeenWelcome = 'has_seen_welcome';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  Future<String?> readToken() async {
    return await _storage.read(key: _keyToken);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _keyToken);
  }

  Future<void> saveUser({
    required int id,
    required String fullName,
    required String mobile,
    required bool verified,
    String studentClass = '',
  }) async {
    await _storage.write(key: _keyUserId, value: id.toString());
    await _storage.write(key: _keyUserName, value: fullName);
    await _storage.write(key: _keyUserMobile, value: mobile);
    await _storage.write(key: _keyUserVerified, value: verified.toString());
    await _storage.write(key: _keyUserStudentClass, value: studentClass);
  }

  Future<Map<String, String?>> readUser() async {
    return {
      'id': await _storage.read(key: _keyUserId),
      'fullName': await _storage.read(key: _keyUserName),
      'mobile': await _storage.read(key: _keyUserMobile),
      'verified': await _storage.read(key: _keyUserVerified),
      'studentClass': await _storage.read(key: _keyUserStudentClass),
    };
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  Future<bool> hasToken() async {
    final token = await readToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> saveLocale(String code) async {
    await _storage.write(key: _keyLocale, value: code);
  }

  Future<String?> readLocale() async {
    return await _storage.read(key: _keyLocale);
  }

  Future<void> saveTheme(String mode) async {
    await _storage.write(key: _keyTheme, value: mode);
  }

  Future<String?> readTheme() async {
    return await _storage.read(key: _keyTheme);
  }

  Future<void> saveHasSeenWelcome() async {
    await _storage.write(key: _keyHasSeenWelcome, value: 'true');
  }

  Future<bool> hasSeenWelcome() async {
    final val = await _storage.read(key: _keyHasSeenWelcome);
    return val == 'true';
  }
}
