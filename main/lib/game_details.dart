import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:main/team.dart';
import 'package:provider/provider.dart';
import 'package:main/games_model.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class OtherView extends StatelessWidget {
  const OtherView({super.key, required this.logos, required this.teams});

  final List<String> logos;
  final List<Team> teams;

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

  @override
  Widget build(BuildContext context) {
    initTimezone();

    return Consumer<GamesModel>(
        builder: (context, model, child) => SafeArea(
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
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                            Text(
                              '${model.currGame.awayTeam}',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            Text(
                              model.currGame.awayScore != null ? '${model.currGame.awayScore}' : '',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                            Text(
                              '${model.currGame.homeTeam}',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            Text(
                              model.currGame.homeScore != null ? '${model.currGame.homeScore}' : '',
                              style: Theme.of(context).textTheme.headlineSmall,
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
                                      child:
                                          Text('${model.currGame.awayBox[0]}')),
                                  Center(
                                      child:
                                          Text('${model.currGame.awayBox[1]}')),
                                  Center(
                                      child:
                                          Text('${model.currGame.awayBox[2]}')),
                                  Center(
                                      child:
                                          Text('${model.currGame.awayBox[3]}')),
                                  Center(
                                      child:
                                          Text('${model.currGame.awayScore}')),
                                ]),
                                TableRow(children: [
                                  Center(
                                      child: Text(getTeamAbbr(
                                          model.currGame.homeTeam))),
                                  Center(
                                      child:
                                          Text('${model.currGame.homeBox[0]}')),
                                  Center(
                                      child:
                                          Text('${model.currGame.homeBox[1]}')),
                                  Center(
                                      child:
                                          Text('${model.currGame.homeBox[2]}')),
                                  Center(
                                      child:
                                          Text('${model.currGame.homeBox[3]}')),
                                  Center(
                                      child:
                                          Text('${model.currGame.homeScore}')),
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
                        Text('Date: ${convertDateTimeToEst(model.currGame.date, model.currGame.time)}'),
                        Text('Time: ${convertUtcTimeToEst(model.currGame.time)}'),
                        Text('Venue: ${model.currGame.venue}'),
                        Text('${model.currGame.stage}: ${model.currGame.week}')
                      ],
                    ),
                  ))),
            ));
  }
}
