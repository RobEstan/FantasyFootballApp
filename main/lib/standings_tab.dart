
import 'package:flutter/material.dart';
import './standing.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './display_team.dart';
import './team.dart';

const List<String> divisions = [
  'AFC East',
  'AFC North',
  'AFC South',
  'AFC West',
  'NFC East',
  'NFC North',
  'NFC South',
  'NFC West',
];
final shivenHeaders = {'x-rapidapi-key': '4bb22b892adc41f1e4eaa6800ff36ab9'};
final jakeHeaders = {'x-rapidapi-key': 'd5acb40e57a90447afa2bfcba8f332e2'};
final himnishHeaders = {'x-rapidapi-key': '30206e5d618f7492ca4322ff246895a0'};

class StandingsTab extends StatefulWidget {
  const StandingsTab({super.key, required this.teams});

  final List<Team> teams;

  @override
  State<StandingsTab> createState() => _StandingsTab();
}

class _StandingsTab extends State<StandingsTab> {
  var standings = List.generate(
      8,
      (i) => List<Standing>.generate(
          4,
          (index) => Standing(
              name: "",
              logo: "",
              position: 0,
              wins: 0,
              losses: 0,
              ties: 0,
              pointsFor: 0,
              pointsAgainst: 0,
              netPoints: 0,
              streak: "",
              id: -1),
          growable: false),
      growable: false);
  late Future<void> _futureStandings;

  @override
  void initState() {
    _futureStandings = getStandings();
    super.initState();
  }

  Future getStandings() async {
    var requestTeams = http.Request(
        'GET',
        Uri.parse(
            'https://v1.american-football.api-sports.io/standings?league=1&season=2024'));
    requestTeams.headers.addAll(himnishHeaders);
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
          id: jsonData[i]['team']['id'],
        );
        standings[(index / 4).floor()][teamStanding.position - 1] =
            teamStanding;
        index++;
      }
    } else {
      print(response.reasonPhrase);
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _futureStandings,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return ListView.builder(
            itemCount: standings.length,
            itemBuilder: (context, divisionIndex) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      divisions[divisionIndex],
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: standings[divisionIndex].length,
                    itemBuilder: (context, teamIndex) {
                      final teamStanding = standings[divisionIndex][teamIndex];
                      return ListTile(
                        leading: teamStanding.logo.isNotEmpty
                            ? Hero(
                                tag: teamStanding.name,
                                child: Image.network(
                                  teamStanding.logo,
                                  width: 30,
                                  height: 30,
                                ))
                            : const Icon(Icons.sports_football),
                        title: Text(teamStanding.name),
                        subtitle: Text(
                            'PF: ${teamStanding.pointsFor}, PA: ${teamStanding.pointsAgainst}, Net Points: ${teamStanding.netPoints}\nStreak: ${teamStanding.streak}'),
                        trailing: Text(
                          'Record: ${teamStanding.wins}-${teamStanding.losses}-${teamStanding.ties}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        onTap: () {
                          Team foundTeam = widget.teams
                              .firstWhere((team) => team.id == teamStanding.id);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DisplayTeam(
                                        team: foundTeam,
                                        teams: widget.teams,
                                        showAppBar: true,
                                      )));
                        },
                      );
                    },
                  ),
                  const Divider(),
                ],
              );
            },
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
