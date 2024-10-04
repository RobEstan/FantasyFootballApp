import 'package:flutter/material.dart';
import './standing.dart';

const List<String> divisions = ['AFC East', 'AFC North', 'AFC South', 'AFC West', 'NFC East', 'NFC North', 'NFC South', 'NFC West',];

class StandingsTab extends StatefulWidget {
  const StandingsTab({super.key, required this.standings});

  final List<List<Standing>> standings;
  @override
  State<StandingsTab> createState() => _StandingsTab();
}

class _StandingsTab extends State<StandingsTab> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.standings.length,
      itemBuilder: (context, divisionIndex) {
        // For each division
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                divisions[divisionIndex],
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            // Display the teams within the division
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.standings[divisionIndex].length,
              itemBuilder: (context, teamIndex) {
                final teamStanding = widget.standings[divisionIndex][teamIndex];
                return ListTile(
                  leading: Image.network(
                          teamStanding.logo,
                          width: 30,
                          height: 30,
                        ),
                  title: Text(teamStanding.name),
                  subtitle: Text(
                      'PF: ${teamStanding.pointsFor}, PA: ${teamStanding.pointsAgainst}, Net Points: ${teamStanding.netPoints}\nStreak: ${teamStanding.streak}'),
                  trailing: Text('Record: ${teamStanding.wins}-${teamStanding.losses}-${teamStanding.ties}', style: const TextStyle(fontSize: 14)),
                );
              },
            ),
            const Divider(), // Add a divider between divisions
          ],
        );
      },
    );
  }
}
