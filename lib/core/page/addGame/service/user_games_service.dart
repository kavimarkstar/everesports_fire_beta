import 'package:cloud_firestore/cloud_firestore.dart';

class UserGamesService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch all games for a user
  static Future<List<Map<String, dynamic>>> fetchUserGames(
    String userId,
  ) async {
    final query = await _firestore
        .collection('users_games')
        .where('user_id', isEqualTo: userId)
        .get();

    return query.docs.map((doc) {
      final data = doc.data();
      data['_id'] = doc.id;
      return data;
    }).toList();
  }

  /// Add a game for a user
  static Future<void> addUserGame(
    String userId,
    Map<String, dynamic> gameData,
  ) async {
    await _firestore.collection('users_games').add({
      ...gameData,
      'user_id': userId,
    });
  }

  /// Edit a user's game UID, ensuring uniqueness for that game
  static Future<String?> editUserGameUID(
    Map<String, dynamic> game,
    String newUID,
  ) async {
    final gameId = game['game_id'];
    final userGameId = game['_id'];

    // Check if new UID is already used for this game by any user (excluding this record)
    final existingUID = await _firestore
        .collection('users_games')
        .where('game_id', isEqualTo: gameId)
        .where('game_uid', isEqualTo: newUID)
        .get();

    final alreadyUsed = existingUID.docs.any((doc) => doc.id != userGameId);

    if (alreadyUsed) {
      return 'This UID is already used for this game.';
    }

    await _firestore.collection('users_games').doc(userGameId).update({
      'game_uid': newUID,
    });
    return null;
  }

  /// Delete a user's game
  static Future<void> deleteUserGame(Map<String, dynamic> game) async {
    final userGameId = game['_id'];
    await _firestore.collection('users_games').doc(userGameId).delete();
  }

  /// Fetch game names for a list of user games
  static Future<Map<String, String>> fetchGameNamesForUserGames(
    List<Map<String, dynamic>> userGames,
  ) async {
    final ids = userGames
        .map(
          (g) => g['game_id'] is Map && g['game_id'].containsKey('oid')
              ? g['game_id']['oid']
              : g['game_id'],
        )
        .toSet()
        .where((id) => id != null)
        .toList();

    if (ids.isEmpty) return {};

    final query = await _firestore
        .collection('game_name')
        .where(FieldPath.documentId, whereIn: ids)
        .get();

    final Map<String, String> idToName = {};
    for (final doc in query.docs) {
      idToName[doc.id] = doc.data()['name'] ?? '';
    }
    return idToName;
  }

  /// Fetch a game by its ID
  static Future<Map<String, dynamic>?> fetchGameById(dynamic gameId) async {
    String id;
    if (gameId is Map && gameId.containsKey('oid')) {
      id = gameId['oid'];
    } else {
      id = gameId.toString();
    }
    final doc = await _firestore.collection('game_name').doc(id).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    data['_id'] = doc.id;
    return data;
  }
}
