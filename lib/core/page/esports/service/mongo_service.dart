import 'package:everesports/database/config/config.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../model/tournament.dart';

class MongoEsportsService {
  static final _dbUrl = configDatabase;
  static const _collectionName = 'Tournament';

  static Future<List<Tournament>> getTournaments() async {
    try {
      final db = await Db.create(_dbUrl);
      await db.open();
      final collection = db.collection(_collectionName);
      final tournamentsRaw = await collection.find().toList();
      print('Fetched tournaments: ' + tournamentsRaw.toString());
      await db.close();
      return tournamentsRaw.map((e) => Tournament.fromMap(e)).toList();
    } catch (e) {
      print('Error fetching tournaments: ' + e.toString());
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getMaps() async {
    try {
      final db = await Db.create(_dbUrl);
      await db.open();
      final collection = db.collection('maps');
      final mapsRaw = await collection.find().toList();
      await db.close();
      return mapsRaw;
    } catch (e) {
      print('Error fetching maps: ' + e.toString());
      return [];
    }
  }

  // Fetch banners from the 'banners' collection
  static Future<List<Map<String, dynamic>>> getBanners() async {
    try {
      final db = await Db.create(_dbUrl);
      await db.open();
      final collection = db.collection('banners');
      final bannersRaw = await collection.find().toList();
      await db.close();
      return bannersRaw;
    } catch (e) {
      print('Error fetching banners: ' + e.toString());
      return [];
    }
  }

  Future<Map<String, dynamic>?> getWeaponById(String id) async {
    try {
      final db = await Db.create(_dbUrl);
      await db.open();
      var collection = db.collection('weapon');
      Map<String, dynamic>? weapon;
      try {
        weapon = await collection.findOne(where.eq('_id', ObjectId.parse(id)));
      } catch (e) {
        // Try as string
        weapon = await collection.findOne(where.eq('_id', id));
        // Try as {'_id': {'\$oid': id}}
        weapon ??= await collection.findOne(where.eq('_id', {'\$oid': id}));
      }
      await db.close();
      return weapon;
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
