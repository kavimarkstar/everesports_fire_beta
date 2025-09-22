import 'package:mongo_dart/mongo_dart.dart';
import 'package:everesports/database/config/config.dart';
import 'package:everesports/core/page/home/model/album.dart';

class AlbumService {
  static Db? _db;
  static DbCollection? _albumCollection;

  static Future<void> _initializeDatabase() async {
    if (_db == null) {
      _db = await Db.create(configDatabase);
      await _db!.open();
      _albumCollection = _db!.collection('album');
    }
  }

  static Future<String> createAlbum(String userId, String name) async {
    await _initializeDatabase();
    final result = await _albumCollection!.insertOne({
      'userId': userId,
      'name': name,
      'createdAt': DateTime.now().toIso8601String(),
    });
    return result.id.toString();
  }

  static Future<List<Album>> getAlbumsByUser(String userId) async {
    await _initializeDatabase();
    final albums = await _albumCollection!.find({'userId': userId}).toList();
    return albums.map((a) => Album.fromMap(a)).toList();
  }
}
