import 'package:flutter/material.dart';

class OtherView extends StatelessWidget {
  const OtherView({super.key});

  // Can make API call here to retrieve game data, which
  // will be displayed in this view.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Placeholder game info')
      ),
      body: const Center(
        child: 
          Column(
            children: [ 
              Icon(Icons.sports_football_outlined),    
              Text('Info about the game will go here.')
            ],
          )
      )
    );
  }
}