import 'dart:convert';
import 'dart:typed_data';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // <-- Add this import

class ProfileService {
  final String connectionString;
  final String serverBaseUrl;

  mongo.Db? _db;
  mongo.DbCollection? _usersCollection;

  ProfileService({required this.connectionString, required this.serverBaseUrl});

  Future<void> openDb() async {
    _db = await mongo.Db.create(connectionString);
    await _db!.open();
    _usersCollection = _db!.collection("users");
  }

  Future<void> closeDb() async {
    await _db?.close();
  }

  Future<Map<String, dynamic>?> fetchUserById(String id) async {
    try {
      await openDb();
      final user = id.length == 24
          ? await _usersCollection!.findOne(
              mongo.where.id(mongo.ObjectId.fromHexString(id)),
            )
          : await _usersCollection!.findOne(mongo.where.eq('userId', id));
      await closeDb();
      return user;
    } catch (e) {
      rethrow;
    }
  }

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
      await openDb();
      final selector = id.length == 24
          ? mongo.where.id(mongo.ObjectId.fromHexString(id))
          : mongo.where.eq('userId', id);
      final result = await _usersCollection!.updateOne(
        selector,
        mongo.modify
          ..set('name', name)
          ..set('username', username)
          ..set('birthday', birthday)
          ..set('password', password)
          ..set('profileImageUrl', profileImageUrl ?? '')
          ..set('coverImageUrl', coverImageUrl ?? ''),
      );
      await closeDb();
      return result.isSuccess;
    } catch (e) {
      rethrow;
    }
  }

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
