import 'package:flutter/material.dart';
import './player.dart';

class DisplayPlayer extends StatelessWidget {
  const DisplayPlayer({
    super.key,
    required this.player,
    required this.showAppBar,
  });

  final Player player;
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: showAppBar ? AppBar(
          title: Text(player.name),
          backgroundColor: Theme.of(context).colorScheme.primary) : null,
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                  width: 100,
                  height: 100,
                  child: Hero(
                      tag: player.name,
                      child:
                          Image(image: NetworkImage(player.image, scale: 1.5)))),
              Text(
                player.name,
                style: Theme.of(context).textTheme.headlineSmall,
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 50.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Player Info',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
          ),
          Text('Age: ${player.age}', style: Theme.of(context).textTheme.bodyLarge),
          Text('Height: ${player.height}', style: Theme.of(context).textTheme.bodyLarge),
          Text('Weight: ${player.weight}', style: Theme.of(context).textTheme.bodyLarge),
          Text('Position: ${player.position}', style: Theme.of(context).textTheme.bodyLarge),
          Text('Number: ${player.number}', style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    ));
  }
}


