import 'package:flutter/material.dart';
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
  late Future _futureTeams;

  Future getTeams() async {
    var jakeHeaders = {'x-rapidapi-key': 'd5acb40e57a90447afa2bfcba8f332e2'};
    var himnishHeaders = {'x-rapidapi-key': '30206e5d618f7492ca4322ff246895a0'};

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

  @override
  void initState() {
    _futureTeams = getTeams();
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
                    const StandingsTab(),
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
