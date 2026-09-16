import '../services/auth_service.dart';

enum AuthStatus { initial, loading, success, error }

enum AuthFlow { none, registerOtp }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final String? token;
  final User? user;
  final AuthFlow flow;
  final String? pendingMobile;

  const AuthState({
    this.status = AuthStatus.initial,
    this.errorMessage,
    this.token,
    this.user,
    this.flow = AuthFlow.none,
    this.pendingMobile,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    String? token,
    User? user,
    AuthFlow? flow,
    String? pendingMobile,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      token: token ?? this.token,
      user: user ?? this.user,
      flow: flow ?? this.flow,
      pendingMobile: pendingMobile ?? this.pendingMobile,
    );
  }
}
