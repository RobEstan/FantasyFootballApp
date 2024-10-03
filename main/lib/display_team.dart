import 'package:flutter/material.dart';
import './team.dart';

class DisplayTeam extends StatelessWidget {
  const DisplayTeam({
    super.key,
    required this.team,
  });

  final Team team;

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
                  width: 75,
                  height: 75,
                  child: Hero(
                      tag: team.name,
                      child:
                          Image(image: NetworkImage(team.logo, scale: 1.5)))),
              Text(
                team.name,
                style: Theme.of(context).textTheme.headlineMedium,
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
                  '${team.wins}-${team.losses}-${team.ties}, ${team.divPosition}$ordinalSuffix in ${team.division}');
            }
            return Text(
                '${team.wins}-${team.losses}, ${team.divPosition}$ordinalSuffix in ${team.division}');
          }),
          Text('Abbreviation: ${team.abbreviation}'),
          Text('Coach: ${team.coach}'),
          Text('City: ${team.city}'),
          Text('Stadium: ${team.stadium}'),
          Padding(padding: const EdgeInsets.all(4.0), child: Text('Last Game', style: Theme.of(context).textTheme.bodyLarge,),),
          Builder(builder: (context) {
            if (team.getLastGame() == null) {
              return Text('The ${team.name} have not played a game yet.');
            } else {
              return Column(
                children: [
                  Text('${team.getLastGame()!.awayTeam}: ${team.getLastGame()!.awayScore}'),
                  Text('${team.getLastGame()!.homeTeam}: ${team.getLastGame()!.homeScore}'),
                ],
              );
            }
          }),
          Padding(padding: const EdgeInsets.all(4.0), child: Text('Next Game', style: Theme.of(context).textTheme.bodyLarge,),),
          Builder(builder: (context) {
            if(team.getNextGame() == null) {
              return Text('The ${team.name} do not have any future games.');
            } else {
              return Column(children: [
                Text(team.getNextGame()!.awayTeam!),
                Text(team.getNextGame()!.homeTeam!),
              ],);
            }
          })
        ],
      ),
    ));
  }
}
