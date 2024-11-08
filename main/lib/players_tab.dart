import 'package:flutter/material.dart';
import 'package:main/display_player.dart';
import 'player.dart';
import 'package:main/favorites_model.dart';
import 'package:provider/provider.dart';

class PlayersTab extends StatefulWidget{
  const PlayersTab({super.key, required this.players});

  final List<Player> players; 

  @override
  State<PlayersTab> createState() => _PlayersTab();
}

class _PlayersTab extends State<PlayersTab> {

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesModel>(
      builder: (context, model, child) => ListView.builder(
          itemCount: 8,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryFixedDim,
                ),
                child: ListTile(
                  title: Text(widget.players[index].name),
                  leading: Row (
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        child: Image(
                            image: NetworkImage(
                          widget.players[index].image,
                        )),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(0),
                        child: IconButton(
                          onPressed: () {
                            model.addFavPlayer(widget.players[index]);
                          },
                          icon: model.isFavPlayer(widget.players[index])
                            ? const Icon(
                              Icons.star,
                              color: Colors.yellow,
                            )
                          : const Icon(Icons.star_border, color: Colors.black,),
                          iconSize: 35.0,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(widget.players[index].name),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                          DisplayPlayer(player: widget.players[index], showAppBar: true)
                      )
                    );
                  },

                ),
              ),
            );
          }
           
      )
    );
  }
}