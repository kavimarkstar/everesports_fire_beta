import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ProfileService {
  final String serverBaseUrl;

  ProfileService({required this.serverBaseUrl});

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _usersCollection = _firestore.collection(
    'users',
  );

  /// Fetch user by Firestore document id or by userId field
  Future<Map<String, dynamic>?> fetchUserById(String id) async {
    try {
      // Try to get by document id
      DocumentSnapshot? doc;
      if (id.length == 20 || id.length == 28 || id.length == 36) {
        // Firestore auto id lengths (not 24 like Mongo)
        doc = await _usersCollection.doc(id).get();
        if (doc.exists) {
          return doc.data() as Map<String, dynamic>;
        }
      }
      // Fallback: try by userId field
      final query = await _usersCollection
          .where('userId', isEqualTo: id)
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        return query.docs.first.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Update user profile in Firestore
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
      // Try to update by document id
      DocumentReference? docRef;
      if (id.length == 20 || id.length == 28 || id.length == 36) {
        docRef = _usersCollection.doc(id);
        final doc = await docRef.get();
        if (!doc.exists) {
          docRef = null;
        }
      }
      // Fallback: update by userId field
      if (docRef == null) {
        final query = await _usersCollection
            .where('userId', isEqualTo: id)
            .limit(1)
            .get();
        if (query.docs.isEmpty) return false;
        docRef = query.docs.first.reference;
      }
      await docRef.update({
        'name': name,
        'username': username,
        'birthday': birthday,
        'password': password,
        'profileImageUrl': profileImageUrl ?? '',
        'coverImageUrl': coverImageUrl ?? '',
      });
      return true;
    } catch (e) {
      rethrow;
    }
  }

  /// Upload image to server (for profile/cover image)
  Future<String?> uploadImage({
    required String endpoint,
    required String filePath,
    String? oldImagePath,
    String? userId,
    String oldImageField = 'oldImagePath',
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$serverBaseUrl/$endpoint'),
      );
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      if (oldImagePath != null) {
        request.fields[oldImageField] = oldImagePath;
      }
      if (userId != null) {
        request.fields['userId'] = userId;
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final jsonResp = jsonDecode(responseBody);

      if (response.statusCode == 200 && jsonResp['imageUrl'] != null) {
        return jsonResp['imageUrl'];
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Delete image from server
  Future<bool> deleteImage({
    required String endpoint,
    required String imagePath,
    String? userId,
  }) async {
    try {
      final uri = Uri.parse('$serverBaseUrl/$endpoint');
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'imagePath': imagePath,
          if (userId != null) 'userId': userId,
        }),
      );
      return res.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  /// Upload image from bytes (for profile/cover image)
  Future<String?> uploadImageFromBytes({
    required String endpoint,
    required Uint8List bytes,
    String? oldImagePath,
    String? userId,
    required String oldImageField,
  }) async {
    try {
      final uri = Uri.parse('$serverBaseUrl/$endpoint');
      var request = http.MultipartRequest('POST', uri);

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: 'upload_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      if (oldImagePath != null) {
        request.fields[oldImageField] = oldImagePath;
      }
      if (userId != null) {
        request.fields['userId'] = userId;
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final jsonResp = jsonDecode(responseBody);

      if (response.statusCode == 200 && jsonResp['imageUrl'] != null) {
        return jsonResp['imageUrl'];
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
