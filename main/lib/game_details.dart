import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:main/team.dart';
import 'package:provider/provider.dart';
import 'package:main/games_model.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class OtherView extends StatelessWidget {
  const OtherView(
      {super.key, required this.logos, required this.teams, required this.id});

  final List<String> logos;
  final List<Team> teams;
  final int id;

  void initTimezone() {
    tz.initializeTimeZones();
  }

  String convertUtcTimeToEst(String utcTime) {
    final estTimeZone = tz.getLocation('America/New_York');
    final now = DateTime.now().toUtc();
    final utcDateTime = DateTime.utc(now.year, now.month, now.day,
        int.parse(utcTime.split(':')[0]), int.parse(utcTime.split(':')[1]));

    final estDateTime = tz.TZDateTime.from(utcDateTime, estTimeZone);
    return '${estDateTime.hour > 12 ? estDateTime.hour - 12 : estDateTime.hour}:${estDateTime.minute.toString().padLeft(2, '0')} ${estDateTime.hour >= 12 ? 'PM' : 'AM'}';
  }

  String convertDateTimeToEst(String date, String time) {
    String utcGameTime = '${date}T$time:00Z';
    DateTime parsedTime = DateTime.parse(utcGameTime);
    DateTime estGameTime =
        tz.TZDateTime.from(parsedTime, tz.getLocation('America/New_York'));
    return '${estGameTime.month}/${estGameTime.day}';
  }

  String getTeamAbbr(String? teamName) {
    if (teamName != null) {
      for (Team t in teams) {
        if (t.name == teamName) {
          return t.abbreviation;
        }
      }
    }
    return 'Team Not Found';
  }

  String justTeamName(String team) {
    final teamList = team.split(' ');
    return teamList[teamList.length - 1];
  }

  Future<Map<String, Map<String, dynamic>>> getGameStats() async {
    final jakeHeaders = {'x-rapidapi-key': 'd5acb40e57a90447afa2bfcba8f332e2'};
    var requestSinglePlayer = http.Request(
        'GET',
        Uri.parse(
            'https://v1.american-football.api-sports.io/games/statistics/teams?id=$id'));
    requestSinglePlayer.headers.addAll(jakeHeaders);
    http.StreamedResponse response = await requestSinglePlayer.send();

    if (response.statusCode == 200) {
      var jsonData =
          jsonDecode(await response.stream.bytesToString())['response'];
      Map<String, dynamic> awayStats = {
        'totalYards': jsonData[0]['statistics']['yards']['total'],
        'passingYards': jsonData[0]['statistics']['passing']['total'],
        'rushingYards': jsonData[0]['statistics']['rushings']['total']
      };
      Map<String, dynamic> homeStats = {
        'totalYards': jsonData[1]['statistics']['yards']['total'],
        'passingYards': jsonData[1]['statistics']['passing']['total'],
        'rushingYards': jsonData[1]['statistics']['rushings']['total']
      };
      Map<String, Map<String, dynamic>> gameStats = {
        'awayStats': awayStats,
        'homeStats': homeStats
      };
      return gameStats;
    } else {
      print(response.reasonPhrase);
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    initTimezone();

    return Consumer<GamesModel>(
        builder: (context, model, child) => FutureBuilder(
            future: getGameStats(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return SafeArea(
                  child: Scaffold(
                      appBar: AppBar(
                        centerTitle: true,
                        title: Text(
                            '${getTeamAbbr(model.currGame.awayTeam)}  @  ${getTeamAbbr(model.currGame.homeTeam)}'),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      body: Center(
                          child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CachedNetworkImage(
                                  imageUrl: logos[0],
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          CircularProgressIndicator(
                                              value: downloadProgress.progress),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                  height: 50,
                                  width: 50,
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      8.0, 0.0, 8.0, 0.0),
                                  child: Text(
                                    justTeamName(model.currGame.awayTeam!),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium,
                                  ),
                                ),
                                Text(
                                  model.currGame.awayScore != null
                                      ? '${model.currGame.awayScore}'
                                      : '',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium,
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CachedNetworkImage(
                                  imageUrl: logos[1],
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          CircularProgressIndicator(
                                              value: downloadProgress.progress),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                  height: 50,
                                  width: 50,
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      8.0, 0.0, 8.0, 0.0),
                                  child: Text(
                                    justTeamName(model.currGame.homeTeam!),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium,
                                  ),
                                ),
                                Text(
                                  model.currGame.homeScore != null
                                      ? '${model.currGame.homeScore}'
                                      : '',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium,
                                ),
                              ],
                            ),
                            Builder(builder: (context) {
                              if (model.currGame.status != "Not Started") {
                                return Table(
                                  border: TableBorder.all(),
                                  children: [
                                    const TableRow(children: [
                                      Center(child: Text('')),
                                      Center(child: Text('1')),
                                      Center(child: Text('2')),
                                      Center(child: Text('3')),
                                      Center(child: Text('4')),
                                      Center(child: Text('Total')),
                                    ]),
                                    TableRow(children: [
                                      Center(
                                          child: Text(getTeamAbbr(
                                              model.currGame.awayTeam))),
                                      Center(
                                          child: Text(
                                              '${model.currGame.awayBox[0]}')),
                                      Center(
                                          child: Text(
                                              '${model.currGame.awayBox[1]}')),
                                      Center(
                                          child: Text(
                                              '${model.currGame.awayBox[2]}')),
                                      Center(
                                          child: Text(
                                              '${model.currGame.awayBox[3]}')),
                                      Center(
                                          child: Text(
                                              '${model.currGame.awayScore}')),
                                    ]),
                                    TableRow(children: [
                                      Center(
                                          child: Text(getTeamAbbr(
                                              model.currGame.homeTeam))),
                                      Center(
                                          child: Text(
                                              '${model.currGame.homeBox[0]}')),
                                      Center(
                                          child: Text(
                                              '${model.currGame.homeBox[1]}')),
                                      Center(
                                          child: Text(
                                              '${model.currGame.homeBox[2]}')),
                                      Center(
                                          child: Text(
                                              '${model.currGame.homeBox[3]}')),
                                      Center(
                                          child: Text(
                                              '${model.currGame.homeScore}')),
                                    ])
                                  ],
                                );
                              } else {
                                return Table(
                                  border: TableBorder.all(),
                                  children: [
                                    const TableRow(children: [
                                      Center(child: Text('')),
                                      Center(child: Text('1')),
                                      Center(child: Text('2')),
                                      Center(child: Text('3')),
                                      Center(child: Text('4')),
                                      Center(child: Text('Total')),
                                    ]),
                                    TableRow(children: [
                                      Center(
                                          child: Text(getTeamAbbr(
                                              model.currGame.awayTeam))),
                                      const Center(child: Text('')),
                                      const Center(child: Text('')),
                                      const Center(child: Text('')),
                                      const Center(child: Text('')),
                                      const Center(child: Text('')),
                                    ]),
                                    TableRow(children: [
                                      Center(
                                          child: Text(getTeamAbbr(
                                              model.currGame.homeTeam))),
                                      const Center(child: Text('')),
                                      const Center(child: Text('')),
                                      const Center(child: Text('')),
                                      const Center(child: Text('')),
                                      const Center(child: Text('')),
                                    ])
                                  ],
                                );
                              }
                            }),
                            Builder(builder: (context) {
                              if (model.currGame.status == 'Final' ||
                                  model.currGame.status == 'Final/OT') {
                                return Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Table(
                                        border: TableBorder.all(),
                                        children: [
                                          TableRow(children: [
                                            Center(
                                              child: Text(
                                                model.currGame.awayTeam!,
                                                textAlign: TextAlign.center,
                                                softWrap: true,
                                              ),
                                            ),
                                            const Center(child: Text('Stat')),
                                            Center(
                                              child: Text(
                                                model.currGame.homeTeam!,
                                                textAlign: TextAlign.center,
                                                softWrap: true,
                                              ),
                                            ),
                                          ]),
                                          TableRow(children: [
                                            Center(
                                              child: Text(
                                                  '${snapshot.data!['awayStats']!['totalYards']}'),
                                            ),
                                            const Center(
                                              child: Text('Total Yards'),
                                            ),
                                            Center(
                                              child: Text(
                                                  '${snapshot.data!['homeStats']!['totalYards']}'),
                                            ),
                                          ]),
                                          TableRow(children: [
                                            Center(
                                              child: Text(
                                                  '${snapshot.data!['awayStats']!['passingYards']}'),
                                            ),
                                            const Center(
                                              child: Text('Passing Yards'),
                                            ),
                                            Center(
                                              child: Text(
                                                  '${snapshot.data!['homeStats']!['passingYards']}'),
                                            ),
                                          ]),
                                          TableRow(children: [
                                            Center(
                                              child: Text(
                                                  '${snapshot.data!['awayStats']!['rushingYards']}'),
                                            ),
                                            const Center(
                                              child: Text('Rushing Yards'),
                                            ),
                                            Center(
                                              child: Text(
                                                  '${snapshot.data!['homeStats']!['rushingYards']}'),
                                            ),
                                          ]),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                          'Date: ${convertDateTimeToEst(model.currGame.date, model.currGame.time)}'),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                          'Time: ${convertUtcTimeToEst(model.currGame.time)}'),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                          'Venue: ${model.currGame.venue}'),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                          '${model.currGame.stage}: ${model.currGame.week}'),
                                    ),
                                  ],
                                );
                              } else {
                                return Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                          'Date: ${convertDateTimeToEst(model.currGame.date, model.currGame.time)}'),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                          'Time: ${convertUtcTimeToEst(model.currGame.time)}'),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                          'Venue: ${model.currGame.venue}'),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                          '${model.currGame.stage}: ${model.currGame.week}'),
                                    ),
                                  ],
                                );
                              }
                            }),
                          ],
                        ),
                      ))),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            }));
  }
}
