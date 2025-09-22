import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

class AuthServiceFireBase {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final String _usersCollection = 'users';

  // ✅ Check if email exists
  static Future<bool> isEmailExists(String email) async {
    final snapshot = await _firestore
        .collection(_usersCollection)
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  // ✅ Verify password (plain text for now, replace with hash in production)
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

  // ✅ Get user by email
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

  // ✅ NEW: Get Firestore document ID by app-specific 8-digit userId
  static Future<String?> getDocIdByUserId(String userId) async {
    final snapshot = await _firestore
        .collection(_usersCollection)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    return snapshot.docs.first.id;
  }
}

class ProfileServiceFireBase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _usersCollection = 'users';

  // Fetch user by Firestore docId
  Future<Map<String, dynamic>?> fetchUserById(String docId) async {
    final docSnapshot = await _firestore
        .collection(_usersCollection)
        .doc(docId)
        .get();
    if (!docSnapshot.exists) return null;
    final data = docSnapshot.data()!;
    data['docId'] = docSnapshot.id;
    return data;
  }

  // Update user profile
  Future<bool> updateUserProfile({
    required String id,
    required String name,
    required String username,
    required String birthday,
    required String password,
    String? profileImageUrl,
    String? coverImageUrl,
  }) async {
    try {
      await _firestore.collection(_usersCollection).doc(id).update({
        'name': name,
        'username': username,
        'birthday': birthday,
        'password': password,
        'profileImageUrl': profileImageUrl,
        'coverImageUrl': coverImageUrl,
      });
      return true;
    } catch (e) {
      print("Error updating profile: $e");
      return false;
    }
  }

  // Upload image from bytes (simulate Firestore Storage path)
  Future<String?> uploadImageFromBytes({
    required String endpoint,
    required Uint8List bytes,
    String? oldImagePath,
    String? userId,
    String? oldImageField,
  }) async {
    // For now just return a dummy URL; replace with Firebase Storage upload
    return "https://example.com/${endpoint}_image.png";
  }

  // Delete image
  Future<bool> deleteImage({
    required String endpoint,
    required String imagePath,
    String? userId,
  }) async {
    // Implement Firebase Storage delete logic here
    print("Deleted $endpoint image: $imagePath");
    return true;
  }
}
