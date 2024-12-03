import 'package:flutter/material.dart';
import 'package:main/game_details.dart';
import 'package:main/team.dart';
import 'package:main/game.dart';
import 'package:provider/provider.dart';
import 'package:main/games_model.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class ScoresTab extends StatefulWidget {
  const ScoresTab({super.key, required this.teams, required this.games});

  final List<Team> teams;
  final List<Game> games;

  @override
  State<ScoresTab> createState() => _ScoresTab();
}

// Returns the Team specified by target from the teams list
Team getTeamFromTeams(List<Team> teams, String target) {
  for (var i = 0; i < teams.length; i++) {
    if (teams[i].name == target) {
      return teams[i];
    }
  }
  return Team(
      abbreviation: 'null',
      name: 'null',
      city: 'null',
      coach: 'null',
      stadium: 'null',
      logo: 'null',
      id: 0);
}

class _ScoresTab extends State<ScoresTab> {
  int currWeek = 1;
  late List<Game> items;
  late List<List<String>> icons;

  void getWeeksGames(String week) {
    items = [];
    icons = [];
    // For each NFL game in the week specified, this loop adds the game to the items list
    // and adds a list of two icons (one for each team) to the icons list
    for (var i = 0; i < widget.games.length; i++) {
      if (widget.games[i].week == week &&
          widget.games[i].stage == 'Regular Season') {
        items.add(widget.games[i]);
        icons.add([
          getTeamFromTeams(widget.teams, widget.games[i].awayTeam!).logo,
          getTeamFromTeams(widget.teams, widget.games[i].homeTeam!).logo
        ]);
      }
    }
  }

