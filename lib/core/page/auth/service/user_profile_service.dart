import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/user_profile.dart';

class UserProfileService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final String _usersCollection = 'users';
  static final String _followingCollection = 'following';
  static final String _likesCollection = 'likes';
  static final String _postsCollection = 'posts';

  // Get user profile by Firestore document ID
  static Future<UserProfile?> getUserProfileById(String docId) async {
    try {
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(docId)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        data['docId'] = doc.id;
        return UserProfile.fromMap(data);
      }
      return null;
    } catch (e) {
      print('Error fetching user profile by ID: $e');
      return null;
    }
  }

  // Get user data by Firestore document ID (alternative method)
  static Future<Map<String, dynamic>?> getUserDataByObjectId(
    String docId,
  ) async {
    try {
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(docId)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        data['docId'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      print('Error fetching user data by ObjectId: $e');
      return null;
    }
  }

  // Get user profile by userId (string)
  static Future<UserProfile?> getUserProfileByUserId(String userId) async {
    try {
      final query = await _firestore
          .collection(_usersCollection)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data();
        data['docId'] = query.docs.first.id;
        return UserProfile.fromMap(data);
      }
      return null;
    } catch (e) {
      print('Error fetching user profile by userId: $e');
      return null;
    }
  }

  // Get user profile by username
  static Future<UserProfile?> getUserProfileByUsername(String username) async {
    try {
      final query = await _firestore
          .collection(_usersCollection)
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data();
        data['docId'] = query.docs.first.id;
        return UserProfile.fromMap(data);
      }
      return null;
    } catch (e) {
      print('Error fetching user profile by username: $e');
      return null;
    }
  }

  // Get followers count
  static Future<int> getFollowersCount(String userId) async {
    try {
      final query = await _firestore
          .collection(_followingCollection)
          .where('followingId', isEqualTo: userId)
          .get();
      return query.size;
    } catch (e) {
      print('Error getting followers count: $e');
      return 0;
    }
  }

  // Get following count
  static Future<int> getFollowingCount(String userId) async {
    try {
      final query = await _firestore
          .collection(_followingCollection)
          .where('userId', isEqualTo: userId)
          .get();
      return query.size;
    } catch (e) {
      print('Error getting following count: $e');
      return 0;
    }
  }

  // Get likes count (total likes received by user)
  static Future<int> getLikesCount(String userId) async {
    try {
      // Get all posts by user
      final postsQuery = await _firestore
          .collection(_postsCollection)
          .where('userId', isEqualTo: userId)
          .get();

      int totalLikes = 0;
      for (final post in postsQuery.docs) {
        final postId = post.id;
        final likesQuery = await _firestore
            .collection(_likesCollection)
            .where('postId', isEqualTo: postId)
            .get();
        totalLikes += likesQuery.size;
      }
      return totalLikes;
    } catch (e) {
      print('Error getting likes count: $e');
      return 0;
    }
  }

  // Update user profile
  static Future<bool> updateUserProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      // Find the user document by userId
      final query = await _firestore
          .collection(_usersCollection)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        print('User not found for update');
        return false;
      }

      final docId = query.docs.first.id;
      await _firestore.collection(_usersCollection).doc(docId).update(updates);
      return true;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  // Search users by username or name
  static Future<List<UserProfile>> searchUsers(String query) async {
    try {
      // Search by username (exact match)
      final usernameQuery = await _firestore
          .collection(_usersCollection)
          .where('username', isEqualTo: query)
          .get();

      // Optionally, also search by name (exact match)
      final nameQuery = await _firestore
          .collection(_usersCollection)
          .where('name', isEqualTo: query)
          .get();

      final users = [
        ...usernameQuery.docs,
        ...nameQuery.docs.where(
          (doc) => !usernameQuery.docs.any((u) => u.id == doc.id),
        ), // avoid duplicates
      ];

      return users.map((doc) {
        final data = doc.data();
        data['docId'] = doc.id;
        return UserProfile.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  // Get all users (with pagination)
  static Future<List<UserProfile>> getAllUsers({
    int limit = 20,
    int skip = 0,
  }) async {
    try {
      final query = await _firestore
          .collection(_usersCollection)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      // Firestore does not support skip/offset directly, so we slice manually
      final docs = query.docs.skip(skip).take(limit);

      return docs.map((doc) {
        final data = doc.data();
        data['docId'] = doc.id;
        return UserProfile.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error getting all users: $e');
      return [];
    }
  }

  // No-op for Firestore, but kept for compatibility
  static Future<void> close() async {
    // No connection to close in Firestore
  }
}
