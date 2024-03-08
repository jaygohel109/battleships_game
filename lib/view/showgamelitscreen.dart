import 'package:battleships/models/battleshiphome.dart';
import 'package:flutter/material.dart';

class OngoingGamesScreen extends StatefulWidget {
  final String access_token;
  final String user_name;

  const OngoingGamesScreen(
      {Key? key, required this.access_token, required this.user_name})
      : super(key: key);

  @override
  State<OngoingGamesScreen> createState() => _OngoingGamesScreenState();
}

class _OngoingGamesScreenState extends State<OngoingGamesScreen> {
  List<dynamic> ongoingGames = [];

  @override
  void initState() {
    super.initState();
    fetchOngoingGames();
  }

  Future<void> fetchOngoingGames() async {
    try {
      final games = await authService.fetchGames(widget.access_token);
      setState(() {
        ongoingGames = games;
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
    final List<dynamic> gamelist = ongoingGames;

    final List<dynamic> filteredGames = gamelist
        .where((game) => game['status'] == 1 || game['status'] == 2)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Completed Games',
          style: TextStyle(
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 255, 164, 28),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Color.fromARGB(255, 225, 225, 225),
      body: ListView.builder(
        itemCount: filteredGames.length,
        itemBuilder: (BuildContext context, int index) {
          final game = filteredGames[index];
          final player1 = game['player1'];
          final player2 = game['player2'];
          final currentPlayer = game['turn'] == 1 ? player1 : player2;

          String winStatus = '';
          if (game['status'] == 1 && player1 == widget.user_name) {
            winStatus = 'You won!';
          } else if (game['status'] == 2 && player2 == widget.user_name) {
            winStatus = 'You won!';
          } else {
            winStatus = 'Opponent wins';
          }

          return ListTile(
            title: Row(
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      children: [
                        TextSpan(
                            text: '# ${game['id']} - ',
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
                  winStatus,
                  style: TextStyle(
                    color:
                        winStatus.contains('won') ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
