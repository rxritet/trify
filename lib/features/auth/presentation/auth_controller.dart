import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../data/auth_exceptions.dart';
import '../data/user_repository.dart';
import '../domain/app_user.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._repository);

  final UserRepository _repository;
  AppUser? _user;
  bool _loading = false;

  AppUser? get user => _user;
  bool get isLoading => _loading;

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    try {
      _user = await _repository.signIn(email: email, password: password);
      return _user != null;
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> register(String name, String email, String password) async {
    _setLoading(true);
    try {
      _user = await _repository.register(
        name: name,
        email: email,
        password: password,
      );
      return null;
    } on EmailAlreadyRegisteredException {
      return 'Этот email уже зарегистрирован.';
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> signInWithGoogle() async {
    if (Firebase.apps.isEmpty) {
      return 'Google-вход на Android ещё настраивается.';
    }
    _setLoading(true);
    try {
      final UserCredential credential;
      if (kIsWeb) {
        final provider = GoogleAuthProvider()
          ..setCustomParameters({'prompt': 'select_account'});
        credential = await FirebaseAuth.instance.signInWithPopup(provider);
      } else {
        await GoogleSignIn.instance.initialize();
        final googleUser = await GoogleSignIn.instance.authenticate();
        final googleAuth = googleUser.authentication;
        final googleCredential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );
        credential = await FirebaseAuth.instance.signInWithCredential(
          googleCredential,
        );
      }
      final googleUser = credential.user;
      if (googleUser == null || googleUser.email == null) {
        return 'Не удалось получить данные Google-аккаунта.';
      }
      _user = AppUser.fromGoogle(
        uid: googleUser.uid,
        email: googleUser.email!,
        displayName: googleUser.displayName,
      );
      return null;
    } on FirebaseAuthException catch (error) {
      if (error.code == 'popup-closed-by-user') {
        return 'Вход через Google отменён.';
      }
      return error.message ?? 'Не удалось войти через Google.';
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        return 'Вход через Google отменён.';
      }
      return 'Не удалось открыть выбор Google-аккаунта.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> restoreGoogleSession() async {
    if (Firebase.apps.isEmpty) return;
    final googleUser = FirebaseAuth.instance.currentUser;
    if (googleUser?.email == null) return;
    _user = AppUser.fromGoogle(
      uid: googleUser!.uid,
      email: googleUser.email!,
      displayName: googleUser.displayName,
    );
  }

  Future<void> signOut() async {
    if (Firebase.apps.isNotEmpty) {
      if (!kIsWeb && FirebaseAuth.instance.currentUser != null) {
        await GoogleSignIn.instance.signOut();
      }
      if (FirebaseAuth.instance.currentUser != null) {
        await FirebaseAuth.instance.signOut();
      }
    }
    _user = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}

class AuthScope extends InheritedNotifier<AuthController> {
  const AuthScope({
    super.key,
    required AuthController controller,
    required super.child,
  }) : super(notifier: controller);

  static AuthController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AuthScope>()!.notifier!;

  static AuthController? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AuthScope>()?.notifier;
}
