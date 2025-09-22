import 'package:everesports/core/page/esports/model/tournament.dart';
import 'package:flutter/material.dart';

Widget buildPriceView(BuildContext context, Tournament tournament) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
    child: Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: isDark
          ? Colors.white.withOpacity(0.10)
          : Colors.black.withOpacity(0.07),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.13)
                : Colors.black.withOpacity(0.08),
            width: 1.3,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.18)
                  : Colors.grey.withOpacity(0.10),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              buildPriceViewItem(context, "Reward", tournament.rewardPrizeUSD),
              buildPriceViewItem(
                context,
                "Player Registration",
                tournament.playerFeeUSD,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

buildPriceViewItem(BuildContext context, String title, String price) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset("assets/icons/cristol.png", height: 22),
            SizedBox(width: 5),
            Text(
              price,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ],
    ),
  );
}
