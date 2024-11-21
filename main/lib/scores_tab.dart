import 'package:flutter/material.dart';
import 'package:main/game_details.dart';
import 'package:main/team.dart';
import 'package:main/game.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:main/games_model.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class ScoresTab extends StatefulWidget{
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
  return Team(abbreviation: 'null', name: 'null', city: 'null', coach: 'null', stadium: 'null', logo: 'null', id: 0);
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
      if (widget.games[i].week == week && widget.games[i].stage == 'Regular Season') {
        items.add(widget.games[i]);
        icons.add([getTeamFromTeams(widget.teams, widget.games[i].awayTeam!).logo, 
          getTeamFromTeams(widget.teams, widget.games[i].homeTeam!).logo]);
      }
    }
  }

  void getCurrentWeek() {
    for (var i = 0; i < widget.games.length; i++) {
      if (widget.games[i].status == "Not Started" && widget.games[i].stage == "Regular Season") {
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

  String convertDate(String date) {
    List<String> dateAsList = date.split('-');
    return '${dateAsList[1]}/${dateAsList[2]}';
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
        title: Padding(padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(onPressed: currWeek > 1 ? () {
                  setState(() {
                    currWeek--;
                    getWeeksGames('Week $currWeek');
                  });
                } : null, icon: const Icon(Icons.arrow_back)),
                Text('Week $currWeek'),
                IconButton(onPressed: currWeek < 18 ? () {
                  setState(() {
                    currWeek++;
                    getWeeksGames('Week $currWeek');
                  });
                } : null, icon: const Icon(Icons.arrow_forward)),
              ],
            ),),
      ),
      body: 
        Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: LayoutBuilder(
                      builder: (context, constraints) => 
                        GestureDetector(
                          child:
                            Builder(builder: (context) {
                              if (items[index].awayScore == null) {
                                return Center(child: Text('${items[index].awayTeam} at ${items[index].homeTeam} on ${convertDate(items[index].date)} at ${convertUtcTimeToEst(
                                          items[index].time)}'));
                              } else {
                                return Center(child: Text('${items[index].awayTeam} at ${items[index].homeTeam} (${items[index].awayScore} - ${items[index].homeScore})'));
                              }
                            }),
                          onTap: () {
                            Provider.of<GamesModel>(context, listen: false).editCurrGame(items[index]);
                            Navigator.push(
                              context,
                                MaterialPageRoute(
                                  builder: (context) => OtherView(logos: icons[index]),
                                )
                            );
                          },
                        )
                    ),
                    leading: SizedBox(
                      height: 30, 
                      width: 30, 
                      child: CachedNetworkImage(
                        imageUrl: icons[index][0],
                        progressIndicatorBuilder: (context, url, downloadProgress) => 
                          CircularProgressIndicator(value: downloadProgress.progress),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      ),
                    ),
                    trailing: SizedBox(
                      height: 30, 
                      width: 30, 
                      child: CachedNetworkImage(
                        imageUrl: icons[index][1],
                        progressIndicatorBuilder: (context, url, downloadProgress) => 
                          CircularProgressIndicator(value: downloadProgress.progress),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      ),
                    ),  
                  );
                },
              ),
            ),
          ],
        ),
    );
  }
}