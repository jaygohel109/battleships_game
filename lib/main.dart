import 'package:battleships/Utils/Authorization.dart';
import 'package:flutter/material.dart';

import 'models/battleshiphome.dart';

void main() {
  runApp(Battleship());
}

class Battleship extends StatelessWidget {
  final AuthService authService = AuthService();

  Battleship({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BattleshipPage(),
    );
  }
}

class BattleshipPage extends StatefulWidget {
  final AuthService authService = AuthService();

  BattleshipPage({super.key});

  @override
  _BattleshipPageState createState() => _BattleshipPageState();
}

class _BattleshipPageState extends State<BattleshipPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Login',
          style: TextStyle(
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 164, 28),
      ),
      backgroundColor: Color.fromARGB(255, 225, 225, 225),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 30.0), // Adjust the padding as needed
              child: TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 30.0), // Adjust the padding as needed
              child: TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () async {
                    final username = usernameController.text;
                    final password = passwordController.text;
                    try {
                      final response = await widget.authService.loginUser(
                        username,
                        password,
                      );
                      if (response.containsKey('message')) {
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Login successful'),
                          ),
                        );
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => LoggedInScreen(
                              user_name: username,
                              access_token: response['access_token']),
                        ));
                      }
                    } catch (e) {
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$e'),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 164, 28),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    final username = usernameController.text;
                    final password = passwordController.text;
                    try {
                      final response = await widget.authService
                          .registerUser(username, password);
                      if (response.containsKey('message')) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('User created successfully'),
                          ),
                        );
                      } else {
                        throw Exception(response['error']);
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$e'),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Register',
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 164, 28),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
