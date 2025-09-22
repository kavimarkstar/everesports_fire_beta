import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:everesports/database/config/config.dart';

class UserGamesService {
  static Future<List<Map<String, dynamic>>> fetchUserGames(
    String userId,
  ) async {
    final db = await mongo.Db.create(configDatabase);
    await db.open();
    final coll = db.collection('users_games');
    final userGames = await coll.find({'user_id': userId}).toList();
    await db.close();
    return userGames;
  }

  static Future<void> addUserGame(
    String userId,
    Map<String, dynamic> gameData,
  ) async {
    final db = await mongo.Db.create(configDatabase);
    await db.open();
    final coll = db.collection('users_games');
    await coll.insertOne({...gameData, 'user_id': userId});
    await db.close();
  }

  static Future<String?> editUserGameUID(
    Map<String, dynamic> game,
    String newUID,
  ) async {
    final db = await mongo.Db.create(configDatabase);
    await db.open();
    final coll = db.collection('users_games');
    // Check if new UID is already used for this game by any user
    final existingUID = await coll.findOne({
      'game_id': game['game_id'],
      'game_uid': newUID,
      '_id': {'ne': game['_id']},
    });
    if (existingUID != null) {
      await db.close();
      return 'This UID is already used for this game.';
    }
    await coll.updateOne(
      {'_id': game['_id']},
      {
        'set': {'game_uid': newUID},
      },
    );
    await db.close();
    return null;
  }

  static Future<void> deleteUserGame(Map<String, dynamic> game) async {
    final db = await mongo.Db.create(configDatabase);
    await db.open();
    final coll = db.collection('users_games');
    await coll.deleteOne({'_id': game['_id']});
    await db.close();
  }

  static Future<Map<String, String>> fetchGameNamesForUserGames(
    List<Map<String, dynamic>> userGames,
  ) async {
    final db = await mongo.Db.create(configDatabase);
    await db.open();
    final gamesCollection = db.collection('game_name');
    final ids = userGames
        .map(
          (g) => g['game_id'] is Map && g['game_id'].containsKey('oid')
              ? mongo.ObjectId.fromHexString(g['game_id']['oid'])
              : g['game_id'],
        )
        .toList();
    final games = await gamesCollection.find({
      '_id': {'in': ids},
    }).toList();
    await db.close();
    final Map<String, String> idToName = {};
    for (final g in games) {
      final id = g['_id'] is mongo.ObjectId
          ? g['_id'].toHexString()
          : g['_id'].toString();
      idToName[id] = g['name'] ?? '';
    }
    return idToName;
  }

  static Future<Map<String, dynamic>?> fetchGameById(dynamic gameId) async {
    final db = await mongo.Db.create(configDatabase);
    await db.open();
    final gamesCollection = db.collection('game_name');
    final id = gameId is Map && gameId.containsKey('oid')
        ? mongo.ObjectId.fromHexString(gameId['oid'])
        : gameId;
    final game = await gamesCollection.findOne({'_id': id});
    await db.close();
    return game;
  }
}
