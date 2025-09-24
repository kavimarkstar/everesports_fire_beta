import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:everesports/core/page/esports/model/tournament.dart';

class SearchService {
  /// Search tournaments in Firestore by query (case-insensitive, multiple fields)
  static Future<List<Tournament>> searchTournaments(String query) async {
    try {
      final collection = FirebaseFirestore.instance.collection('Tournament');
      Query<Map<String, dynamic>> q = collection;

      // If query is empty or "all", return all tournaments
      if (query.isEmpty || query.toLowerCase() == 'all') {
        final snapshot = await q.get();
        return snapshot.docs
            .map((doc) => Tournament.fromMap(doc.data()))
            .toList();
      }

      // Firestore doesn't support OR queries across multiple fields directly.
      // So, we fetch all and filter in memory (for small datasets).
      final snapshot = await q.get();
      final lowerQuery = query.toLowerCase();

      final filtered = snapshot.docs
          .where((doc) {
            final data = doc.data();
            return (data['title']?.toString().toLowerCase().contains(
                      lowerQuery,
                    ) ??
                    false) ||
                (data['description']?.toString().toLowerCase().contains(
                      lowerQuery,
                    ) ??
                    false) ||
                (data['gameName']?.toString().toLowerCase().contains(
                      lowerQuery,
                    ) ??
                    false) ||
                (data['selectedWeapons']?.toString().toLowerCase().contains(
                      lowerQuery,
                    ) ??
                    false) ||
                (data['selectedMap']?.toString().toLowerCase().contains(
                      lowerQuery,
                    ) ??
                    false);
          })
          .map((doc) => Tournament.fromMap(doc.data()))
          .toList();

      return filtered;
    } catch (e) {
      print('Error searching tournaments: $e');
      return [];
    }
  }

  /// Search users in Firestore by query (case-insensitive, multiple fields)
  static Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final collection = FirebaseFirestore.instance.collection('users');
      Query<Map<String, dynamic>> q = collection;

      // If query is empty or "all", return all users
      if (query.isEmpty || query.toLowerCase() == 'all') {
        final snapshot = await q.get();
        return snapshot.docs.map((doc) => doc.data()).toList();
      }

      // Firestore doesn't support OR queries across multiple fields directly.
      // So, we fetch all and filter in memory (for small datasets).
      final snapshot = await q.get();
      final lowerQuery = query.toLowerCase();

      final filtered = snapshot.docs
          .where((doc) {
            final data = doc.data();
            return (data['username']?.toString().toLowerCase().contains(
                      lowerQuery,
                    ) ??
                    false) ||
                (data['userId']?.toString().toLowerCase().contains(
                      lowerQuery,
                    ) ??
                    false) ||
                (data['name']?.toString().toLowerCase().contains(lowerQuery) ??
                    false) ||
                (data['email']?.toString().toLowerCase().contains(lowerQuery) ??
                    false);
          })
          .map((doc) => doc.data())
          .toList();

      return filtered;
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  /// Search both tournaments and users
  static Future<Map<String, dynamic>> searchAll(String query) async {
    final tournaments = await searchTournaments(query);
    final users = await searchUsers(query);

    return {'tournaments': tournaments, 'users': users};
  }

  /// Search suggestions in Firestore (collection: 'search')
  static Future<List<String>> searchSuggestions(String query) async {
    try {
      final collection = FirebaseFirestore.instance.collection('search');
      final lowerQuery = query.toLowerCase();

      // Search for matching terms (case-insensitive)
      final snapshot = await collection.get();
      final suggestionsRaw = snapshot.docs
          .where(
            (doc) =>
                (doc['term']?.toString().toLowerCase().contains(lowerQuery) ??
                false),
          )
          .toList();

      // If no match, insert the query as a new suggestion
      if (suggestionsRaw.isEmpty && query.isNotEmpty) {
        await collection.add({'term': query});
      }

      // Fetch all suggestions matching the query (including the new one if inserted)
      final updatedSnapshot = await collection.get();
      final updatedSuggestionsRaw = updatedSnapshot.docs
          .where(
            (doc) =>
                (doc['term']?.toString().toLowerCase().contains(lowerQuery) ??
                false),
          )
          .toList();

      // Return the list of terms as strings
      return updatedSuggestionsRaw
          .map((e) => e['term']?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    } catch (e) {
      print('Error searching/inserting suggestions: $e');
      return [];
    }
  }
}
