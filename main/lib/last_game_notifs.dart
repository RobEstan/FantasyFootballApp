import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:main/game.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

final jakeHeaders = {'x-rapidapi-key': 'd5acb40e57a90447afa2bfcba8f332e2'};
final himnishHeaders = {'x-rapidapi-key': '30206e5d618f7492ca4322ff246895a0'};

late List<dynamic> lastGame;
int notifId = 0;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

void setLastGame(int len) {
  lastGame = List.filled(len, null);
}

Future<void> callAPI() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final List<String> favTeamsID = prefs.getStringList('favoriteTeamsID') ?? [];
  setLastGame(favTeamsID.length);

  for (var x = 0; x < favTeamsID.length; x++) {
    var id = favTeamsID[x];
    var requestGames = http.Request(
        'GET',
        Uri.parse(
            'https://v1.american-football.api-sports.io/games?league=1&season=2024&team=${int.parse(id)}'));
    requestGames.headers.addAll(himnishHeaders);
    http.StreamedResponse response = await requestGames.send();

    if (response.statusCode == 200) {
      var jsonData =
          jsonDecode(await response.stream.bytesToString())['response'];
      for (var i = 0; i < jsonData.length; i++) {
        var currData = jsonData[i];
        
        if (currData['game']['status']['long'] != 'Not Started') {
          lastGame[x] = Game(
            id: currData['game']['id'],
            stage: currData['game']['stage'],
            week: currData['game']['week'],
            date: currData['game']['date']['date'],
            time: currData['game']['date']['time'],
            status: currData['game']['status']['long'],
            venue: currData['game']['venue']['name'],
            homeTeam: currData['teams']['home']['name'],
            awayTeam: currData['teams']['away']['name'],
            homeScore: currData['scores']['home']['total'],
            awayScore: currData['scores']['away']['total'],
            awayBox: currData['game']['status']['long'] == 'Not Started'
                ? []
                : [
                    currData['scores']['away']['quarter_1'] ?? 0,
                    currData['scores']['away']['quarter_2'] ?? 0,
                    currData['scores']['away']['quarter_3'] ?? 0,
                    currData['scores']['away']['quarter_4'] ?? 0,
                  ],
            homeBox: currData['game']['status']['long'] == 'Not Started'
                ? []
                : [
                    currData['scores']['home']['quarter_1'] ?? 0,
                    currData['scores']['home']['quarter_2'] ?? 0,
                    currData['scores']['home']['quarter_3'] ?? 0,
                    currData['scores']['home']['quarter_4'] ?? 0,
                  ],
          );
        } else {
          break;
        }
      }
    } else {
      print(response.reasonPhrase);
    }
  }
}

Future<void> sendNotification() async {
  for (var game in lastGame) {
    if (game is Game) {
      final Game currGame = game;
      final List<String> homeTeamList = currGame.homeTeam!.split(' ');
      String homeTeam = '';
      if (homeTeamList.length > 2) {
        homeTeam = homeTeamList[0] + homeTeamList[1];
      } else {
        homeTeam = homeTeamList[0];
      }

      final List<String> awayTeamList = currGame.awayTeam!.split(' ');
      String awayTeam = '';
      if (homeTeamList.length > 2) {
        awayTeam = awayTeamList[0] + awayTeamList[1];
      } else {
        awayTeam = awayTeamList[0];
      }

      final int homeScore = currGame.homeScore!;
      final int awayScore = currGame.awayScore!;
      showNotification(homeTeam, awayTeam, homeScore, awayScore);
    }
  }
}

Future<void> showNotification(String homeTeam, String awayTeam, int homeScore, int awayScore) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('your channel id', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker',
            icon: '@drawable/ic_launcher_foreground',
            color: Colors.black);
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
        notifId++,
        'Final Score',
        '$homeTeam $homeScore - $awayScore $awayTeam',
        notificationDetails,
        payload: 'item x',);
  }