import 'package:flutter/material.dart';
import 'package:main/favorites_model.dart';
import './display_team.dart';
import './team.dart';
import 'package:provider/provider.dart';

class TeamsTab extends StatefulWidget {
  const TeamsTab({super.key, required this.teams});

  final List<Team> teams;

  @override
  State<TeamsTab> createState() => _TeamsTab();
}

class _TeamsTab extends State<TeamsTab> {
  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesModel>(
        builder: (context, model, child) => ListView.builder(
            itemCount: 32,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                    title: Text(widget.teams[index].abbreviation),
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(0),
                          child: IconButton(
                            onPressed: () {
                              model.editFavTeams(widget.teams[index]);
                            },
                            icon: model.isFavTeam(widget.teams[index])
                                ? const Icon(
                                    Icons.star,
                                    color: Colors.yellow,
                                  )
                                : const Icon(Icons.star_border),
                            iconSize: 35.0,
                          ),
                        ),
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: Hero(
                            tag: widget.teams[index].name,
                            child: Image(
                                image: NetworkImage(
                              widget.teams[index].logo,
                            )),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(widget.teams[index].name),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DisplayTeam(
                                    team: widget.teams[index],
                                    teams: widget.teams,
                                  )));
                    },
                  ),
                ),
              );
            }));
  }
}
