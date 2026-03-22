sealed class AuthState {}

class Initial extends AuthState {
  Initial();
}

class Authenticated extends AuthState {
  Authenticated();
}

class Unauthenticated implements AuthState {
  Unauthenticated();
}

class AuthErrorState extends AuthState {
  final String message;
  AuthErrorState(this.message);
}
