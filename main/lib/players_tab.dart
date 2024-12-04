import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:main/display_player.dart';
import 'player.dart';
import 'package:main/favorites_model.dart';
import 'package:provider/provider.dart';

class PlayersTab extends StatefulWidget {
  const PlayersTab({super.key, required this.players});

  final List<Player> players;

  @override
  State<PlayersTab> createState() => _PlayersTab();
}

class _PlayersTab extends State<PlayersTab> {
  final jakeHeaders = {'x-rapidapi-key': 'd5acb40e57a90447afa2bfcba8f332e2'};
  List<Player> searchResults = [];

  void addFoundPlayers() {
    Provider.of<FavoritesModel>(context, listen: false)
        .updateFoundSearch(searchResults);
  }

  Future getSingularPlayer(String name) async {
    var requestSinglePlayer = http.Request(
        'GET',
        Uri.parse(
            'https://v1.american-football.api-sports.io/players?search=$name'));
    requestSinglePlayer.headers.addAll(jakeHeaders);
    http.StreamedResponse response = await requestSinglePlayer.send();

    if (response.statusCode == 200) {
      var jsonData =
          jsonDecode(await response.stream.bytesToString())['response'];
      for (var i = 0; i < jsonData.length; i++) {
        var currPlayer = jsonData[i];
        final Player player = Player(
            id: currPlayer['id'] ?? -1,
            name: currPlayer['name'] ?? 'N/A',
            age: currPlayer['age'] ?? -1,
            height: currPlayer['height'] ?? 'N/A',
            weight: currPlayer['weight'] ?? 'N/A',
            position: currPlayer['position'] ?? 'N/A',
            number: currPlayer['number'] ?? -1,
            image: currPlayer['image'] ?? 'N/A');
        searchResults.add(player);
      }
      addFoundPlayers();
    } else {
      print(response.reasonPhrase);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FavoritesModel>(context, listen: false).clearFoundSearch();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesModel>(
      builder: (context, model, child) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SearchBar(
              shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(0))),
              surfaceTintColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.inversePrimary),
              shadowColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.primary),
              hintText: 'Player Name...',
              hintStyle: const WidgetStatePropertyAll(TextStyle(fontStyle: FontStyle.italic)),
              onSubmitted: (value) async {
                await getSingularPlayer(value);
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
                itemCount: model.foundSearch.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryFixedDim,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(model.foundSearch[index].name),
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(0),
                              child: IconButton(
                                onPressed: () {
                                  model.addFavPlayer(model.foundSearch[index]);
                                },
                                icon: model.isFavPlayer(model.foundSearch[index].id)
                                    ? const Icon(
                                        Icons.star,
                                        color: Colors.yellow,
                                      )
                                    : const Icon(
                                        Icons.star_border,
                                        color: Colors.black,
                                      ),
                                iconSize: 35.0,
                              ),
                            ),
                            SizedBox(
                              width: 70,
                              height: 70,
                              child: Image(
                                  image: NetworkImage(
                                model.foundSearch[index].image,
                              )),
                            ),
                          ],
                        ),
                        subtitle: Text(model.foundSearch[index].name),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DisplayPlayer(
                                      player: model.foundSearch[index],
                                      showAppBar: true)));
                        },
                      ),
                    ),
                  );
                }),
          )
        ],
      ),
    );
  }
  // Widget build(BuildContext context) {
  //   return Consumer<FavoritesModel>(
  //     builder: (context, model, child) => ListView.builder(
  //         itemCount: 8,
  //         itemBuilder: (context, index) {
  //           return Padding(
  //             padding: const EdgeInsets.all(8.0),
  //             child: Container(
  //               decoration: BoxDecoration(
  //                   color: Theme.of(context).colorScheme.primaryFixedDim,
  //               ),
  //               child: ListTile(
  //                 title: Text(widget.players[index].name),
  //                 leading: Row (
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     Container(
  //                       width: 70,
  //                       height: 70,
  //                       child: Image(
  //                           image: NetworkImage(
  //                         widget.players[index].image,
  //                       )),
  //                     ),
  //                     Padding(
  //                       padding: const EdgeInsets.all(0),
  //                       child: IconButton(
  //                         onPressed: () {
  //                           model.addFavPlayer(widget.players[index]);
  //                         },
  //                         icon: model.isFavPlayer(widget.players[index])
  //                           ? const Icon(
  //                             Icons.star,
  //                             color: Colors.yellow,
  //                           )
  //                         : const Icon(Icons.star_border, color: Colors.black,),
  //                         iconSize: 35.0,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //                 subtitle: Text(widget.players[index].name),
  //                 onTap: () {
  //                   Navigator.push(
  //                     context,
  //                     MaterialPageRoute(
  //                       builder: (context) =>
  //                         DisplayPlayer(player: widget.players[index], showAppBar: true)
  //                     )
  //                   );
  //                 },

  //               ),
  //             ),
  //           );
  //         }

  //     )
  //   );
  // }
}
