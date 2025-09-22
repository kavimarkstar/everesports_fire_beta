import 'dart:io';

import 'package:everesports/Theme/colors.dart';
import 'package:everesports/core/page/esports/model/tournament.dart';
import 'package:everesports/database/config/config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SingalTournamentImage extends StatefulWidget {
  final Tournament item;
  const SingalTournamentImage({super.key, required this.item});

  @override
  State<SingalTournamentImage> createState() => _SingalTournamentImageState();
}

class _SingalTournamentImageState extends State<SingalTournamentImage> {
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
            child: widget.item.imageThumb.isNotEmpty
                ? Image.network(
                    "$fileServerBaseUrl${widget.item.imageThumb}",
                    fit: BoxFit.cover,
                    width: double.infinity,
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
