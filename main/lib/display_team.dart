import 'package:flutter/material.dart';
import './team.dart';

class DisplayTeam extends StatelessWidget {
  const DisplayTeam({
    super.key,
    required this.team,
    required this.teams,
  });

  final Team team;
  final List<Team> teams;

  String? getOpponentLogo(String opponentName) {
    for (var i = 0; i < teams.length; i++) {
      if (teams[i].name == opponentName) {
        return teams[i].logo;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
          title: Text(team.name),
          backgroundColor: Theme.of(context).colorScheme.primary),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                  width: 100,
                  height: 100,
                  child: Hero(
                      tag: team.name,
                      child:
                          Image(image: NetworkImage(team.logo, scale: 1.5)))),
              Text(
                team.name,
                style: Theme.of(context).textTheme.headlineSmall,
              )
            ],
          ),
          Builder(builder: (context) {
            var ordinalSuffix = '';
            if (team.divPosition == 1) {
              ordinalSuffix = 'st';
            } else if (team.divPosition == 2) {
              ordinalSuffix = 'nd';
            } else if (team.divPosition == 3) {
              ordinalSuffix = 'rd';
            } else {
              ordinalSuffix = 'th';
            }
            if (team.ties! > 0) {
              return Text(
                  '${team.wins}-${team.losses}-${team.ties}, ${team.divPosition}$ordinalSuffix in ${team.division}', style: Theme.of(context).textTheme.bodyLarge);
            }
            return Text(
                '${team.wins}-${team.losses}, ${team.divPosition}$ordinalSuffix in ${team.division}', style: Theme.of(context).textTheme.bodyLarge);
          }),
          Text('Abbreviation: ${team.abbreviation}', style: Theme.of(context).textTheme.bodyLarge),
          Text('Coach: ${team.coach}', style: Theme.of(context).textTheme.bodyLarge),
          Text('City: ${team.city}', style: Theme.of(context).textTheme.bodyLarge),
          Text('Stadium: ${team.stadium}', style: Theme.of(context).textTheme.bodyLarge),
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
                if (team.getLastGame() == null) {
                  return Text('The ${team.name} have not played a game yet.');
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
                                var awayTeamName = team.getLastGame()!.awayTeam;
                                dynamic awayTeamLogo;
                                if (awayTeamName != team.name) {
                                  awayTeamLogo = getOpponentLogo(team.getLastGame()!.awayTeam!);
                                } else {
                                  awayTeamLogo = team.logo;
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 8.0,),
                                  child: SizedBox(width: 50, height: 50, child: Image(image: NetworkImage(awayTeamLogo))),
                                );
                              }),
                              Text(
                                  '${team.getLastGame()!.awayTeam}: ${team.getLastGame()!.awayScore}', style: Theme.of(context).textTheme.bodyLarge,),
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
                                var homeTeamName = team.getLastGame()!.homeTeam;
                                dynamic homeTeamLogo;
                                if (homeTeamName != team.name) {
                                  homeTeamLogo = getOpponentLogo(team.getLastGame()!.homeTeam!);
                                } else {
                                  homeTeamLogo = team.logo;
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 8.0,),
                                  child: SizedBox(width: 50, height: 50, child: Image(image: NetworkImage(homeTeamLogo))),
                                );
                              }),
                              Text(
                                  '${team.getLastGame()!.homeTeam}: ${team.getLastGame()!.homeScore}', style: Theme.of(context).textTheme.bodyLarge),
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
                if (team.getNextGame() == null) {
                  return Text('The ${team.name} do not have any future games.');
                } else {
                  return Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Builder(builder: (context) {
                                var awayTeamName = team.getNextGame()!.awayTeam;
                                dynamic awayTeamLogo;
                                if (awayTeamName != team.name) {
                                  awayTeamLogo = getOpponentLogo(team.getNextGame()!.awayTeam!);
                                } else {
                                  awayTeamLogo = team.logo;
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 8.0,),
                                  child: SizedBox(width: 50, height: 50, child: Image(image: NetworkImage(awayTeamLogo))),
                                );
                              }),
                              Text(team.getNextGame()!.awayTeam!, style: Theme.of(context).textTheme.bodyLarge),
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
                                var homeTeamName = team.getNextGame()!.homeTeam;
                                dynamic homeTeamLogo;
                                if (homeTeamName != team.name) {
                                  homeTeamLogo = getOpponentLogo(team.getNextGame()!.homeTeam!);
                                } else {
                                  homeTeamLogo = team.logo;
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 8.0,),
                                  child: SizedBox(width: 50, height: 50, child: Image(image: NetworkImage(homeTeamLogo))),
                                );
                              }),
                              Text(team.getNextGame()!.homeTeam!, style: Theme.of(context).textTheme.bodyLarge),
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
    ));
  }
}
