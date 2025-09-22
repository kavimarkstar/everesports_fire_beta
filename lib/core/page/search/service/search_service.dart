import 'package:mongo_dart/mongo_dart.dart';
import 'package:everesports/database/config/config.dart';
import 'package:everesports/core/page/esports/model/tournament.dart';

class SearchService {
  static Future<List<Tournament>> searchTournaments(String query) async {
    try {
      final db = await Db.create(configDatabase);
      await db.open();
      final collection = db.collection('Tournament');

      // If query is empty or "all", return all tournaments
      if (query.isEmpty || query.toLowerCase() == 'all') {
        final tournamentsRaw = await collection.find({}).toList();
        await db.close();
        return tournamentsRaw.map((e) => Tournament.fromMap(e)).toList();
      }

      // Search in multiple fields for better matching
      final tournamentsRaw = await collection.find({
        '\$or': [
          {
            'title': {'\$regex': query, '\$options': 'i'},
          },
          {
            'description': {'\$regex': query, '\$options': 'i'},
          },
          {
            'gameName': {'\$regex': query, '\$options': 'i'},
          },
          {
            'selectedWeapons': {'\$regex': query, '\$options': 'i'},
          },
          {
            'selectedMap': {'\$regex': query, '\$options': 'i'},
          },
        ],
      }).toList();

      await db.close();
      return tournamentsRaw.map((e) => Tournament.fromMap(e)).toList();
    } catch (e) {
      print('Error searching tournaments: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final db = await Db.create(configDatabase);
      await db.open();
      final collection = db.collection('users');

      // If query is empty or "all", return all users
      if (query.isEmpty || query.toLowerCase() == 'all') {
        final usersRaw = await collection.find({}).toList();
        await db.close();
        return usersRaw;
      }

      // Search in multiple fields for better matching
      final usersRaw = await collection.find({
        '\$or': [
          {
            'username': {'\$regex': query, '\$options': 'i'},
          },
          {
            'userId': {'\$regex': query, '\$options': 'i'},
          },
          {
            'name': {'\$regex': query, '\$options': 'i'},
          },
          {
            'email': {'\$regex': query, '\$options': 'i'},
          },
        ],
      }).toList();

      await db.close();
      return usersRaw;
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> searchAll(String query) async {
    final tournaments = await searchTournaments(query);
    final users = await searchUsers(query);

    return {'tournaments': tournaments, 'users': users};
  }

  static Future<List<String>> searchSuggestions(String query) async {
    try {
      final db = await Db.create(configDatabase);
      await db.open();
      final collection = db.collection('search');

      // Search for matching terms (case-insensitive)
      final suggestionsRaw = await collection.find({
        'term': {'\$regex': query, '\$options': 'i'},
      }).toList();

      // If no match, insert the query as a new suggestion
      if (suggestionsRaw.isEmpty && query.isNotEmpty) {
        await collection.insert({'term': query});
      }

      // Fetch all suggestions matching the query (including the new one if inserted)
      final updatedSuggestionsRaw = await collection.find({
        'term': {'\$regex': query, '\$options': 'i'},
      }).toList();

      await db.close();
      // Return the list of terms as strings
      return updatedSuggestionsRaw.map((e) => e['term'] as String).toList();
    } catch (e) {
      print('Error searching/inserting suggestions: $e');
      return [];
    }
  }
}
