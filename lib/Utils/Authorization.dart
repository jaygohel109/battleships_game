import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = 'http://165.227.117.48';

  Future<Map<String, dynamic>> registerUser(
      String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  Future<Map<String, dynamic>> loginUser(
      String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Invalid username or password');
    } else {
      throw Exception('Failed to log in');
    }
  }

  Future<void> logoutUser(String accessToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );
      if (response.statusCode == 200) {
        return;
      } else {
        throw Exception('Logout failed with status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  Future<Map<String, dynamic>> startGame(
      String? accessToken, List<String> ships, String? ai) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/games'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'ships': ships, 'ai': ai}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to start game');
      }
    } catch (e) {
      throw Exception('Failed to start game: $e');
    }
  }

  Future<List<dynamic>> fetchGames(String accessToken) async {
    final response = await http.get(
      Uri.parse('$baseUrl/games'),
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final games = jsonDecode(response.body)['games'];
      print(games);
      return games;
    } else {
      throw Exception('Failed to fetch games');
    }
  }

  Future<Map<String, dynamic>> getGameDetails(
      int gameId, String? accessToken) async {
    final response = await http.get(
      Uri.parse('$baseUrl/games/$gameId'),
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch game details');
    }
  }

  Future<Map<String, dynamic>> gameDelete(
      int gameId, String accessToken) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/games/$gameId'),
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to delete game');
    }
  }

  Future<String> shootOpponentShip(
      String? accessToken, String? tileToShoot, int gameId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/games/$gameId'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'shot': tileToShoot}),
      );

      if (response.statusCode == 200) {
        print('Shot fired at $tileToShoot successfully');
        return 'Shot fired at $tileToShoot successfully';
      } else {
        print('Failed to shoot: ${response.statusCode}');
        return 'Failed to shoot: ${response.statusCode}';
      }
    } catch (e) {
      return 'Failed to shoot: $e';
    }
  }
}
