class Tournament {
  final String id;
  final String tournamentId;
  final String title;
  final String description;
  final String imageThumb;
  final String gameName;
  final String gameMode;
  final String subGameMode;
  final String? round;
  final String minimumLevel;
  final String player;
  final String teamMode;
  final String? defaltCoin;
  final String specialMode;
  final String specialAirdrop;
  final String aridrop;
  final String hpHelth;
  final String movementSpeed;
  final String jumpHeight;
  final String ammoLimit;
  final String friendlyFire;
  final String characterSkill;
  final String preciseAim;
  final String loadout;
  final String headshot;
  final String environment;
  final String safeZoneMoving;
  final String highTierLootZone;
  final String vehicle;
  final String autoRevival;
  final String zoneShrinkSpeed;
  final String outOfZoneDamage;
  final String supplyGadget;
  final String deathSpectate;
  final String swichPosition;
  final String blockEmulator;
  final List<String> selectedWeapons;
  final String selectedMap;
  final String rewardPrizeUSD;
  final String playerFeeUSD;
  final String tournamentMode;
  final DateTime? createdAt;

  Tournament({
    required this.id,
    required this.tournamentId,
    required this.title,
    required this.description,
    required this.imageThumb,
    required this.gameName,
    required this.gameMode,
    required this.subGameMode,
    this.round,
    required this.minimumLevel,
    required this.player,
    required this.teamMode,
    this.defaltCoin,
    required this.specialMode,
    required this.specialAirdrop,
    required this.aridrop,
    required this.hpHelth,
    required this.movementSpeed,
    required this.jumpHeight,
    required this.ammoLimit,
    required this.friendlyFire,
    required this.characterSkill,
    required this.preciseAim,
    required this.loadout,
    required this.headshot,
    required this.environment,
    required this.safeZoneMoving,
    required this.highTierLootZone,
    required this.vehicle,
    required this.autoRevival,
    required this.zoneShrinkSpeed,
    required this.outOfZoneDamage,
    required this.supplyGadget,
    required this.deathSpectate,
    required this.swichPosition,
    required this.blockEmulator,
    required this.selectedWeapons,
    required this.selectedMap,
    required this.rewardPrizeUSD,
    required this.playerFeeUSD,
    required this.tournamentMode,
    this.createdAt,
  });

  factory Tournament.fromMap(Map<String, dynamic> map) {
    String id = '';
    if (map['_id'] is Map && map['_id']['\$oid'] != null) {
      id = map['_id']['\$oid'];
    } else if (map['_id'] != null) {
      id = map['_id'].toString();
    }
    DateTime? createdAt;
    if (map['createdAt'] != null) {
      try {
        createdAt = DateTime.parse(map['createdAt']);
      } catch (_) {
        createdAt = null;
      }
    }

    List<String> selectedWeapons = [];
    if (map['selectedWeapons'] is List) {
      selectedWeapons = (map['selectedWeapons'] as List)
          .map((item) => item.toString())
          .toList();
    }

    return Tournament(
      id: id,
      tournamentId: map['TournamentId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageThumb: map['imageThumb'] ?? '',
      gameName: map['gameName'] ?? '',
      gameMode: map['gameMode'] ?? '',
      subGameMode: map['subGameMode'] ?? '',
      round: map['round'],
      minimumLevel: map['minimumLevel'] ?? '',
      player: map['player'] ?? '',
      teamMode: map['teamMode'] ?? '',
      defaltCoin: map['defaltCoin'],
      specialMode: map['specialMode'] ?? '',
      specialAirdrop: map['specialAirdrop'] ?? '',
      aridrop: map['aridrop'] ?? '',
      hpHelth: map['hpHelth'] ?? '',
      movementSpeed: map['movementSpeed'] ?? '',
      jumpHeight: map['jumpHeight'] ?? '',
      ammoLimit: map['ammoLimit'] ?? '',
      friendlyFire: map['friendlyFire'] ?? '',
      characterSkill: map['characterSkill'] ?? '',
      preciseAim: map['preciseAim'] ?? '',
      loadout: map['loadout'] ?? '',
      headshot: map['headshot'] ?? '',
      environment: map['environment'] ?? '',
      safeZoneMoving: map['safeZoneMoving'] ?? '',
      highTierLootZone: map['highTierLootZone'] ?? '',
      vehicle: map['vehicle'] ?? '',
      autoRevival: map['autoRevival'] ?? '',
      zoneShrinkSpeed: map['zoneShrinkSpeed'] ?? '',
      outOfZoneDamage: map['outOfZoneDamage'] ?? '',
      supplyGadget: map['supplyGadget'] ?? '',
      deathSpectate: map['deathSpectate'] ?? '',
      swichPosition: map['swichPosition'] ?? '',
      blockEmulator: map['blockEmulator'] ?? '',
      selectedWeapons: selectedWeapons,
      selectedMap: map['selectedMap'] ?? '',
      rewardPrizeUSD: map['rewardPrizeUSD'] ?? '',
      playerFeeUSD: map['playerFeeUSD'] ?? '',
      tournamentMode: map['tournamentMode'] ?? '',
      createdAt: createdAt,
    );
  }
}
