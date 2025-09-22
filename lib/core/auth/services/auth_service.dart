import 'package:cloud_firestore/cloud_firestore.dart';

class AuthServiceFireBase {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final String _usersCollection = 'users';

  // Check if email exists
  static Future<bool> isEmailExists(String email) async {
    final snapshot = await _firestore
        .collection(_usersCollection)
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  // Get Firestore docId by app-specific 8-digit userId
  static Future<String?> getDocIdByUserId(String userId) async {
    final snapshot = await _firestore
        .collection(_usersCollection)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    return snapshot.docs.first.id; // Return the Firestore document ID
  }

  // Verify password (plain text, replace with hash in real apps)
  static Future<bool> verifyPassword(String email, String password) async {
    final snapshot = await _firestore
        .collection(_usersCollection)
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return false;

    final user = snapshot.docs.first.data();
    return user['password'] == password;
  }

  // Get user by email
  static Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final snapshot = await _firestore
        .collection(_usersCollection)
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final doc = snapshot.docs.first;
    final data = doc.data();
    data['docId'] = doc.id; // Add document ID
    return data;
  }

  // ✅ Get user by Firestore document ID
  static Future<Map<String, dynamic>?> getUserById(String docId) async {
    final docSnapshot = await _firestore
        .collection(_usersCollection)
        .doc(docId)
        .get();

    if (!docSnapshot.exists) return null;

    final data = docSnapshot.data()!;
    data['docId'] = docSnapshot.id; // Add document ID
    return data;
  }
}

class UserServiceFireBase {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final String _usersCollection = 'users';

  // Check if username is taken
  static Future<bool> isUsernameTaken(String username) async {
    final snapshot = await _firestore
        .collection(_usersCollection)
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  // Get last userId as int
  static Future<int> getLastUserId() async {
    final snapshot = await _firestore
        .collection(_usersCollection)
        .orderBy('userId', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return -1;

    final lastIdStr = snapshot.docs.first.data()['userId'];
    return int.tryParse(lastIdStr) ?? -1;
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

    String userId = newId.toString().padLeft(8, '0');

    final userData = {
      "userId": userId,
      "name": name,
      "email": email,
      "birthday": birthday,
      "password": password,
      "username": username,
      "createdAt": DateTime.now().toIso8601String(),
    };

    await _firestore.collection(_usersCollection).add(userData);
  }
}
