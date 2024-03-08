import 'dart:ui';

import 'package:battleships/Utils/Authorization.dart';
import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  final Map<String, dynamic> gameData;
  final int gameId;
  final String? accessToken;
  final VoidCallback? onGameUpdated;

  const GameScreen({
    Key? key,
    required this.gameData,
    required this.gameId,
    required this.accessToken,
    this.onGameUpdated,
  }) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<String> ships = [];
  List<String> sunkShips = [];
  List<String> wrecks = [];
  List<String> shots = [];
  String? selectedTile;
  String hoveredTile = '';
  int? gamestatus = 0;
  final AuthService authService = AuthService();
  @override
  void initState() {
    super.initState();
    ships = List<String>.from(widget.gameData['ships']);
    sunkShips = List<String>.from(widget.gameData['sunk']);
    wrecks = List<String>.from(widget.gameData['wrecks']);
    shots = List<String>.from(widget.gameData['shots']);
    gamestatus = widget.gameData['status'];
  }

  void selectTile(String tileName) {
    setState(() {
      selectedTile = tileName;
    });
  }

  void setHoveredTile(String tileName) {
    setState(() {
      hoveredTile = tileName;
    });
  }

  @override
  Widget build(BuildContext context) {
    ships = List<String>.from(widget.gameData['ships']);
    sunkShips = List<String>.from(widget.gameData['sunk']);
    wrecks = List<String>.from(widget.gameData['wrecks']);
    shots = List<String>.from(widget.gameData['shots']);
    gamestatus = widget.gameData['status'];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Game Details',
          style: TextStyle(
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 164, 28),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: buildGrid(),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () async {
                String message = '';
                if (selectedTile != null) {
                  message = await authService.shootOpponentShip(
                    widget.accessToken,
                    selectedTile,
                    widget.gameId,
                  );
                } else {
                  message = 'Please select a tile first';
                }

                try {
                  final gameDetails1 = await authService.getGameDetails(
                      widget.gameId, widget.accessToken);

                  setState(() {
                    widget.gameData.clear();
                    widget.gameData.addAll(gameDetails1);
                  });

                  if (widget.onGameUpdated != null) {
                    widget.onGameUpdated!();
                  }

                  // ignore: use_build_context_synchronously
                  if (gamestatus == 1 || gamestatus == 2) {
                    showEndGameDialog(gamestatus!);
                  } else {
                    showShotResultDialog(message);
                  }
                } catch (e) {
                  print('Failed to fetch game details: $e');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 164, 28),
              ),
              child: const Text('Shoot'),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildGrid() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image:
                  NetworkImage('https://wallpapercave.com/wp/wp11552730.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 0),
            child: Container(
              color: const Color.fromARGB(255, 107, 107, 107)
                  .withOpacity(0.1), // Adjust opacity as needed
            ),
          ),
        ),
        GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: 36,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Center(
                    child: Text(
                      ' ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              } else if (index % 6 == 0) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Center(
                    child: Text(
                      String.fromCharCode('A'.codeUnitAt(0) + (index ~/ 6 - 1)),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              } else if (index < 6) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Center(
                    child: Text(
                      (index % 6).toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              } else {
                int row = (index - 1) ~/ 6 + 1;
                String column = (index % 6).toString();
                String tileName =
                    String.fromCharCode('A'.codeUnitAt(0) + row - 2) + column;

                bool isShip = ships.contains(tileName);
                bool isSunk = sunkShips.contains(tileName);
                bool isWrecked = wrecks.contains(tileName);
                bool isShot = shots.contains(tileName);

                return GestureDetector(
                  onTap: () {
                    selectTile(tileName);
                  },
                  child: MouseRegion(
                    onEnter: (_) {
                      setHoveredTile(tileName);
                    },
                    onExit: (_) {
                      setHoveredTile('');
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: selectedTile == tileName
                            ? Colors.green
                            : hoveredTile == tileName
                                ? Colors.grey.withOpacity(0.5)
                                : isSunk
                                    ? Colors.red
                                    // : isWrecked
                                    //     ? Colors.blue
                                    //     : isShot
                                    //         ? Colors
                                    //             .orange // Added orange color for shots
                                    : const Color.fromARGB(255, 255, 205, 129)
                                        .withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: Colors.black),
                      ),
                      child: Center(
                        child: isSunk
                            ? const Icon(Icons.emoji_events,
                                color: Colors
                                    .white) // Show bomb icon for wrecked ships
                            : isShip
                                ? const Icon(Icons.directions_boat,
                                    color: Colors
                                        .black) // Show ship icon for unsunked ships
                                : isWrecked
                                    ? const Icon(Icons.bubble_chart,
                                        color: Colors
                                            .blue) // Show bubble icon for sunked ships
                                    : isShot
                                        ? const Icon(Icons.fireplace,
                                            color: Colors
                                                .orange) // Show fire icon for shots
                                        : null, // No icon if no ship or sunk
                      ),
                    ),
                  ),
                );
              }
            }),
      ],
    );
  }

  void showEndGameDialog(int status) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: const Text(
            'Game Over',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                status == 1 ? 'Player 1 won!' : 'Player 2 won!',
                style: const TextStyle(
                  color: Colors.black,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  void showShotResultDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: const Text(
            'Shot Result',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                style: const TextStyle(
                  color: Colors.black,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }
}
