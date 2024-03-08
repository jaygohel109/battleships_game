import 'dart:ui';
import 'package:battleships/Utils/Authorization.dart';
import 'package:flutter/material.dart';

class NewGameScreen extends StatefulWidget {
  final String? username;
  final String? accessToken;
  final String? ai;
  final VoidCallback? onGameUpdated;

  const NewGameScreen({
    Key? key,
    required this.username,
    required this.accessToken,
    this.ai,
    this.onGameUpdated,
  }) : super(key: key);

  @override
  _NewGameScreenState createState() => _NewGameScreenState();
}

final AuthService authService = AuthService();

class _NewGameScreenState extends State<NewGameScreen> {
  Set<String> selectedTiles = Set<String>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Place ships',
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
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton(
              onPressed: () {
                handleSubmit(widget.accessToken, widget.ai);
                if (widget.onGameUpdated != null) {
                  widget.onGameUpdated!();
                }
                Navigator.pop(context, 'game_added');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 164, 28),
              ),
              child: const Text('Submit'),
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
              image: NetworkImage(
                  'https://wallpapercave.com/wp/wp11552730.jpg'), // Replace with your image URL
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
              // Title column (A-E)
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
              // Title row (1-5)
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
              // Main grid cells
              int row = (index - 1) ~/ 6 + 1;
              String column = (index % 6).toString();
              String tileName =
                  String.fromCharCode('A'.codeUnitAt(0) + row - 2) + column;

              return InkWell(
                onTap: () {
                  handleGridItemClick(tileName);
                },
                child: MouseRegion(
                  onEnter: (_) {
                    handleGridItemHover(true, tileName);
                  },
                  onExit: (_) {
                    handleGridItemHover(false, tileName);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: selectedTiles.contains(tileName)
                          ? Colors.blue.withOpacity(0.5) // Selected color
                          : _hoveredTile == tileName
                              ? Colors.grey.withOpacity(0.5) // Hovered color
                              : const Color.fromARGB(255, 255, 205, 129)
                                  .withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.black),
                    ),
                  ),
                  // this will shows title of position.
                  //child: Center(
                  //   child: Text(
                  //     tileName,
                  //     style: TextStyle(
                  //       fontWeight: FontWeight.bold,
                  //     ),
                  //   ),
                  // ),
                ),
              );
            }
          },
        )
      ],
    );
  }

  String _hoveredTile = '';

  void handleGridItemHover(bool hover, String tileName) {
    setState(() {
      if (hover) {
        _hoveredTile = tileName;
      } else {
        _hoveredTile = '';
      }
    });
  }

  void handleGridItemClick(String tileName) {
    setState(() {
      if (selectedTiles.contains(tileName)) {
        selectedTiles.remove(tileName);
      } else if (selectedTiles.length < 5) {
        selectedTiles.add(tileName);
      }
    });
  }

  void handleSubmit(String? accessToken, String? ai) async {
    if (selectedTiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select positions.'),
        ),
      );
    } else if (selectedTiles.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least 5 positions.'),
        ),
      );
    } else {
      try {
        final response = await authService.startGame(
            accessToken, selectedTiles.toList(), ai);
        print('Game started: $response');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start game: $e'),
          ),
        );
      }
    }
  }
}
