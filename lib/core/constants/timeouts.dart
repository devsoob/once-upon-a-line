class AppTimeouts {
  AppTimeouts._();

  static const Duration firebaseInit = Duration(seconds: 20);
  static const Duration anonymousSignIn = Duration(seconds: 15);
  static const Duration createRoom = Duration(seconds: 5);
}
