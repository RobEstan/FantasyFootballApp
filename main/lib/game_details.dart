import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:main/games_model.dart';

class OtherView extends StatelessWidget {
  const OtherView({super.key, required this.logos});

  final List<String> logos;

  @override
  Widget build(BuildContext context) {
    return Consumer<GamesModel>(
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          title: Text(model.currGame.date),
        ),
        body: Center(
          child: 
            Column(
              children: [ 
                Row(
                  children: [
                    CachedNetworkImage(
                      imageUrl: logos[0],
                      progressIndicatorBuilder: (context, url, downloadProgress) => 
                        CircularProgressIndicator(value: downloadProgress.progress),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                      height: 100,
                      width: 100,
                    ),  
                    Text('${model.currGame.awayTeam}: ${model.currGame.awayScore}'),
                  ],
                ),
                Row(
                  children: [
                    CachedNetworkImage(
                      imageUrl: logos[1],
                      progressIndicatorBuilder: (context, url, downloadProgress) => 
                        CircularProgressIndicator(value: downloadProgress.progress),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                      height: 100,
                      width: 100,
                    ), 
                    Text('${model.currGame.homeTeam}: ${model.currGame.homeScore}'),
                  ],
                ),                
                Text('Venue: ${model.currGame.venue}'),
                Text(model.currGame.stage)
              ],
            )
        )
      )
    );
  }
}