import 'package:flutter/material.dart';
import 'package:main/standing.dart';
import 'package:main/team.dart';
import 'package:main/teams_tab.dart';
import './favorites_tab.dart';
import './players_tab.dart';
import './scores_tab.dart';
import './standings_tab.dart';
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
  var standings = List.generate(8, (i) => List<Standing>.generate(4, (index) => Standing(name: "b", logo: "", position: 0, wins: 0, losses: 0, ties: 0, pointsFor: 0, pointsAgainst: 0, netPoints: -23, streak: ""), growable: false), growable: false);
  late Future _futureTeams;

  Future getTeams() async {
    var jakeHeaders = {'x-rapidapi-key': 'd5acb40e57a90447afa2bfcba8f332e2'};

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
    var shivenHeaders = {'x-rapidapi-key': '4bb22b892adc41f1e4eaa6800ff36ab9'};

    var requestTeams = http.Request(
        'GET',
        Uri.parse(
            'https://v1.american-football.api-sports.io/standings?league=1&season=2024'));
    requestTeams.headers.addAll(shivenHeaders);
    http.StreamedResponse response = await requestTeams.send();

    int index = 0;
    if (response.statusCode == 200) {
      var jsonData =
          jsonDecode(await response.stream.bytesToString())['response'];


      for (var i = 0; i < jsonData.length; i++) {
        final teamStanding = Standing(
          name: jsonData[i]['team']['name'],
          logo: jsonData[i]['team']['logo'],
          position: jsonData[i]['position'],
          wins: jsonData[i]['won'],
          losses: jsonData[i]['lost'],
          ties: jsonData[i]['ties'],
          pointsFor: jsonData[i]['points']['for'],
          pointsAgainst: jsonData[i]['points']['against'],
          netPoints: jsonData[i]['points']['difference'],
          streak: jsonData[i]['streak'],
        );
        standings[(index/4).floor()][teamStanding.position - 1] = teamStanding;
        index++;
      }
    } else {
      print(response.reasonPhrase);
    }
  }


  Future<void> fetchAllData() async {
    await getTeams();
    await getStandings();
  }

  @override
  void initState() {
    _futureTeams = fetchAllData();
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
              future: _futureTeams,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return TabBarView(children: [
                    //If you have to pass a parameter to your class (as I did for TeamsTab),
                    //you will have to remove const!
                    const ScoresTab(),
                    StandingsTab(standings: standings),
                    TeamsTab(teams: teams,),
                    const PlayersTab(),
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
