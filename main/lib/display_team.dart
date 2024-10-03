import 'package:flutter/material.dart';
import './team.dart';

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
                SizedBox(width: 75, height: 75, child: Hero(tag: team.name, child: Image(image: NetworkImage(team.logo, scale: 1.5)))),
                Text(team.name, style: Theme.of(context).textTheme.headlineMedium,)
              ],
            ),
          Text('${team.wins}-${team.losses}-${team.ties}, ${team.divPosition} in ${team.division}'),
          Text('Abbreviation: ${team.abbreviation}'),
          Text('Coach: ${team.coach}'),
          Text('City: ${team.city}'),
          Text('Stadium: ${team.stadium}'),
        ],
      ),
    ));
  }
}