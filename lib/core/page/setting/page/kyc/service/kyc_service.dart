import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:everesports/core/page/setting/page/kyc/model/kyc_request.dart';

class KycService {
  static const String _collectionName = 'kyc_requests';
  static const String _countriesCollectionName = 'countrys';

  /// Submit a KYC request to Firestore
  static Future<bool> submitKycRequest(KycRequest request) async {
    try {
      final collection = FirebaseFirestore.instance.collection(_collectionName);
      await collection.doc(request.userId).set(request.toMap());
      return true;
    } catch (e) {
      throw Exception('Failed to submit KYC request: $e');
    }
  }

  /// Get KYC request by user ID
  static Future<KycRequest?> getKycRequestByUserId(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(_collectionName)
          .doc(userId)
          .get();

      if (!doc.exists) return null;
      return KycRequest.fromMap(doc.data()!);
    } catch (e) {
      throw Exception('Failed to fetch KYC request: $e');
    }
  }

  /// Get all KYC requests with optional status filter
  static Future<List<KycRequest>> getKycRequests({String? status}) async {
    try {
      Query query = FirebaseFirestore.instance.collection(_collectionName);
      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }
      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => KycRequest.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
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
      final docRef = FirebaseFirestore.instance
          .collection(_collectionName)
          .doc(requestId);

      await docRef.update({
        'status': status.toString(),
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
      });

      return true;
    } catch (e) {
      throw Exception('Failed to update KYC status: $e');
    }
  }

  /// Convert image file to base64 string for database storage
  static Future<String> fileToBase64String(File file) async {
    try {
      final bytes = await file.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      throw Exception('Failed to convert file to base64: $e');
    }
  }

  /// Store image as base64 string in Firestore under user's KYC request
  static Future<bool> storeImageAsBase64InKycRequest({
    required String userId,
    required String fieldName,
    required File file,
  }) async {
    try {
      final base64String = await fileToBase64String(file);
      final docRef = FirebaseFirestore.instance
          .collection(_collectionName)
          .doc(userId);

      await docRef.set({fieldName: base64String}, SetOptions(merge: true));
      return true;
    } catch (e) {
      throw Exception('Failed to store image as base64: $e');
    }
  }

  /// Get list of countries from Firestore
  static Future<List<String>> getCountries() async {
    try {
      final collection = FirebaseFirestore.instance.collection(
        _countriesCollectionName,
      );
      final querySnapshot = await collection.get();

      final countries =
          querySnapshot.docs
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
      await FirebaseFirestore.instance
          .collection(_collectionName)
          .doc(requestId)
          .delete();
      return true;
    } catch (e) {
      throw Exception('Failed to delete KYC request: $e');
    }
  }
}
