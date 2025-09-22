import 'package:mongo_dart/mongo_dart.dart';
import 'package:everesports/database/config/config.dart';
import 'package:everesports/core/page/home/model/post.dart';

class PostService {
  static Db? _db;
  static DbCollection? _postsCollection;

  static Future<void> _initializeDatabase() async {
    if (_db == null) {
      try {
        _db = await Db.create(configDatabase);
        await _db!.open();
        _postsCollection = _db!.collection('posts');
      } catch (e) {
        print('Error connecting to database: $e');
        rethrow;
      }
    }
  }

  static Future<List<Post>> getAllPosts() async {
    try {
      print('Initializing database...');
      await _initializeDatabase();
      print('Database initialized successfully');

      print('Fetching posts from collection...');
      final cursor = await _postsCollection!.find(
        where.sortBy('createdAt', descending: true),
      );

      final List<Post> posts = [];
      await for (final document in cursor) {
        print('Processing document: ${document['_id']}');
        posts.add(Post.fromMap(document));
      }

      print('Total posts fetched: ${posts.length}');
      return posts;
    } catch (e) {
      print('Error fetching posts: $e');
      return [];
    }
  }

  static Future<Post?> getPostById(String id) async {
    try {
      await _initializeDatabase();

      final document = await _postsCollection!.findOne(
        where.eq('_id', ObjectId.fromHexString(id)),
      );

      if (document != null) {
        return Post.fromMap(document);
      }
      return null;
    } catch (e) {
      print('Error fetching post by ID: $e');
      return null;
    }
  }

  static Future<List<Post>> getPostsByUserId(String userId) async {
    try {
      await _initializeDatabase();

      final cursor = await _postsCollection!.find(
        where.eq('userId', userId).sortBy('createdAt', descending: true),
      );

      final List<Post> posts = [];
      await for (final document in cursor) {
        posts.add(Post.fromMap(document));
      }

      return posts;
    } catch (e) {
      print('Error fetching posts by user ID: $e');
      return [];
    }
  }

  static Future<void> closeDatabase() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
      _postsCollection = null;
    }
  }

  static Future<void> incrementShareCount(String postId) async {
    await _initializeDatabase();
    await _postsCollection!.updateOne(
      where.eq('_id', ObjectId.fromHexString(postId)),
      {
        'inc': {'shareCount': 1},
      },
    );
  }

  static Future<void> addSharedUserId(String postId, String userId) async {
    await _initializeDatabase();
    await _postsCollection!.updateOne(
      where.eq('_id', ObjectId.fromHexString(postId)),
      {
        'addToSet': {'sharedUserIds': userId},
      },
    );
  }
}
