import 'package:battleships/Utils/Authorization.dart';
import 'package:battleships/view/gamescreen.dart';
import 'package:battleships/main.dart';
import 'package:battleships/models/newgamescreen.dart';
import 'package:battleships/view/showgamelitscreen.dart';
import 'package:flutter/material.dart';

class LoggedInScreen extends StatefulWidget {
  final String user_name;
  final String access_token;

  const LoggedInScreen({
    Key? key,
    required this.user_name,
    required this.access_token,
  }) : super(key: key);

  @override
  _LoggedInScreenState createState() => _LoggedInScreenState();
}

final AuthService authService = AuthService();

class _LoggedInScreenState extends State<LoggedInScreen> {
  List<dynamic> ongoingGames = [];

  @override
  void initState() {
    super.initState();
    fetchOngoingGames();
  }

  void reloadGames() {
    fetchOngoingGames();
  }

  void showGameDetails(int gameId) async {
    try {
      final gameDetails =
          await authService.getGameDetails(gameId, widget.access_token);
      final int status = gameDetails['status'];
      final player1 = gameDetails['player1'];
      final player2 = gameDetails['player2'];
      final currentPlayer = gameDetails['turn'] == 1 ? player1 : player2;
      final isYourTurn = currentPlayer == widget.user_name;

      if (status == 1 || status == 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Cannot view game details. Game status is active or completed.'),
          ),
        );
        return;
      }

      if (!isYourTurn) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('waiting for opponent \'s turn'),
          ),
        );
        return;
      }

      final result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => GameScreen(
          gameData: gameDetails,
          gameId: gameId,
          accessToken: widget.access_token,
          onGameUpdated: () {
            fetchOngoingGames();
          },
        ),
      ));

      if (result != null && result == 'game_updated') {
        fetchOngoingGames();
        print("Game details updated");
      }
    } catch (e) {
      print('Failed to fetch game details: $e');
    }
  }

  Future<void> fetchOngoingGames() async {
    try {
      final games = await authService.fetchGames(widget.access_token);
      final filteredGames = games
          .where((game) => game['status'] == 0 || game['status'] == 3)
          .toList();

      setState(() {
        ongoingGames = filteredGames;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to fetch ongoing games: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 164, 28),
        title: const Text(
          'Battleships',
          style: TextStyle(
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        actions: <Widget>[
          IconButton(
            color: const Color.fromARGB(255, 0, 0, 0),
            onPressed: reloadGames,
            icon: const Icon(Icons.refresh),
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      drawer: Drawer(
        backgroundColor: const Color.fromARGB(255, 174, 174, 174),
        child: ListView(
          children: <Widget>[
            Container(
              color: const Color.fromARGB(255, 255, 164, 28),
              padding: const EdgeInsets.symmetric(vertical: 70, horizontal: 16),
              child: ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Welcome to Battleship',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Logged in as ${widget.user_name}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('New Game'),
              iconColor: Colors.black,
              onTap: () async {
                final result =
                    await Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => NewGameScreen(
                    username: widget.user_name,
                    accessToken: widget.access_token,
                    onGameUpdated: () {
                      fetchOngoingGames();
                    },
                  ),
                ));
                if (result != null && result == 'game_added') {
                  fetchOngoingGames();
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.android),
              title: const Text('New Game AI'),
              iconColor: Colors.black,
              onTap: () async {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return SimpleDialog(
                      title:
                          const Text('Which AI do you want to play against?'),
                      children: <Widget>[
                        SimpleDialogOption(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            final result = await Navigator.of(context)
                                .push(MaterialPageRoute(
                              builder: (context) => NewGameScreen(
                                username: widget.user_name,
                                accessToken: widget.access_token,
                                ai: "random",
                              ),
                            ));
                            if (result != null && result == 'game_added') {
                              fetchOngoingGames();
                            }
                          },
                          child: const Text('Random'),
                        ),
                        SimpleDialogOption(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            // navigateToGameScreen('Option 1');
                            final result = await Navigator.of(context)
                                .push(MaterialPageRoute(
                              builder: (context) => NewGameScreen(
                                username: widget.user_name,
                                accessToken: widget.access_token,
                                ai: "perfect",
                              ),
                            ));
                            if (result != null && result == 'game_added') {
                              fetchOngoingGames();
                            }
                          },
                          child: const Text('Perfect'),
                        ),
                        SimpleDialogOption(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            final result = await Navigator.of(context)
                                .push(MaterialPageRoute(
                              builder: (context) => NewGameScreen(
                                  username: widget.user_name,
                                  accessToken: widget.access_token,
                                  ai: "oneship"),
                            ));
                            if (result != null && result == 'game_added') {
                              fetchOngoingGames();
                            }
                          },
                          child: const Text('OneShip'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Show completed games'),
              iconColor: Colors.black,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OngoingGamesScreen(
                        access_token: widget.access_token,
                        user_name: widget.user_name),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              iconColor: Colors.black,
              onTap: () async {
                try {
                  showLogoutConfirmation(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Logout failed: $e'),
                    ),
                  );
                }
              },
            )
          ],
        ),
      ),
      backgroundColor: Color.fromARGB(255, 225, 225, 225),
      body: ListView.builder(
          itemCount: ongoingGames.length,
          itemBuilder: (BuildContext context, int index) {
            final game = ongoingGames[index];
            final player1 = game['player1'];
            final player2 = game['player2'];
            final currentPlayer = game['turn'] == 1 ? player1 : player2;
            final isYourTurn = currentPlayer == widget.user_name;

            return Dismissible(
              key: Key(game['id'].toString()),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.red,
                child: const Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: Text(
                      'Delete',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              onDismissed: (direction) async {
                setState(() {
                  ongoingGames.removeAt(index);
                });
                try {
                  await authService.gameDelete(game['id'], widget.access_token);
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Failed to delete game. Please try again later.'),
                    ),
                  );
                  print('Error deleting game: $error');
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Game ${game['id']} deleted'),
                  ),
                );
              },
              child: ListTile(
                title: Row(
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: DefaultTextStyle.of(context).style,
                          children: [
                            TextSpan(
                                text: 'Game ID: ${game['id']} - ',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                            TextSpan(
                                text: '$player1 vs $player2',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      isYourTurn ? 'Your turn' : 'Opponent\'s turn',
                      style: TextStyle(
                        color: isYourTurn
                            ? const Color.fromARGB(255, 72, 202, 143)
                            : const Color.fromARGB(255, 255, 81, 69),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  showGameDetails(game['id']);
                },
              ),
            );
          }),
    );
  }
}

Future<void> showLogoutConfirmation(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Color.fromARGB(255, 184, 184, 184),
        title: const Text('Logout Confirmation'),
        content: const SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Are you sure you want to log out?'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                // await authService.logoutUser(user_id); // Pass the user_id
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) =>
                      Battleship(), // Replace with your login screen
                ));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Logout failed: $e'),
                  ),
                );
              }
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
            ),
          ),
        ],
      );
    },
  );
}
