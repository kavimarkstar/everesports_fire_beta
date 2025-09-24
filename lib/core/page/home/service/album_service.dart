import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:everesports/core/page/home/model/album.dart';

class AlbumService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _albumCollection = _firestore.collection(
    'album',
  );

  static Future<String> createAlbum(String userId, String name) async {
    final docRef = await _albumCollection.add({
      'userId': userId,
      'name': name,
      'createdAt': DateTime.now().toIso8601String(),
    });
    return docRef.id;
  }

  static Future<List<Album>> getAlbumsByUser(String userId) async {
    final querySnapshot = await _albumCollection
        .where('userId', isEqualTo: userId)
        .get();

    return querySnapshot.docs
        .map(
          (doc) => Album.fromMap({
            ...doc.data() as Map<String, dynamic>,
            'id': doc.id,
          }),
        )
        .toList();
  }
}
