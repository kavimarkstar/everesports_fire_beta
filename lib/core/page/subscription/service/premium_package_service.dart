import 'package:cloud_firestore/cloud_firestore.dart';

class PremiumPackage {
  final String id;
  final String title;
  final String price;
  final String description;
  final List<String> items;
  final String duration;
  final bool isPopular;
  final DateTime createdAt;
  final DateTime updatedAt;

  PremiumPackage({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.items,
    required this.duration,
    required this.isPopular,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PremiumPackage.fromMap(Map<String, dynamic> map) {
    // Handle price formatting to remove decimal places
    String formattedPrice = 'Free';
    if (map['price'] != null) {
      if (map['price'] is num) {
        // If price is a number, convert to integer string to remove decimals
        formattedPrice = map['price'].toInt().toString();
      } else {
        // If price is already a string, use it as is
        formattedPrice = map['price'].toString();
      }
    }

    // Firestore document id can be in 'id' or 'doc.id'
    String id = map['id']?.toString() ?? map['_id']?.toString() ?? '';

    // Firestore Timestamps
    DateTime createdAt;
    DateTime updatedAt;
    if (map['createdAt'] is Timestamp) {
      createdAt = (map['createdAt'] as Timestamp).toDate();
    } else if (map['createdAt'] is DateTime) {
      createdAt = map['createdAt'];
    } else if (map['createdAt'] is String) {
      createdAt = DateTime.tryParse(map['createdAt']) ?? DateTime.now();
    } else {
      createdAt = DateTime.now();
    }
    if (map['updatedAt'] is Timestamp) {
      updatedAt = (map['updatedAt'] as Timestamp).toDate();
    } else if (map['updatedAt'] is DateTime) {
      updatedAt = map['updatedAt'];
    } else if (map['updatedAt'] is String) {
      updatedAt = DateTime.tryParse(map['updatedAt']) ?? DateTime.now();
    } else {
      updatedAt = DateTime.now();
    }

    return PremiumPackage(
      id: id,
      title: map['title'] ?? map['name'] ?? 'Unknown Plan',
      price: formattedPrice,
      description: map['description'] ?? 'No description available',
      items: List<String>.from(map['items'] ?? []),
      duration: map['duration'] ?? 'monthly',
      isPopular: map['isPopular'] ?? false,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'description': description,
      'items': items,
      'duration': duration,
      'isPopular': isPopular,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class PremiumPackageService {
  static const String _collectionName = 'premium_packages';

  static Future<List<PremiumPackage>> getPremiumPackages() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection(_collectionName)
          .get();

      List<PremiumPackage> packages = querySnapshot.docs.map((doc) {
        final data = doc.data();
        // Attach Firestore doc id if not present in data
        if (!data.containsKey('id')) {
          data['id'] = doc.id;
        }
        return PremiumPackage.fromMap(data);
      }).toList();

      // Sort by popularity and title
      packages.sort((a, b) {
        if (a.isPopular && !b.isPopular) return -1;
        if (!a.isPopular && b.isPopular) return 1;
        return a.title.compareTo(b.title);
      });

      return packages;
    } catch (e) {
      print('Error fetching premium packages: $e');
      // Return default packages if database fails
      return _getDefaultPackages();
    }
  }

  static List<PremiumPackage> _getDefaultPackages() {
    return [
      PremiumPackage(
        id: 'default_basic',
        title: 'Basic',
        price: '\$4.99/mo',
        description: 'Essential features for everyone',
        items: ['Ad-free experience', 'Basic support', 'Standard quality'],
        duration: 'monthly',
        isPopular: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      PremiumPackage(
        id: 'default_standard',
        title: 'Standard',
        price: '\$9.99/mo',
        description: 'Enhanced features for power users',
        items: [
          'Ad-free experience',
          'Priority support',
          'HD quality',
          'Download content',
        ],
        duration: 'monthly',
        isPopular: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      PremiumPackage(
        id: 'default_premium',
        title: 'Premium',
        price: '\$14.99/mo',
        description: 'Professional features for creators',
        items: [
          'Ad-free experience',
          '24/7 support',
          '4K quality',
          'Download content',
          'Exclusive content',
        ],
        duration: 'monthly',
        isPopular: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      PremiumPackage(
        id: 'default_ultimate',
        title: 'Ultimate',
        price: '\$19.99/mo',
        description: 'Ultimate features for power users',
        items: [
          'Ad-free experience',
          '24/7 support',
          '4K quality',
          'Download content',
          'Exclusive content',
          'Early access',
          'Custom themes',
        ],
        duration: 'monthly',
        isPopular: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }
}
