import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_exceptions.dart';
import '../domain/app_user.dart';

class UserRepository {
  UserRepository._(this._preferences);
  final SharedPreferencesAsync _preferences;
  static const _key = 'trify_local_users';

  static Future<UserRepository> open() async {
    final repository = UserRepository._(SharedPreferencesAsync());
    if ((await repository._read()).isEmpty) {
      await repository.register(
        name: 'Алина Сейтова',
        email: 'alina@trify.local',
        password: 'trify123',
      );
    }
    return repository;
  }

  Future<AppUser?> signIn({
    required String email,
    required String password,
  }) async {
    final user = (await _read()).where(
      (item) =>
          item['email'] == email.trim().toLowerCase() &&
          item['password_hash'] == _hash(password),
    );
    return user.isEmpty ? null : AppUser.fromMap(user.first);
  }

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final users = await _read();
    final normalizedEmail = email.trim().toLowerCase();
    if (users.any((item) => item['email'] == normalizedEmail)) {
      throw const EmailAlreadyRegisteredException();
    }
    final user = <String, Object?>{
      'id': DateTime.now().microsecondsSinceEpoch,
      'name': name.trim(),
      'email': normalizedEmail,
      'password_hash': _hash(password),
      'created_at': DateTime.now().toIso8601String(),
    };
    users.add(user);
    await _preferences.setString(_key, jsonEncode(users));
    return AppUser.fromMap(user);
  }

  Future<List<Map<String, Object?>>> _read() async {
    final raw = await _preferences.getString(_key);
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((item) => Map<String, Object?>.from(item as Map))
        .toList();
  }

  static String _hash(String value) =>
      sha256.convert(utf8.encode(value)).toString();
}
