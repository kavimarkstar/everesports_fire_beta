import 'dart:async';

import 'package:everesports/database/config/config.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class AuthService {
  static late mongo.Db db;
  static late mongo.DbCollection _usersCollection;

  static Future<void> init() async {
    db = mongo.Db(configDatabase);
    await db.open();
    _usersCollection = db.collection('users');
  }

  static Future<bool> isEmailExists(String email) async {
    final user = await _usersCollection.findOne({'email': email});
    return user != null;
  }

  static Future<bool> verifyPassword(String email, String password) async {
    final user = await _usersCollection.findOne({'email': email});
    if (user == null) return false;

    // Simple plain text check (use hashed check in real apps)
    return user['password'] == password;
  }

  static Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    return await _usersCollection.findOne({'email': email});
  }

  static Future<void> close() async {
    await db.close();
  }
}

class UserService {
  static late mongo.Db _db;
  static late mongo.DbCollection _usersCollection;

  static Future<void> init() async {
    _db = mongo.Db(configDatabase);
    await _db.open();
    _usersCollection = _db.collection('users');
  }

  static Future<void> close() async {
    await _db.close();
  }

  static Future<bool> isUsernameTaken(String username) async {
    final doc = await _usersCollection.findOne({'username': username});
    return doc != null;
  }

  // Get last userId as int, or -1 if none exists
  static Future<int> getLastUserId() async {
    final users = await _usersCollection
        .find(mongo.where.sortBy('userId', descending: true).limit(1))
        .cast<Map<String, dynamic>>()
        .toList();

    if (users.isEmpty || users.first['userId'] == null) return -1;
    return int.tryParse(users.first['userId']) ?? -1;
  }

  // Insert user with auto-incremented 8-digit userId
  static Future<void> insertUser({
    required String name,
    required String email,
    required String birthday,
    required String password,
    required String username,
  }) async {
    int lastId = await getLastUserId();
    int newId = lastId + 1;

    // Format userId with 8-digit leading zeros (e.g. 00000001)
    String userId = newId.toString().padLeft(8, '0');

    final userData = {
      "_id": mongo.ObjectId(),
      "userId": userId,
      "name": name,
      "email": email,
      "birthday": birthday,
      "password": password,
      "username": username,
      "createdAt": DateTime.now().toIso8601String(),
    };

    await _usersCollection.insert(userData);
  }
}
