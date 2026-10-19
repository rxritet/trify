import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'auth_exceptions.dart';
import '../domain/app_user.dart';

class UserRepository {
  UserRepository._(this._database);
  final Database _database;

  static Future<UserRepository> open() async {
    final database = await openDatabase(
      join(await getDatabasesPath(), 'trify.db'),
      version: 1,
      onCreate: (db, _) => db.execute('''CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE, password_hash TEXT NOT NULL,
        created_at TEXT NOT NULL)'''),
    );
    final repository = UserRepository._(database);
    await repository._seedDemoUser();
    return repository;
  }

  Future<void> _seedDemoUser() async {
    if (Sqflite.firstIntValue(
          await _database.rawQuery('SELECT COUNT(*) FROM users'),
        ) ==
        0) {
      await register(
        name: 'Алина Сейтова',
        email: 'alina@trify.local',
        password: 'trify123',
      );
    }
  }

  Future<AppUser?> signIn({
    required String email,
    required String password,
  }) async {
    final rows = await _database.rawQuery(
      'SELECT id, name, email, created_at FROM users WHERE lower(email) = lower(?) AND password_hash = ?',
      [email.trim(), _hash(password)],
    );
    return rows.isEmpty ? null : AppUser.fromMap(rows.first);
  }

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final id = await _database.rawInsert(
        'INSERT INTO users (name, email, password_hash, created_at) VALUES (?, ?, ?, ?)',
        [
          name.trim(),
          email.trim().toLowerCase(),
          _hash(password),
          DateTime.now().toIso8601String(),
        ],
      );
      final rows = await _database.rawQuery(
        'SELECT id, name, email, created_at FROM users WHERE id = ?',
        [id],
      );
      return AppUser.fromMap(rows.single);
    } on DatabaseException catch (error) {
      if (error.isUniqueConstraintError()) {
        throw const EmailAlreadyRegisteredException();
      }
      rethrow;
    }
  }

  static String _hash(String value) =>
      sha256.convert(utf8.encode(value)).toString();
}
