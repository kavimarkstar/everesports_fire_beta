import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/tournament.dart';

class FirebaseEsportsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const _collectionName = 'Tournament';

  static Future<List<Tournament>> getTournaments() async {
    try {
      final querySnapshot = await _firestore.collection(_collectionName).get();
      final tournamentsRaw = querySnapshot.docs
          .map((doc) => doc.data())
          .toList();
      print('Fetched tournaments: $tournamentsRaw');
      return tournamentsRaw.map((e) => Tournament.fromMap(e)).toList();
    } catch (e) {
      print('Error fetching tournaments: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getMaps() async {
    try {
      final querySnapshot = await _firestore.collection('maps').get();
      final mapsRaw = querySnapshot.docs.map((doc) => doc.data()).toList();
      return List<Map<String, dynamic>>.from(mapsRaw);
    } catch (e) {
      print('Error fetching maps: $e');
      return [];
    }
  }

  // Fetch banners from the 'banners' collection
  static Future<List<Map<String, dynamic>>> getBanners() async {
    try {
      final querySnapshot = await _firestore.collection('banners').get();
      final bannersRaw = querySnapshot.docs.map((doc) => doc.data()).toList();
      return List<Map<String, dynamic>>.from(bannersRaw);
    } catch (e) {
      print('Error fetching banners: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getWeaponById(String id) async {
    try {
      final docSnapshot = await _firestore.collection('weapon').doc(id).get();
      if (docSnapshot.exists) {
        return docSnapshot.data();
      } else {
        print('Weapon not found for id: $id');
        return null;
      }
    } catch (e) {
      print('Error fetching weapon: $e');
      return null;
    }
  }

  // Add this if you specifically need to handle ObjectId strings
  Future<Map<String, dynamic>?> getWeaponByObjectIdString(
    String objectIdString,
  ) async {
    try {
      // Extract the ID from "ObjectId(...)" format
      final id = objectIdString
          .replaceAll('ObjectId("', '')
          .replaceAll('")', '');
      return await getWeaponById(id);
    } catch (e) {
      print('Error parsing weapon ID: $e');
      return null;
    }
  }
}
