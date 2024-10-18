import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './team.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import './game.dart';

class FavoritesTab extends StatefulWidget {
  final List<Team> teams;
  final int favoriteTeamId;
  const FavoritesTab({super.key, required this.teams, required this.favoriteTeamId});

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
    tz.initializeTimeZones();
  }

  String convertUtcTimeToEst(String utcTime) {
    // Load the America/New_York timezone (EST/EDT)
    final estTimeZone = tz.getLocation('America/New_York');
    
    // Get the current date
    final now = DateTime.now().toUtc();

    // Manually create a DateTime with the UTC time (from the API) and today's date
    final utcDateTime = DateTime.utc(now.year, now.month, now.day, 
                                     int.parse(utcTime.split(':')[0]),  // hours from the API time
                                     int.parse(utcTime.split(':')[1])); // minutes from the API time

    // Convert UTC time to EST/EDT
    final estDateTime = tz.TZDateTime.from(utcDateTime, estTimeZone);

    // Format EST time as desired (e.g., 1:00 PM)
    return '${estDateTime.hour > 12 ? estDateTime.hour - 12 : estDateTime.hour}:${estDateTime.minute.toString().padLeft(2, '0')} ${estDateTime.hour >= 12 ? 'PM' : 'AM'}';
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
    final favoriteTeam = widget.teams.firstWhere(
      (team) => team.id == widget.favoriteTeamId,
    );

    return teamInfo == null
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (favoriteTeam != null)
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(favoriteTeam.logo),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    const SizedBox(width: 16),
                    Text(
                      'Favorite Team: ${teamInfo!['name']}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text('Coach: ${teamInfo!['coach'] ?? 'N/A'}'),
                Text('Owner: ${teamInfo!['owner'] ?? 'N/A'}'),
                Text('Stadium: ${teamInfo!['stadium'] ?? 'N/A'}'),
                const SizedBox(height: 20),
                if (favoriteTeam != null) ...[
                  Text(
                    'Division: ${favoriteTeam.division ?? 'N/A'}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Position: ${favoriteTeam.divPosition ?? 'N/A'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
                const SizedBox(height: 10),
                if (favoriteTeam != null) ...[
                  Text(
                    'Record: W ${favoriteTeam.wins ?? 0} - L ${favoriteTeam.losses ?? 0} - T ${favoriteTeam.ties ?? 0}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
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
                          Text('Time: ${convertUtcTimeToEst(latestGame!.time)}'),
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
                          Text('Time: ${convertUtcTimeToEst(upcomingGame!.time)}'),
                          Text('Venue: ${upcomingGame!.venue ?? 'N/A'}'),
                        ],
                      )
                    : const Text('No upcoming game data available.'),
              ],
            ),
          );
  }

}