  void getCurrentWeek() {
    for (var i = 0; i < widget.games.length; i++) {
      if (widget.games[i].status == "Not Started" &&
          widget.games[i].stage == "Regular Season") {
        currWeek = int.parse(widget.games[i].week.split(" ")[1]);
        break;
      }
    }
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
      for (Team t in widget.teams) {
        if (t.name == teamName) {
          if (t.name == "Los Angeles Rams") {
            return "${t.abbreviation}R";
          }
          return t.abbreviation;
        }
      }
    }
    return 'Team Not Found';
  }

  String getQuarter(String gameStatus) {
    if (gameStatus == "First Quarter") {
      return 'Q1';
    } else if (gameStatus == "Second Quarter") {
      return 'Q2';
    } else if (gameStatus == "Halftime") {
      return 'Half';
    } else if (gameStatus == "Third Quarter") {
      return 'Q3';
    } else if (gameStatus == "Fourth Quarter") {
      return 'Q4';
    } else {
      return 'OT';
    }
  }

  bool homeWins(Game game) {
    return game.homeScore! > game.awayScore!;
  }

  @override
  void initState() {
    getCurrentWeek();
    getWeeksGames('Week $currWeek');
    tz.initializeTimeZones();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  onPressed: currWeek > 1
                      ? () {
                          setState(() {
                            currWeek--;
                            getWeeksGames('Week $currWeek');
                          });
                        }
                      : null,
                  icon: const Icon(Icons.arrow_back)),
              Text('Week $currWeek'),
              IconButton(
                  onPressed: currWeek < 18
                      ? () {
                          setState(() {
                            currWeek++;
                            getWeeksGames('Week $currWeek');
                          });
                        }
                      : null,
                  icon: const Icon(Icons.arrow_forward)),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: LayoutBuilder(
                      builder: (context, constraints) => Column(
                            children: [
                              const Divider(
                                color: Colors.black,
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                child: Builder(builder: (context) {
                                  if (items[index].homeScore != null ||
                                      items[index].awayScore != null) {
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Builder(builder: (context) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 8.0,
                                                  right: 8.0,
                                                ),
                                                child: SizedBox(
                                                    width: 50,
                                                    height: 50,
                                                    child: Image(
                                                        image: NetworkImage(
                                                            icons[index][0]))),
                                              );
                                            }),
                                            Builder(builder: (context) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 8.0,
                                                  right: 8.0,
                                                ),
                                                child: SizedBox(
                                                    width: 50,
                                                    height: 50,
                                                    child: Image(
                                                        image: NetworkImage(
                                                            icons[index][1]))),
                                              );
                                            }),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 75,
                                              height: 50,
                                              child: Text(
                                                getTeamAbbr(
                                                    items[index].awayTeam),
                                                style: !homeWins(items[index]) && (items[index].status == "Finished" || items[index].status == "After Over Time") ? Theme.of(context)
                                                    .textTheme
                                                    .headlineMedium!.copyWith(fontWeight: FontWeight.bold) :
                                                    Theme.of(context)
                                                  .textTheme
                                                  .headlineMedium,
                                              ),
                                            ),
                                            Text(
                                                getTeamAbbr(
                                                    items[index].homeTeam),
                                                style: homeWins(items[index]) && (items[index].status == "Finished" || items[index].status == "After Over Time") ? Theme.of(context)
                                                    .textTheme
                                                    .headlineMedium!.copyWith(fontWeight: FontWeight.bold) :
                                                    Theme.of(context)
                                                  .textTheme
                                                  .headlineMedium,)
                                          ],
                                        ),
                                        const SizedBox(
                                          width: 50,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              height: 50,
                                              child: Text(
                                                '${items[index].awayScore}',
                                                style: !homeWins(items[index]) && (items[index].status == "Finished" || items[index].status == "After Over Time") ? Theme.of(context)
                                                    .textTheme
                                                    .headlineMedium!.copyWith(fontWeight: FontWeight.bold) : 
                                                    Theme.of(context)
                                                  .textTheme
                                                  .headlineMedium,
                                              ),
                                            ),
                                            Text(
                                              '${items[index].homeScore}',
                                              style: homeWins(items[index]) && (items[index].status == "Finished" || items[index].status == "After Over Time") ? Theme.of(context)
                                                  .textTheme
                                                  .headlineMedium!.copyWith(fontWeight: FontWeight.bold) : 
                                                  Theme.of(context)
                                                  .textTheme
                                                  .headlineMedium,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          width: 25,
                                        ),
                                        Builder(builder: (context) {
                                          if (items[index].status ==
                                              "Finished") {
                                            return Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Final',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headlineSmall,
                                                ),
                                              ],
                                            );
                                          } else if (items[index].status ==
                                              "After Over Time") {
                                            return Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Final',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headlineSmall,
                                                ),
                                                Text(
                                                  'OT',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headlineSmall,
                                                ),
                                              ],
                                            );
                                          } else if (items[index].status ==
                                              "Not Started") {
                                            return Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  convertDateTimeToEst(
                                                      items[index].date,
                                                      items[index].time),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headlineSmall,
                                                ),
                                                Text(
                                                  convertUtcTimeToEst(
                                                      items[index].time),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headlineSmall,
                                                ),
                                              ],
                                            );
                                          } else {
                                            return Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Text(getQuarter(items[index].status), style: Theme.of(context).textTheme.headlineSmall,)
                                                ],
                                              );
                                          }
                                        }),
                                      ],
                                    );
                                  } else {
                                    return Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Builder(builder: (context) {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      left: 8.0,
                                                      right: 8.0,
                                                    ),
                                                    child: SizedBox(
                                                        width: 50,
                                                        height: 50,
                                                        child: Image(
                                                            image: NetworkImage(
                                                                icons[index]
                                                                    [0]))),
                                                  );
                                                }),
                                                Text(
                                                  getTeamAbbr(items[index].awayTeam),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headlineMedium,
                                                ),
                                              ],
                                            ),
                                            const Spacer(),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 25.0, 20.0, 0),
                                              child: Text(convertDateTimeToEst(
                                                  items[index].date,
                                                  items[index].time), style: Theme.of(context).textTheme.headlineMedium,),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Builder(builder: (context) {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      left: 8.0,
                                                      right: 8.0,
                                                    ),
                                                    child: SizedBox(
                                                        width: 50,
                                                        height: 50,
                                                        child: Image(
                                                            image: NetworkImage(
                                                                icons[index]
                                                                    [1]))),
                                                  );
                                                }),
                                                Text(getTeamAbbr(items[index].homeTeam),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headlineMedium),
                                              ],
                                            ),
                                            const Spacer(),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 0, 12.0, 25.0),
                                              child: Text(convertUtcTimeToEst(
                                                  items[index].time), style: Theme.of(context).textTheme.headlineMedium,),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  }
                                }),
                                onTap: () {
                                  Provider.of<GamesModel>(context,
                                          listen: false)
                                      .editCurrGame(items[index]);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => OtherView(
                                            logos: icons[index],
                                            teams: widget.teams),
                                      ));
                                },
                              ),
                              const Divider(
                                color: Colors.black,
                              ),
                            ],
                          )),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
