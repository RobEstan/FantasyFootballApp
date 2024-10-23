import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './favorites_model.dart';
import './team.dart';

class DisplayTeam extends StatefulWidget {
  const DisplayTeam({
    super.key,
    required this.team,
    required this.teams,
  });

  final Team team;
  final List<Team> teams;

  @override
  State<DisplayTeam> createState() => _DisplayTeam();
}

class _DisplayTeam extends State<DisplayTeam> {
  String? getOpponentLogo(String opponentName) {
    for (var i = 0; i < widget.teams.length; i++) {
      if (widget.teams[i].name == opponentName) {
        return widget.teams[i].logo;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesModel>(builder: (context, model, child) =>
      SafeArea(
          child: Scaffold(
        // appBar: AppBar(
        //   title: Text(widget.team.name),
        //   backgroundColor: Theme.of(context).colorScheme.primary,
        //   actions: [
        //     IconButton(
        //         onPressed: () {
        //           model.editFavTeams(widget.team);
        //         },
        //         icon: model.isFavTeam(widget.team)
        //             ? const Icon(
        //                 Icons.star,
        //                 color: Colors.yellow,
        //               )
        //             : const Icon(Icons.star_border),
        //         iconSize: 35.0,
        //       ),
        //   ],
        // ),
        body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                    width: 100,
                    height: 100,
                    child: Hero(
                        tag: widget.team.name,
                        child: Image(
                            image:
                                NetworkImage(widget.team.logo, scale: 1.5)))),
                Text(
                  widget.team.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                )
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
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Builder(builder: (context) {
                  if (widget.team.getLastGame() == null) {
                    return Text(
                        'The ${widget.team.name} have not played a game yet.');
                  } else {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Builder(builder: (context) {
                                  var awayTeamName =
                                      widget.team.getLastGame()!.awayTeam;
                                  dynamic awayTeamLogo;
                                  if (awayTeamName != widget.team.name) {
                                    awayTeamLogo = getOpponentLogo(
                                        widget.team.getLastGame()!.awayTeam!);
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
                                            image: NetworkImage(awayTeamLogo))),
                                  );
                                }),
                                Text(
                                  '${widget.team.getLastGame()!.awayTeam}: ${widget.team.getLastGame()!.awayScore}',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Builder(builder: (context) {
                                  var homeTeamName =
                                      widget.team.getLastGame()!.homeTeam;
                                  dynamic homeTeamLogo;
                                  if (homeTeamName != widget.team.name) {
                                    homeTeamLogo = getOpponentLogo(
                                        widget.team.getLastGame()!.homeTeam!);
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
                                            image: NetworkImage(homeTeamLogo))),
                                  );
                                }),
                                Text(
                                    '${widget.team.getLastGame()!.homeTeam}: ${widget.team.getLastGame()!.homeScore}',
                                    style:
                                        Theme.of(context).textTheme.bodyLarge),
                              ],
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                }),
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
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Builder(builder: (context) {
                  if (widget.team.getNextGame() == null) {
                    return Text(
                        'The ${widget.team.name} do not have any future games.');
                  } else {
                    return Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Builder(builder: (context) {
                                  var awayTeamName =
                                      widget.team.getNextGame()!.awayTeam;
                                  dynamic awayTeamLogo;
                                  if (awayTeamName != widget.team.name) {
                                    awayTeamLogo = getOpponentLogo(
                                        widget.team.getNextGame()!.awayTeam!);
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
                                            image: NetworkImage(awayTeamLogo))),
                                  );
                                }),
                                Text(widget.team.getNextGame()!.awayTeam!,
                                    style:
                                        Theme.of(context).textTheme.bodyLarge),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Builder(builder: (context) {
                                  var homeTeamName =
                                      widget.team.getNextGame()!.homeTeam;
                                  dynamic homeTeamLogo;
                                  if (homeTeamName != widget.team.name) {
                                    homeTeamLogo = getOpponentLogo(
                                        widget.team.getNextGame()!.homeTeam!);
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
                                            image: NetworkImage(homeTeamLogo))),
                                  );
                                }),
                                Text(widget.team.getNextGame()!.homeTeam!,
                                    style:
                                        Theme.of(context).textTheme.bodyLarge),
                              ],
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                }),
              ),
            )
          ],
        ),
      ))
    );
  }
}
