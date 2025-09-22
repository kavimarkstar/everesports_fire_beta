import 'package:mongo_dart/mongo_dart.dart';
import 'package:everesports/database/config/config.dart';

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

    return PremiumPackage(
      id: map['_id'].toString(),
      title: map['title'] ?? map['name'] ?? 'Unknown Plan',
      price: formattedPrice,
      description: map['description'] ?? 'No description available',
      items: List<String>.from(map['items'] ?? []),
      duration: map['duration'] ?? 'monthly',
      isPopular: map['isPopular'] ?? false,
      createdAt: map['createdAt'] is DateTime
          ? map['createdAt']
          : DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] is DateTime
          ? map['updatedAt']
          : DateTime.parse(map['updatedAt']),
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
  static Future<List<PremiumPackage>> getPremiumPackages() async {
    try {
      final db = await Db.create(configDatabase);
      await db.open();

      final collection = db.collection('premium_packages');
      final cursor = await collection.find();

      List<PremiumPackage> packages = [];
      await for (final doc in cursor) {
        packages.add(PremiumPackage.fromMap(doc));
      }

      await db.close();

      // Sort by popularity and price
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
