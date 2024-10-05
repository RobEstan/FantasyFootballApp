import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './game.dart';

class FavoritesTab extends StatefulWidget {
  const FavoritesTab({super.key});

  @override
  State<FavoritesTab> createState() => _FavoritesTab();
}

class _FavoritesTab extends State<FavoritesTab> {
  final int teamID = 4;
  Game? latestGame;
  Game? upcomingGame;
  Map<String, dynamic>? teamInfo;

  @override
  void initState() {
    super.initState();
    fetchTeamData();
  }

  Future<void> fetchTeamData() async {
    var himnishHeaders = {
      'x-rapidapi-key': '30206e5d618f7492ca4322ff246895a0',
    };

    
    var teamInfoRequest = http.Request(
      'GET',
      Uri.parse(
          'https://v1.american-football.api-sports.io/teams?id=$teamID&league=1&season=2024'),
    );
    teamInfoRequest.headers.addAll(himnishHeaders);
    http.StreamedResponse teamInfoResponse = await teamInfoRequest.send();

    if (teamInfoResponse.statusCode == 200) {
      var responseBody = await teamInfoResponse.stream.bytesToString();
      var teamInfoJson = jsonDecode(responseBody);
      setState(() {
        if (teamInfoJson['response'] != null &&
            teamInfoJson['response'].isNotEmpty) {
          teamInfo = teamInfoJson['response'][0];
        } else {
          teamInfo = null;
        }
      });
    } else {
      print('Failed to load data from API. Status code: ${teamInfoResponse.statusCode}');
    }


    var gamesRequest = http.Request(
      'GET',
      Uri.parse(
          'https://v1.american-football.api-sports.io/games?league=1&season=2024&team=$teamID'),
    );
    gamesRequest.headers.addAll(himnishHeaders);
    http.StreamedResponse gameResponse = await gamesRequest.send();

    if (gameResponse.statusCode == 200) {
      var responseBodyGames = await gameResponse.stream.bytesToString();
      var gamesDecoded = jsonDecode(responseBodyGames);
      List<dynamic> games = gamesDecoded['response'];

     
      Game? tempLatestGame;
      Game? tempUpcomingGame;
      for (var game in games) {
        var status = game['game']['status']['long'];
        var currGame = Game(
          stage: game['game']['stage'],
          week: game['game']['week'],
          date: game['game']['date']['date'],
          time: game['game']['date']['time'],
          status: game['game']['status']['long'],
          venue: game['game']['venue']['name'],
          homeTeam: game['teams']['home']['name'],
          awayTeam: game['teams']['away']['name'],
          homeScore: game['scores']['home']['total'],
          awayScore: game['scores']['away']['total'],
        );
        if (status == 'Finished') {
          tempLatestGame = currGame;
        }
        if (status == 'Not Started' && tempUpcomingGame == null) {
          tempUpcomingGame = currGame;
        }
      }
      setState(() {
        latestGame = tempLatestGame;
        upcomingGame = tempUpcomingGame;
      });
    } else {
      print('Failed to load games from API. Status code: ${gameResponse.statusCode}');
    }
  }


  String getOpponentName(Game game, String teamName) {
    return game.homeTeam == teamName ? game.awayTeam! : game.homeTeam!;
  }

  @override
  Widget build(BuildContext context) {
    return teamInfo == null
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Favorite Team: ${teamInfo!['name']}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text('Coach: ${teamInfo!['coach'] ?? 'N/A'}'),
                Text('Owner: ${teamInfo!['owner'] ?? 'N/A'}'),
                Text('Stadium: ${teamInfo!['stadium'] ?? 'N/A'}'),
                const SizedBox(height: 20),
                const Text('Latest Game', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                latestGame != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Opponent: ${getOpponentName(latestGame!, teamInfo!['name'])}'),
                          Text('Score: ${latestGame!.homeScore} - ${latestGame!.awayScore}'),
                          Text('Date: ${latestGame!.date}'),
                          Text('Venue: ${latestGame!.venue ?? 'N/A'}'),
                        ],
                      )
                    : const Text('No latest game data available.'),
                const SizedBox(height: 20),
                const Text('Upcoming Game', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                upcomingGame != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Opponent: ${getOpponentName(upcomingGame!, teamInfo!['name'])}'),
                          Text('Date: ${upcomingGame!.date}'),
                          Text('Venue: ${upcomingGame!.venue ?? 'N/A'}'),
                        ],
                      )
                    : const Text('No upcoming game data available.'),
              ],
            ),
          );
  }
}
