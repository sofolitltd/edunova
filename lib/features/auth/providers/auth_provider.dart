import 'package:flutter_riverpod/legacy.dart';

import '../models/auth_state.dart';
import '../services/auth_service.dart';
import '../../../shared/services/secure_storage_service.dart';
import '../../../shared/services/notification_service.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final SecureStorageService _storage;

  AuthNotifier({AuthService? authService, SecureStorageService? storage})
      : _authService = authService ?? AuthService(),
        _storage = storage ?? SecureStorageService(),
        super(const AuthState());

  Future<void> init() async {
    final token = await _storage.readToken();
    if (token == null || token.isEmpty) return;

    final user = await _storage.readUser();
    final id = int.tryParse(user['id'] ?? '');
    if (id == null) return;

    state = AuthState(
      token: token,
      user: User(
        id: id,
        fullName: user['fullName'] ?? '',
        mobile: user['mobile'] ?? '',
        verified: user['verified'] == 'true',
        studentClass: user['studentClass'] ?? '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  void reset() {
    state = state.copyWith(status: AuthStatus.initial, errorMessage: null);
  }

  Future<void> login({required String mobile, required String password}) async {
    state = const AuthState(status: AuthStatus.loading);

    try {
      final result = await _authService.login(
        mobile: mobile,
        password: password,
      );

      if (result.token != null) {
        await _storage.saveToken(result.token!);
      }
      if (result.user != null) {
        await _storage.saveUser(
          id: result.user!.id,
          fullName: result.user!.fullName,
          mobile: result.user!.mobile,
          verified: result.user!.verified,
          studentClass: result.user!.studentClass,
        );
      }

      state = state.copyWith(
        status: AuthStatus.success,
        token: result.token,
        user: result.user,
      );

      // Register FCM token after login
      NotificationService().initialize(this);
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Connection failed. Please try again.',
      );
    }
  }

  Future<void> register({
    required String fullName,
    required String mobile,
    required String password,
    required String studentClass,
  }) async {
    state = const AuthState(status: AuthStatus.loading);

    try {
      await _authService.register(
        fullName: fullName,
        mobile: mobile,
        password: password,
        studentClass: studentClass,
      );

      // TODO: Restore AuthFlow.registerOtp when OTP is re-enabled in backend
      state = const AuthState(
        status: AuthStatus.success,
        // flow: AuthFlow.registerOtp,
      ).copyWith(pendingMobile: mobile);
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Connection failed. Please try again.',
      );
    }
  }

  Future<void> verifyOTP({
    required String mobile,
    required String code,
  }) async {
    state = const AuthState(status: AuthStatus.loading);

    try {
      await _authService.verifyOTP(mobile: mobile, code: code);

      state = const AuthState(status: AuthStatus.success);
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Connection failed. Please try again.',
      );
    }
  }

  Future<void> resendOTP({required String mobile}) async {
    try {
      await _authService.resendOTP(mobile: mobile);
    } on AuthException {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _storage.clearAll();
    state = const AuthState();
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final token = state.token;
    if (token == null) throw AuthException('Not authenticated');

    state = state.copyWith(status: AuthStatus.loading);

    try {
      await _authService.changePassword(
        token: token,
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      state = state.copyWith(status: AuthStatus.success);
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Connection failed. Please try again.',
      );
    }
  }

  Future<User> updateProfile({
    required String fullName,
    String fatherName = '',
    String fatherMobile = '',
    String motherName = '',
    String motherMobile = '',
    String notificationMobile = '',
    String gender = '',
    String religion = '',
    String studentClass = '',
    String shift = '',
    String school = '',
    String address = '',
  }) async {
    final token = state.token;
    if (token == null) throw AuthException('Not authenticated');

    try {
      final updatedUser = await _authService.updateProfile(
        token: token,
        fullName: fullName,
        fatherName: fatherName,
        fatherMobile: fatherMobile,
        motherName: motherName,
        motherMobile: motherMobile,
        notificationMobile: notificationMobile,
        gender: gender,
        religion: religion,
        studentClass: studentClass,
        shift: shift,
        school: school,
        address: address,
      );
      state = state.copyWith(user: updatedUser);
      await _storage.saveUser(
        id: updatedUser.id,
        fullName: updatedUser.fullName,
        mobile: updatedUser.mobile,
        verified: updatedUser.verified,
        studentClass: updatedUser.studentClass,
      );
      return updatedUser;
    } on AuthException catch (e) {
      throw AuthException(e.message);
    }
  }

  Future<void> registerDeviceToken(String fcmToken) async {
    final token = state.token;
    if (token == null) return;
    try {
      await _authService.registerDeviceToken(token: token, fcmToken: fcmToken);
    } catch (_) {}
  }

}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});