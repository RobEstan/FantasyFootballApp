import 'package:flutter/material.dart';
import 'player.dart';

class PlayersTab extends StatefulWidget{
  const PlayersTab({super.key, required this.players});

  final List<Player> players; 

  @override
  State<PlayersTab> createState() => _PlayersTab();
}

class _PlayersTab extends State<PlayersTab> {

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: ListView.builder(
      itemCount: widget.players.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryFixedDim,),
                child: ListTile(
                  title: Text(widget.players[index].name),
                  leading: Container(
                    width: 70,
                    height: 70,
                    child: Image(
                        image: NetworkImage(
                      widget.players[index].image,
                    )),
                  ),
                  subtitle: Text(widget.players[index].name),
                  //onTap: () {
                  //  Navigator.push(
                  //      context,
                  //      MaterialPageRoute(
                  //          builder: (context) =>
                  //              DisplayTeam(team: widget.teams[index])));
                  //},
                ),
              ),
            );
          }
           
      )
    );
  }
}