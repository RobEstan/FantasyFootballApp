import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:main/team.dart';
import './display_team.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  List<Team> teams = [];

  Future getTeams() async {
    var headers = {
      'x-rapidapi-key': 'd5acb40e57a90447afa2bfcba8f332e2'
    };

    var request = http.Request('GET', Uri.parse('https://v1.american-football.api-sports.io/teams?league=1&season=2024'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(await response.stream.bytesToString())['response'];

      for (var i = 0; i < jsonData.length - 2; i++) {
        final team = Team(
            abbreviation: jsonData[i]['code'],
            name: jsonData[i]['name'],
            city: jsonData[i]['city'],
            coach: jsonData[i]['coach'],
            stadium: jsonData[i]['stadium'],
            logo: jsonData[i]['logo']);

        teams.add(team);
      }
    } else {
      print(response.reasonPhrase);
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp( 
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Teams'),
        ),
        body: FutureBuilder(future: getTeams(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ListView.builder(
              itemCount: 32,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(teams[index].abbreviation),
                  leading: Image(image: NetworkImage(teams[index].logo, scale: 0.5)),
                  subtitle: Text(teams[index].name),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => DisplayTeam(team: teams[index])));
                  },
                );
              }
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        }
      ),)
    );
  }
}