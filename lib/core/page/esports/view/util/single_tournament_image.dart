import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:everesports/Theme/colors.dart';
import 'package:everesports/core/page/esports/model/tournament.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SingalTournamentImage extends StatelessWidget {
  final Tournament item;
  const SingalTournamentImage({super.key, required this.item});

  Uint8List? _decodeImageData(String? dataField) {
    if (dataField == null || dataField.isEmpty) return null;
    try {
      // Heuristic: Check if the string consists only of 0s and 1s.
      if (RegExp(r'^[01]+$').hasMatch(dataField)) {
        // It's a binary string, parse it.
        return _binaryStringToBytes(dataField);
      } else {
        // Assume it's Base64 and decode it.
        return base64Decode(dataField);
      }
    } catch (e) {
      return null;
    }
  }

  static Uint8List _binaryStringToBytes(String binary) {
    final length = (binary.length / 8).ceil();
    final bytes = Uint8List(length);
    for (int i = 0; i < length; i++) {
      final start = i * 8;
      final end = (i + 1) * 8;
      final byteStr = binary.substring(
        start,
        end > binary.length ? binary.length : end,
      );
      bytes[i] = int.parse(byteStr.padLeft(8, '0'), radix: 2);
    }
    return bytes;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: double.infinity,
      height: 275,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              bottomLeft: const Radius.circular(20),
              bottomRight: const Radius.circular(20),
              topLeft:
                  !kIsWeb &&
                      (Platform.isWindows ||
                          Platform.isMacOS ||
                          Platform.isLinux)
                  ? Radius.circular(20)
                  : Radius.circular(0),
              topRight:
                  !kIsWeb &&
                      (Platform.isWindows ||
                          Platform.isMacOS ||
                          Platform.isLinux)
                  ? Radius.circular(20)
                  : Radius.circular(0),
            ),
            child: item.imageThumb.isNotEmpty
                ? FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('thumbnail')
                        .doc(item.imageThumb)
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting ||
                          !snapshot.hasData) {
                        return Container(color: Colors.grey[300]);
                      }
                      final thumbData =
                          snapshot.data!.data() as Map<String, dynamic>?;
                      final dynamic dataField = thumbData?['data'];
                      final bytes = _decodeImageData(
                        dataField is String ? dataField : null,
                      );
                      if (bytes != null) {
                        return Image.memory(
                          bytes,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.red,
                                size: 40,
                              ),
                            );
                          },
                        );
                      } else {
                        return Container(color: Colors.grey[300]);
                      }
                    },
                  )
                : Container(color: Colors.grey[300]),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  (isDarkMode ? mainBlackColor : mainWhiteColor).withOpacity(
                    0.95,
                  ),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
