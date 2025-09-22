import 'package:everesports/responsive/responsive.dart';
import 'package:flutter/material.dart';
import 'package:everesports/Theme/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:everesports/database/config/config.dart';

Widget topCardbuild(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
    child: Card(
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.white.withOpacity(0.1)
          : Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          width: 2,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.1),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SizedBox(
        height: 180, // Increased height to accommodate subscriber count
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Blue subscribers\nwith a verified KYC\nwill receive a blue checkmark\nonce approval.",
                      maxLines: 6,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: isMobile(context) ? 15 : 18,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Subscriber count display
                    FutureBuilder<int>(
                      future: _getSubscriberCount(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.grey,
                              ),
                            ),
                          );
                        }

                        final subscriberCount = snapshot.data ?? 0;
                        return Row(
                          children: [
                            Icon(Icons.people, color: mainColor, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              '${_formatCount(subscriberCount)} Active Subscribers',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: mainColor,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Image.asset(
                  "assets/icons/verfiy.png",
                  width: isMobile(context) ? 150 : 150,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// Helper function to get subscriber count from the server
Future<int> _getSubscriberCount() async {
  try {
    final response = await http.get(
      Uri.parse('$fileServerBaseUrl/api/subscriber-count'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['count'] ?? 0;
    }
  } catch (e) {
    print('Error fetching subscriber count: $e');
  }
  return 0;
}

// Helper function to format count numbers (removes decimal places)
String _formatCount(int count) {
  if (count >= 1000000000) {
    return '${(count / 1000000000).round()}B';
  } else if (count >= 1000000) {
    return '${(count / 1000000).round()}M';
  } else if (count >= 1000) {
    return '${(count / 1000).round()}K';
  } else {
    return count.toString();
  }
}
