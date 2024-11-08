import 'package:flutter/material.dart';
import 'package:main/game_details.dart';
import 'package:main/team.dart';
import 'package:main/game.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:main/games_model.dart';

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
  @override
  Widget build(BuildContext context) {
    var items = [];
    var icons = [];

    // For each NFL game in the week specified, this loop adds the game to the items list 
    // and adds a list of two icons (one for each team) to the icons list
    for (var i = 0; i < widget.games.length; i++) {
      if (widget.games[i].week == 'Week 7') {
        items.add(widget.games[i]);
        icons.add([getTeamFromTeams(widget.teams, widget.games[i].awayTeam!).logo, 
          getTeamFromTeams(widget.teams, widget.games[i].homeTeam!).logo]);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Week 7',)),
      ),
      body: 
        ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: LayoutBuilder(
                builder: (context, constraints) => 
                  GestureDetector(
                    child:
                      Center(child: Text('${items[index].awayTeam} at ${items[index].homeTeam} (${items[index].awayScore} - ${items[index].homeScore})')),
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
    );
  }
}
//}