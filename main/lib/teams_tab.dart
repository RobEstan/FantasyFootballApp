import 'package:flutter/material.dart';
import './display_team.dart';
import './team.dart';

class TeamsTab extends StatefulWidget {
  const TeamsTab({super.key, required this.teams});

  final List<Team> teams;

  @override
  State<TeamsTab> createState() => _TeamsTab();
}

class _TeamsTab extends State<TeamsTab> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: 32,
        itemBuilder: (context, index) {
          return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(widget.teams[index].abbreviation),
                  leading: Container(
                    width: 50,
                    height: 50,
                    child: Image(
                        image: NetworkImage(
                      widget.teams[index].logo,
                    )),
                  ),
                  subtitle: Text(widget.teams[index].name),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                DisplayTeam(team: widget.teams[index])));
                  },
                ),
              ),
            );
        });
  }
}
