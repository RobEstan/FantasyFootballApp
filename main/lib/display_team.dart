import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import './favorites_model.dart';
import './team.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

int notifId = 0;

class DisplayTeam extends StatefulWidget {
  const DisplayTeam({
    super.key,
    required this.team,
    required this.teams,
    required this.showAppBar,
  });

  final Team team;
  final List<Team> teams;
  final bool showAppBar;

  @override
  State<DisplayTeam> createState() => _DisplayTeam();
}

class _DisplayTeam extends State<DisplayTeam> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  String? getOpponentLogo(String opponentName) {
    for (var i = 0; i < widget.teams.length; i++) {
      if (widget.teams[i].name == opponentName) {
        return widget.teams[i].logo;
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/New_York'));
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

  String justTeamName(String team) {
    final teamList = team.split(' ');
    return teamList[teamList.length - 1];
  }

  Future<void> showNotification() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('your channel id', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker',
            icon: '@drawable/ic_launcher_foreground',
            color: Colors.black);
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
      notifId++,
      'Final Score',
      '${getTeamAbbr(widget.team.getLastGame()!.awayTeam)} ${widget.team.getLastGame()!.awayScore} - ${getTeamAbbr(widget.team.getLastGame()!.homeTeam)} ${widget.team.getLastGame()!.homeScore}',
      notificationDetails,
      payload: 'item x',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesModel>(
        builder: (context, model, child) => SafeArea(
                child: Scaffold(
              appBar: widget.showAppBar
                  ? AppBar(
                      title: Text(widget.team.name),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      actions: [
                        IconButton(
                          onPressed: () {
                            model.editFavTeams(widget.team);
                          },
                          icon: model.isFavTeam(widget.team)
                              ? const Icon(
                                  Icons.star,
                                  color: Colors.yellow,
                                )
                              : const Icon(
                                  Icons.star_border,
                                  color: Colors.black,
                                ),
                          iconSize: 35.0,
                        ),
                      ],
                    )
                  : null,
              body: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                            width: 100,
                            height: 100,
                            child: Hero(
                                tag: widget.team.name,
                                child: Image(
                                    image: NetworkImage(widget.team.logo,
                                        scale: 1.5)))),
                      ],
                    ),
                    Builder(builder: (context) {
                      var ordinalSuffix = '';
                      if (widget.team.divPosition == 1) {
                        ordinalSuffix = 'st';
                      } else if (widget.team.divPosition == 2) {
                        ordinalSuffix = 'nd';
                      } else if (widget.team.divPosition == 3) {
                        ordinalSuffix = 'rd';
                      } else {
                        ordinalSuffix = 'th';
                      }
                      if (widget.team.ties! > 0) {
                        return Text(
                            '${widget.team.wins}-${widget.team.losses}-${widget.team.ties}, ${widget.team.divPosition}$ordinalSuffix in ${widget.team.division}',
                            style: Theme.of(context).textTheme.bodyLarge);
                      }
                      return Text(
                          '${widget.team.wins}-${widget.team.losses}, ${widget.team.divPosition}$ordinalSuffix in ${widget.team.division}',
                          style: Theme.of(context).textTheme.bodyLarge);
                    }),
                    Text('Abbreviation: ${widget.team.abbreviation}',
                        style: Theme.of(context).textTheme.bodyLarge),
                    Text('Coach: ${widget.team.coach}',
                        style: Theme.of(context).textTheme.bodyLarge),
                    Text('City: ${widget.team.city}',
                        style: Theme.of(context).textTheme.bodyLarge),
                    Text('Stadium: ${widget.team.stadium}',
                        style: Theme.of(context).textTheme.bodyLarge),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 50.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Last Game',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          const Divider(
                            color: Colors.black,
                          ),
                          Builder(builder: (context) {
                            if (widget.team.getLastGame() == null) {
                              return Text(
                                  'The ${widget.team.name} have not played a game yet.');
                            } else {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Builder(builder: (context) {
                                            var awayTeamName = widget.team
                                                .getLastGame()!
                                                .awayTeam;
                                            dynamic awayTeamLogo;
                                            if (awayTeamName !=
                                                widget.team.name) {
                                              awayTeamLogo = getOpponentLogo(
                                                  widget.team
                                                      .getLastGame()!
                                                      .awayTeam!);
                                            } else {
                                              awayTeamLogo = widget.team.logo;
                                            }
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
                                                          awayTeamLogo))),
                                            );
                                          }),
                                          Text(
                                            '${widget.team.getLastGame()!.awayTeam}: ${widget.team.getLastGame()!.awayScore}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge,
                                          ),
                                        ],
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
                                            var homeTeamName = widget.team
                                                .getLastGame()!
                                                .homeTeam;
                                            dynamic homeTeamLogo;
                                            if (homeTeamName !=
                                                widget.team.name) {
                                              homeTeamLogo = getOpponentLogo(
                                                  widget.team
                                                      .getLastGame()!
                                                      .homeTeam!);
                                            } else {
                                              homeTeamLogo = widget.team.logo;
                                            }
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
                                                          homeTeamLogo))),
                                            );
                                          }),
                                          Text(
                                              '${widget.team.getLastGame()!.homeTeam}: ${widget.team.getLastGame()!.homeScore}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            }
                          }),
                          const Divider(
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 50.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Next Game',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 50.0),
                      child: Column(
                        children: [
                          const Divider(
                            color: Colors.black,
                          ),
                          Builder(builder: (context) {
                            if (widget.team.getNextGame() == null) {
                              return Text(
                                  'The ${widget.team.name} do not have any future games.');
                            } else {
                              return Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          Builder(builder: (context) {
                                            var awayTeamName = widget.team
                                                .getNextGame()!
                                                .awayTeam;
                                            dynamic awayTeamLogo;
                                            if (awayTeamName !=
                                                widget.team.name) {
                                              awayTeamLogo = getOpponentLogo(
                                                  widget.team
                                                      .getNextGame()!
                                                      .awayTeam!);
                                            } else {
                                              awayTeamLogo = widget.team.logo;
                                            }
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
                                                          awayTeamLogo))),
                                            );
                                          }),
                                          Text(
                                              widget.team
                                                  .getNextGame()!
                                                  .awayTeam!,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge),
                                        ],
                                      ),
                                      const Spacer(),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 25.0, 20.0, 0),
                                        child: Text(convertDateTimeToEst(
                                            widget.team.getNextGame()!.date,
                                            widget.team.getNextGame()!.time)),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          Builder(builder: (context) {
                                            var homeTeamName = widget.team
                                                .getNextGame()!
                                                .homeTeam;
                                            dynamic homeTeamLogo;
                                            if (homeTeamName !=
                                                widget.team.name) {
                                              homeTeamLogo = getOpponentLogo(
                                                  widget.team
                                                      .getNextGame()!
                                                      .homeTeam!);
                                            } else {
                                              homeTeamLogo = widget.team.logo;
                                            }
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
                                                          homeTeamLogo))),
                                            );
                                          }),
                                          Text(
                                              widget.team
                                                  .getNextGame()!
                                                  .homeTeam!,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge),
                                        ],
                                      ),
                                      const Spacer(),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 0, 12.0, 25.0),
                                        child: Text(convertUtcTimeToEst(
                                            widget.team.getNextGame()!.time)),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            }
                          }),
                          const Divider(
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              floatingActionButton: model.notificationsOn
                  ? FloatingActionButton(
                      onPressed: () async {
                        await showNotification();
                      },
                      child: const Icon(Icons.notifications_active),
                    )
                  : null,
            )));
  }
}
