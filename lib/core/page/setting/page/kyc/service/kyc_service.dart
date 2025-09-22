import 'dart:convert';
import 'dart:io';

import 'package:everesports/core/page/setting/page/kyc/model/kyc_request.dart';
import 'package:everesports/database/config/config.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class KycService {
  static const String _collectionName = 'kyc_requests';
  static const String _countriesCollectionName = 'countrys';

  /// Submit a KYC request to the database
  static Future<bool> submitKycRequest(KycRequest request) async {
    try {
      final db = await mongo.Db.create(configDatabase);
      await db.open();
      final collection = db.collection(_collectionName);

      await collection.insertOne(request.toMap());
      await db.close();
      return true;
    } catch (e) {
      throw Exception('Failed to submit KYC request: $e');
    }
  }

  /// Get KYC request by user ID
  static Future<KycRequest?> getKycRequestByUserId(String userId) async {
    try {
      final db = await mongo.Db.create(configDatabase);
      await db.open();
      final collection = db.collection(_collectionName);

      final doc = await collection.findOne({'userId': userId});
      await db.close();

      if (doc == null) return null;
      return KycRequest.fromMap(doc);
    } catch (e) {
      throw Exception('Failed to fetch KYC request: $e');
    }
  }

  /// Get all KYC requests with optional status filter
  static Future<List<KycRequest>> getKycRequests({String? status}) async {
    try {
      final db = await mongo.Db.create(configDatabase);
      await db.open();
      final collection = db.collection(_collectionName);

      final query = status != null ? {'status': status} : <String, dynamic>{};
      final docs = await collection.find(query).toList();
      await db.close();

      return docs.map((doc) => KycRequest.fromMap(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch KYC requests: $e');
    }
  }

  /// Update KYC request status
  static Future<bool> updateKycStatus(
    String requestId,
    KycStatus status,
  ) async {
    try {
      final db = await mongo.Db.create(configDatabase);
      await db.open();
      final collection = db.collection(_collectionName);

      final result = await collection.updateOne(
        {'_id': mongo.ObjectId.fromHexString(requestId)},
        {
          r'$set': {
            'status': status.toString(),
            'updatedAt': DateTime.now().toUtc().toIso8601String(),
          },
        },
      );

      await db.close();
      return result.isSuccess;
    } catch (e) {
      throw Exception('Failed to update KYC status: $e');
    }
  }

  /// Upload a file to the server
  static Future<String> uploadFile(File file, String userId) async {
    try {
      final uri = Uri.parse('$fileServerBaseUrl/upload-kyc');
      final request = http.MultipartRequest('POST', uri);

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          contentType: MediaType('application', 'octet-stream'),
        ),
      );
      request.fields['userId'] = userId;

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final decoded = jsonDecode(body);
        final filePath = decoded['filePath'] as String?;
        if (filePath != null) return filePath;
      }

      throw Exception('File upload failed (${response.statusCode})');
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  /// Get list of countries from database
  static Future<List<String>> getCountries() async {
    try {
      final db = await mongo.Db.create(configDatabase);
      await db.open();
      final collection = db.collection(_countriesCollectionName);

      final docs = await collection.find().toList();
      await db.close();

      final countries =
          docs
              .map((e) => (e['name'] ?? e['country'] ?? '').toString().trim())
              .where((e) => e.isNotEmpty)
              .toSet()
              .toList()
            ..sort();

      return countries;
    } catch (e) {
      throw Exception('Failed to fetch countries: $e');
    }
  }

  /// Check if user has submitted KYC request
  static Future<bool> hasKycRequest(String userId) async {
    try {
      final request = await getKycRequestByUserId(userId);
      return request != null;
    } catch (e) {
      return false;
    }
  }

  /// Get KYC status for a user
  static Future<KycStatus?> getKycStatus(String userId) async {
    try {
      final request = await getKycRequestByUserId(userId);
      if (request == null) return null;
      return KycStatus.fromString(request.status);
    } catch (e) {
      return null;
    }
  }

  /// Delete KYC request (admin function)
  static Future<bool> deleteKycRequest(String requestId) async {
    try {
      final db = await mongo.Db.create(configDatabase);
      await db.open();
      final collection = db.collection(_collectionName);

      final result = await collection.deleteOne({
        '_id': mongo.ObjectId.fromHexString(requestId),
      });

      await db.close();
      return result.isSuccess;
    } catch (e) {
      throw Exception('Failed to delete KYC request: $e');
    }
  }
}
