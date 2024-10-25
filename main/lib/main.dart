import 'package:flutter/material.dart';
import 'package:main/standing.dart';
import 'package:main/team.dart';
import 'package:main/teams_tab.dart';
import './favorites_tab.dart';
import './players_tab.dart';
import './scores_tab.dart';
import './standings_tab.dart';
import './game.dart';
import './player.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
  List<Team> teams = [];
  List<Player> players = [];
  late Future _future;
  final jakeHeaders = {'x-rapidapi-key': 'd5acb40e57a90447afa2bfcba8f332e2'};
  final shivenHeaders = {'x-rapidapi-key': '4bb22b892adc41f1e4eaa6800ff36ab9'};
  final himnishHeaders = {'x-rapidapi-key': '30206e5d618f7492ca4322ff246895a0'};

  Future getTeams() async {
    var requestTeams = http.Request(
        'GET',
        Uri.parse(
            'https://v1.american-football.api-sports.io/teams?league=1&season=2024'));
    requestTeams.headers.addAll(jakeHeaders);
    http.StreamedResponse response = await requestTeams.send();

    if (response.statusCode == 200) {
      var jsonData =
          jsonDecode(await response.stream.bytesToString())['response'];

      for (var i = 0; i < jsonData.length - 2; i++) {
        final team = Team(
          abbreviation: jsonData[i]['code'],
          name: jsonData[i]['name'],
          city: jsonData[i]['city'],
          coach: jsonData[i]['coach'],
          stadium: jsonData[i]['stadium'],
          logo: jsonData[i]['logo'],
          id: jsonData[i]['id'],
        );

        teams.add(team);
      }
    } else {
      print(response.reasonPhrase);
    }
  }

  Future getStandings() async {
    var requestStandings = http.Request(
        'GET',
        Uri.parse(
            'https://v1.american-football.api-sports.io/standings?league=1&season=2024'));
    requestStandings.headers.addAll(jakeHeaders);
    http.StreamedResponse response = await requestStandings.send();

    if (response.statusCode == 200) {
      var jsonData =
          jsonDecode(await response.stream.bytesToString())['response'];
      for (var i = 0; i < jsonData.length; i++) {
        var currJsonData = jsonData[i];
        var currTeamName = currJsonData['team']['name'];
        for (var x = 0; x < teams.length; x++) {
          var currSearchName = teams[x].name;
          if (currTeamName == currSearchName) {
            Team foundTeam = teams[x];
            foundTeam.setDivision(currJsonData['division']);
            foundTeam.setDivPosition(currJsonData['position']);
            foundTeam.setWins(currJsonData['won']);
            foundTeam.setLosses(currJsonData['lost']);
            foundTeam.setTies(currJsonData['ties']);
            break;
          }
        }
      }
    } else {
      print(response.reasonPhrase);
    }
  }

  Future getGames() async {
    var requestGames = http.Request(
        'GET',
        Uri.parse(
            'https://v1.american-football.api-sports.io/games?league=1&season=2024'));
    requestGames.headers.addAll(jakeHeaders);
    http.StreamedResponse response = await requestGames.send();

    if (response.statusCode == 200) {
      var jsonData =
          jsonDecode(await response.stream.bytesToString())['response'];
      for (var i = 0; i < jsonData.length; i++) {
        var currData = jsonData[i];
        final game = Game(
          stage: currData['game']['stage'],
          week: currData['game']['week'],
          date: currData['game']['date']['date'],
          time: currData['game']['date']['time'],
          status: currData['game']['status']['long'],
          venue: currData['game']['venue']['name'],
          homeTeam: currData['teams']['home']['name'],
          awayTeam: currData['teams']['away']['name'],
          homeScore: currData['scores']['home']['total'],
          awayScore: currData['scores']['away']['total'],
        );
        var foundTeams = 0;
        for(Team team in teams) {
          if (team.name == game.homeTeam || team.name == game.awayTeam) {
            team.games.add(game);
            foundTeams++;
          }

          if (foundTeams >= 2) {
            break;
          }
        }
      }
    } else {
      print(response.reasonPhrase);
    }
  }

  Future getSingularPlayer() async {
    var requestSinglePlayer = http.Request(
        'GET',
        Uri.parse(
            'https://v1.american-football.api-sports.io/players?season=2024&team=5'));
    requestSinglePlayer.headers.addAll(jakeHeaders);
    http.StreamedResponse response = await requestSinglePlayer.send();

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(await response.stream.bytesToString())['response'];
      for (var i = 0; i < 8; i ++) {
        var currPlayer = jsonData[i];
        final Player player = Player(
          id: currPlayer['id'],
          name: currPlayer['name'],
          age: currPlayer['age'],
          height: currPlayer['height'],
          weight: currPlayer['weight'],
          position: currPlayer['position'],
          number: currPlayer['number'],
          image: currPlayer['image']);
        players.add(player);
      }
    } else {
      print(response.reasonPhrase);
    }
  }

  @override
  void initState() {
    _future = getTeams().then((_) {
      getStandings();
      getGames();
      getSingularPlayer();
    });
    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: DefaultTabController(
          length: 5,
          child: SafeArea(
            child: Scaffold(
                  appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: const Text('Sports App'),
            bottom: const TabBar(
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black,
              tabs: [Tab(text: 'Scores',), Tab(text: 'Standings',), Tab(text: 'Teams',), Tab(text: 'Players',), Tab(text: 'Favorite',)]),
                  ),
                  body: FutureBuilder(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return TabBarView(children: [
                    //If you have to pass a parameter to your class (as I did for TeamsTab),
                    //you will have to remove const!
                    const ScoresTab(),
                    const StandingsTab(),
                    TeamsTab(teams: teams,),
                    PlayersTab(players: players),
                    const FavoritesTab(),
                  ]);
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
                ),
          ),
        ));
  }
}
