import 'package:flutter/material.dart';

import 'dart:async';
import 'package:everesports/core/page/addGame/service/user_games_service.dart';
import 'package:everesports/widget/common_snackbar.dart';

class UserGamesListPage extends StatefulWidget {
  final List<Map<String, dynamic>> userGames;
  final String? userId;
  final VoidCallback? onRefresh;

  const UserGamesListPage({
    Key? key,
    required this.userGames,
    required this.userId,
    this.onRefresh,
  }) : super(key: key);

  @override
  State<UserGamesListPage> createState() => _UserGamesListPageState();
}

class _UserGamesListPageState extends State<UserGamesListPage> {
  Future<void> _editGameUID(Map<String, dynamic> game) async {
    final TextEditingController uidController = TextEditingController(
      text: game['game_uid'] ?? '',
    );
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Game UID'),
          content: TextField(
            controller: uidController,
            decoration: const InputDecoration(labelText: 'Game UID'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, uidController.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    if (result != null && result != game['game_uid']) {
      final error = await UserGamesService.editUserGameUID(game, result);
      if (error != null) {
        commonSnackBarbuildError(context, error);
        return;
      }
      if (widget.onRefresh != null) widget.onRefresh!();
      setState(() {});
      commonSnackBarbuild(context, 'Game UID updated successfully.');
    }
  }

  Future<Map<String, dynamic>?> fetchGameById(dynamic gameId) async {
    return await UserGamesService.fetchGameById(gameId);
  }

  Future<Map<String, String>> fetchGameNamesForUserGames(
    List<Map<String, dynamic>> userGames,
  ) async {
    return await UserGamesService.fetchGameNamesForUserGames(userGames);
  }

  Future<void> _deleteUserGame(Map<String, dynamic> game) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Game'),
        content: const Text('Are you sure you want to delete this game entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await UserGamesService.deleteUserGame(game);
      if (widget.onRefresh != null) widget.onRefresh!();
      setState(() {});
      commonSnackBarbuild(context, 'Game entry deleted.');
    } catch (e) {
      commonSnackBarbuildError(context, 'Error deleting game: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userGames = widget.userGames;
    return FutureBuilder<Map<String, String>>(
      future: fetchGameNamesForUserGames(userGames),
      builder: (context, snapshot) {
        final idToName = snapshot.data ?? {};
        return Scaffold(
          appBar: AppBar(title: const Text("My Games")),
          body: LayoutBuilder(
            builder: (context, constraints) {
              if (userGames.isEmpty) {
                return const Center(child: Text("No games added yet."));
              }
              if (constraints.maxWidth < 600) {
                // Mobile/tablet: AnimatedSwitcher for ListView
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: ListView.separated(
                    key: ValueKey(userGames.length),
                    itemCount: userGames.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final game = userGames[index];
                      final gameId =
                          game['game_id'] is Map &&
                              game['game_id'].containsKey('oid')
                          ? game['game_id']['oid']
                          : game['game_id'].toString();
                      final gameName =
                          idToName[gameId] ?? game['dropdown_game_name'] ?? '';
                      final customGameName = (game['game_name'] ?? '')
                          .toString()
                          .trim();
                      final titleText = customGameName.isNotEmpty
                          ? customGameName
                          : gameName;
                      return ListTile(
                        title: Text(titleText),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Game Name: $gameName'),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(game['game_uid'] ?? ''),
                                Text(game['joined_date'] ?? ''),
                              ],
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editGameUID(game),
                              tooltip: 'Edit UID',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteUserGame(game),
                              tooltip: 'Delete',
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              } else {
                // Desktop/web: AnimatedSwitcher for DataTable
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: SingleChildScrollView(
                    key: ValueKey(userGames.length),
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing:
                          MediaQuery.of(context).size.width *
                          0.04, // Add more space between columns
                      columns: const [
                        DataColumn(label: Text('Your Game Name')),
                        DataColumn(label: Text('Game Name')),
                        DataColumn(label: Text('Game UID')),
                        DataColumn(label: Text('Joined Date'), numeric: true),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: userGames.map((game) {
                        final gameId =
                            game['game_id'] is Map &&
                                game['game_id'].containsKey('oid')
                            ? game['game_id']['oid']
                            : game['game_id'].toString();
                        final gameName =
                            idToName[gameId] ??
                            game['dropdown_game_name'] ??
                            '';
                        final customGameName = (game['game_name'] ?? '')
                            .toString()
                            .trim();
                        return DataRow(
                          cells: [
                            DataCell(
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: Text(customGameName),
                              ),
                            ),
                            DataCell(
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: Text(gameName),
                              ),
                            ),
                            DataCell(
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: Text(game['game_uid'] ?? ''),
                              ),
                            ),
                            DataCell(
                              Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: Text(game['joined_date'] ?? ''),
                              ),
                            ),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    tooltip: 'Edit UID',
                                    onPressed: () => _editGameUID(game),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    tooltip: 'Delete',
                                    onPressed: () => _deleteUserGame(game),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }
}
