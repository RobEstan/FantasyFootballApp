import 'package:flutter/material.dart';
import './team.dart';

class DisplayTeam extends StatelessWidget{
  const DisplayTeam({super.key, required this.team});

  final Team team;

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      appBar: AppBar(
        title: Text(team.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image(image: NetworkImage(team.logo, scale: 1.5)),
                Text(team.name, style: Theme.of(context).textTheme.headlineLarge,)
              ],
            ),
          Text('Abbreviation: ' + team.abbreviation),
          Text('Coach: ' + team.coach),
          Text('City: ' + team.city),
          Text('Stadium: ' + team.stadium),
        ],
      ),
    ));
  }
}