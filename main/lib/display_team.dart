import 'package:flutter/material.dart';
import './team.dart';
// import './player.dart';

class DisplayTeam extends StatelessWidget{
  const DisplayTeam({super.key, required this.team,});

  final Team team;

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      appBar: AppBar(
        title: Text(team.name),
        backgroundColor: Theme.of(context).colorScheme.primary
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(width: 75, height: 75, child: Image(image: NetworkImage(team.logo, scale: 1.5))),
                Text(team.name, style: Theme.of(context).textTheme.headlineLarge,)
              ],
            ),
          Text('Abbreviation: ${team.abbreviation}'),
          Text('Coach: ${team.coach}'),
          Text('City: ${team.city}'),
          Text('Stadium: ${team.stadium}'),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //   children: [
          //     Image(image: NetworkImage(players[0].image, scale: 1.5),),
          //     Text('${players[0].position} #${players[0].number} ${players[0].name}', style: Theme.of(context).textTheme.bodySmall,)
          //   ],
          // )
        ],
      ),
    ));
  }
}