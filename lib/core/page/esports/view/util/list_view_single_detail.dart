import 'package:everesports/Theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:everesports/core/page/esports/model/tournament.dart';

Widget buildListViewSingleDetail(
  BuildContext context,
  Tournament tournament,
  VoidCallback onPressed,
  VoidCallback onTap,
) {
  return buildCard(
    context,
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Tournament Details",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: onPressed,
                    icon: AnimatedRotation(
                      turns: 0.5,
                      duration: Duration(milliseconds: 300),
                      child: Icon(Icons.arrow_drop_up),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (tournament.gameName != 'Null' &&
              tournament.gameName != 'null' &&
              tournament.gameName != '')
            buildDetail(context, "Game Name", tournament.gameName),
          if (tournament.gameMode != 'Null' &&
              tournament.gameMode != 'null' &&
              tournament.gameMode != '')
            buildDetail(context, "Game Mode", tournament.gameMode),
          if (tournament.subGameMode != 'Null' &&
              tournament.subGameMode != 'null' &&
              tournament.subGameMode != '')
            buildDetail(context, "Sub Game Mode", tournament.subGameMode),
          if (tournament.round != null &&
              tournament.round != 'Null' &&
              tournament.round != 'null' &&
              tournament.round != '')
            buildDetail(context, "Round", tournament.round ?? 'N/A'),

          if (tournament.minimumLevel != 'Null' &&
              tournament.minimumLevel != 'null' &&
              tournament.minimumLevel != '')
            buildDetail(context, "Minimum Level", tournament.minimumLevel),
          if (tournament.player != 'Null' &&
              tournament.player != 'null' &&
              tournament.player != '')
            buildDetail(context, "Player", tournament.player),
          if (tournament.teamMode != 'Null' &&
              tournament.teamMode != 'null' &&
              tournament.teamMode != '')
            buildDetail(context, "Team Mode", tournament.teamMode),
          if (tournament.defaltCoin != null &&
              tournament.defaltCoin != 'Null' &&
              tournament.defaltCoin != 'null' &&
              tournament.defaltCoin != '')
            buildDetail(
              context,
              "Default Coin",
              tournament.defaltCoin ?? 'N/A',
            ),
          if (tournament.specialMode != 'Null' &&
              tournament.specialMode != 'null' &&
              tournament.specialMode != '')
            buildDetail(context, "Special Mode", tournament.specialMode),
          if (tournament.specialAirdrop != 'Null' &&
              tournament.specialAirdrop != 'null' &&
              tournament.specialAirdrop != '')
            buildDetail(context, "Special Airdrop", tournament.specialAirdrop),
          if (tournament.aridrop != 'Null' &&
              tournament.aridrop != 'null' &&
              tournament.aridrop != '')
            buildDetail(context, "Aridrop", tournament.aridrop),
          if (tournament.hpHelth != 'Null' &&
              tournament.hpHelth != 'null' &&
              tournament.hpHelth != '')
            buildDetail(context, "HP Health", tournament.hpHelth),
          if (tournament.movementSpeed != 'Null' &&
              tournament.movementSpeed != 'null' &&
              tournament.movementSpeed != '')
            buildDetail(context, "Movement Speed", tournament.movementSpeed),
          if (tournament.jumpHeight != 'Null' &&
              tournament.jumpHeight != 'null' &&
              tournament.jumpHeight != '')
            buildDetail(context, "Jump Height", tournament.jumpHeight),
          if (tournament.ammoLimit != 'Null' &&
              tournament.ammoLimit != 'null' &&
              tournament.ammoLimit != '')
            buildDetail(context, "Ammo Limit", tournament.ammoLimit),
          if (tournament.friendlyFire != 'Null' &&
              tournament.friendlyFire != 'null' &&
              tournament.friendlyFire != '')
            buildDetail(context, "Friendly Fire", tournament.friendlyFire),
          if (tournament.characterSkill != 'Null' &&
              tournament.characterSkill != 'null' &&
              tournament.characterSkill != '')
            buildDetail(context, "Character Skill", tournament.characterSkill),
          if (tournament.preciseAim != 'Null' &&
              tournament.preciseAim != 'null' &&
              tournament.preciseAim != '')
            buildDetail(context, "Precise Aim", tournament.preciseAim),
          if (tournament.loadout != 'Null' &&
              tournament.loadout != 'null' &&
              tournament.loadout != '')
            buildDetail(context, "Loadout", tournament.loadout),
          if (tournament.headshot != 'Null' &&
              tournament.headshot != 'null' &&
              tournament.headshot != '')
            buildDetail(context, "Headshot", tournament.headshot),
          if (tournament.environment != 'Null' &&
              tournament.environment != 'null' &&
              tournament.environment != '')
            buildDetail(context, "Environment", tournament.environment),
          if (tournament.safeZoneMoving != 'Null' &&
              tournament.safeZoneMoving != 'null' &&
              tournament.safeZoneMoving != '')
            buildDetail(context, "Safe Zone Moving", tournament.safeZoneMoving),
          if (tournament.highTierLootZone != 'Null' &&
              tournament.highTierLootZone != 'null' &&
              tournament.highTierLootZone != '')
            buildDetail(
              context,
              "High Tier Loot Zone",
              tournament.highTierLootZone,
            ),
          if (tournament.vehicle != 'Null' &&
              tournament.vehicle != 'null' &&
              tournament.vehicle != '')
            buildDetail(context, "Vehicle", tournament.vehicle),
          if (tournament.autoRevival != 'Null' &&
              tournament.autoRevival != 'null' &&
              tournament.autoRevival != '')
            buildDetail(context, "Auto Revival", tournament.autoRevival),
          if (tournament.zoneShrinkSpeed != 'Null' &&
              tournament.zoneShrinkSpeed != 'null' &&
              tournament.zoneShrinkSpeed != '')
            buildDetail(
              context,
              "Zone Shrink Speed",
              tournament.zoneShrinkSpeed,
            ),
          if (tournament.outOfZoneDamage != 'Null' &&
              tournament.outOfZoneDamage != 'null' &&
              tournament.outOfZoneDamage != '')
            buildDetail(
              context,
              "Out of Zone Damage",
              tournament.outOfZoneDamage,
            ),
          if (tournament.supplyGadget != 'Null' &&
              tournament.supplyGadget != 'null' &&
              tournament.supplyGadget != '')
            buildDetail(context, "Supply Gadget", tournament.supplyGadget),
          if (tournament.deathSpectate != 'Null' &&
              tournament.deathSpectate != 'null' &&
              tournament.deathSpectate != '')
            buildDetail(context, "Death Spectate", tournament.deathSpectate),
          if (tournament.swichPosition != 'Null' &&
              tournament.swichPosition != 'null' &&
              tournament.swichPosition != '')
            buildDetail(context, "Swich Position", tournament.swichPosition),
          if (tournament.blockEmulator != 'Null' &&
              tournament.blockEmulator != 'null' &&
              tournament.blockEmulator != '')
            buildDetail(context, "Block Emulator", tournament.blockEmulator),

          if (tournament.selectedMap != 'Null' &&
              tournament.selectedMap != 'null' &&
              tournament.selectedMap != '')
            buildDetail(context, "Selected Map", tournament.selectedMap),
        ],
      ),
    ),
  );
}

buildCard(BuildContext context, Widget content) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
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
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          child: content,
        ),
      ),
    ),
  );
}

buildDetail(
  BuildContext context,
  String title,
  String detailValue, {
  int index = 0,
}) {
  return TweenAnimationBuilder<double>(
    duration: Duration(milliseconds: 300 + (index * 50)),
    tween: Tween(begin: 0.0, end: 1.0),
    builder: (context, animationValue, child) {
      return Transform.translate(
        offset: Offset(0, 20 * (1 - animationValue)),
        child: Opacity(
          opacity: animationValue,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 5,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "$title : ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? mainWhiteColor
                            : mainBlackColor,
                      ),
                    ),
                    Text(
                      detailValue,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? secondWhiteColor.withOpacity(0.8)
                            : secondBlackColor.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 5,
                ),
                child: Divider(),
              ),
            ],
          ),
        ),
      );
    },
  );
}
