import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class FavoritesTab extends StatefulWidget{
  const FavoritesTab({super.key});

  @override
  State<FavoritesTab> createState() => _FavoritesTab();
}

class _FavoritesTab extends State<FavoritesTab> {
  final int teamID = 4;
  dynamic latestGame;
  dynamic upcomingGame;
  Map<String, dynamic>? teamInfo;

  @override 
  void initState(){
    super.initState();
    fetchTeamData();
  }

  Future<void> fetchTeamData() async {
    var himnishHeaders = {
      'x-rapidapi-key': '30206e5d618f7492ca4322ff246895a0'};


    var teamInfoRequest = http.Request(
        'GET',
        Uri.parse(
            'https://v1.american-football.api-sports.io/teams?id=$teamID&league=1&season=2024'));
    teamInfoRequest.headers.addAll(himnishHeaders);
    http.StreamedResponse teamInfoResponse = await teamInfoRequest.send();
    if (teamInfoResponse.statusCode == 200) {
      var responseBody = await teamInfoResponse.stream.bytesToString();
      var teamInfoJson = jsonDecode(responseBody);
      setState(() {
        if (teamInfoJson['response'] != null && teamInfoJson['response'].isNotEmpty) {
          teamInfo = teamInfoJson['response'][0];
        } else {
          teamInfo = null; 
        }
      });
    } else {
      print('Failed to load data from API. Status code');
    }

    var gamesRequest = http.Request(
      'GET',
      Uri.parse('https://v1.american-football.api-sports.io/games?league=1&season=2024&team=4'));
    gamesRequest.headers.addAll(himnishHeaders);
    http.StreamedResponse gameResponse = await gamesRequest.send();
    if(gameResponse.statusCode == 200){
      var responseBodyGames = await gameResponse.stream.bytesToString();
      var gamesDecoded = jsonDecode(responseBodyGames);
      List<dynamic> games = gamesDecoded['response'];
      print(games.length);
      for(var game in games){
        var status = game['game']['status']['long'];
        if(status == 'Finished'){
          print('Finished game found');
          latestGame = game;
        }
        if (latestGame != null && status == 'Not Started') {
            print('upcoming game found');
            upcomingGame = game;
            break; 
        }
      }

    }else{
      print('Failed to load data from API. Status code');
    }
  }

  String getOpponentName(dynamic game, String teamName) {
    if (game['teams']['home']['name'] == teamName) {
      return game['teams']['away']['name'];
    } else {
      return game['teams']['home']['name'];
    }
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
                            Text('Opponent: ${getOpponentName(latestGame, teamInfo!['name'])}'),
                            Text('Score: ${latestGame!['game']['scores']['home']['total']} - ${latestGame!['game']['scores']['away']['total']}'),
                            Text('Date: ${latestGame!['game']['date']['date'] ?? 'N/A'}'),
                            Text('Venue: ${latestGame!['game']['venue']['name']}'),
                          ],
                        )
                      : const Text('No latest game data available.'),
                  
                  const Text('Upcoming Game', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  upcomingGame != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Opponent: ${getOpponentName(upcomingGame, teamInfo!['name'])}'),
                            Text('Date: ${upcomingGame!['game']['date']['date'] ?? 'N/A'}'),
                            Text('Venue: ${upcomingGame!['game']['venue']['name']}'),
                          ],
                        )
                      : const Text('No upcoming game data available.'),
                ],
            ),
          );
  }

}







    


