import 'package:flutter/material.dart';
import 'package:main/game_details.dart';

class ScoresTab extends StatefulWidget{
  const ScoresTab({super.key});

  @override
  State<ScoresTab> createState() => _ScoresTab();
}

class _ScoresTab extends State<ScoresTab> {

  @override
  Widget build(BuildContext context) {
    final items = ['Ravens vs Steelers (24 - 17)', 'Buccaneers vs Falcons (31-21)', 'Lions vs Seahawks (14-17)'];
    final icons = [Icons.sports_football_outlined, Icons.sports_football_outlined, Icons.sports_football_outlined];
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: LayoutBuilder(
            builder: (context, constraints) => GestureDetector(
              child:
                Text(items[index]),
              onTap: () {
                Navigator.push(
                  context,
                    MaterialPageRoute(
                      builder: (context) => const OtherView(),
                    )
                );
              },
            )
          ),
          leading: LayoutBuilder(
            builder: (context, constraints) => GestureDetector(
              child:
                Icon(icons[index]),
              onTap: () {
                Navigator.push(
                  context,
                    MaterialPageRoute(
                      builder: (context) => const OtherView(),
                    )
                );
              },
            )
          ),     
        );
      },
    );
  }
}