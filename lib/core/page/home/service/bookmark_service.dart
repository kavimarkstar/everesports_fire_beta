import 'package:mongo_dart/mongo_dart.dart';
import 'package:everesports/database/config/config.dart';

class BookmarkService {
  static Db? _db;
  static DbCollection? _bookmarkCollection;

  static Future<void> _initializeDatabase() async {
    if (_db == null) {
      _db = await Db.create(configDatabase);
      await _db!.open();
      _bookmarkCollection = _db!.collection('bookmark');
    }
  }

  static Future<void> addBookmark(
    String userId,
    String postId,
    String albumId,
  ) async {
    await _initializeDatabase();
    await _bookmarkCollection!.insertOne({
      'userId': userId,
      'postId': postId,
      'albumId': albumId,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> removeBookmark(
    String userId,
    String postId,
    String albumId,
  ) async {
    await _initializeDatabase();
    await _bookmarkCollection!.deleteOne({
      'userId': userId,
      'postId': postId,
      'albumId': albumId,
    });
  }

  static Future<bool> isBookmarked(
    String userId,
    String postId,
    String albumId,
  ) async {
    await _initializeDatabase();
    final doc = await _bookmarkCollection!.findOne({
      'userId': userId,
      'postId': postId,
      'albumId': albumId,
    });
    return doc != null;
  }

  static Future<int> getBookmarkCount(String postId) async {
    await _initializeDatabase();
    return await _bookmarkCollection!.count({'postId': postId});
  }

  static Future<List<String>> getBookmarkedPostIdsByUser(
    String userId,
    String albumId,
  ) async {
    await _initializeDatabase();
    final bookmarks = await _bookmarkCollection!.find({
      'userId': userId,
      'albumId': albumId,
    }).toList();
    return bookmarks.map((b) => b['postId'] as String).toList();
  }
}
