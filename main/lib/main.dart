import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:main/drawer_model.dart';
import 'package:main/favorites_model.dart';
import 'package:main/games_model.dart';
import 'package:main/team.dart';
import 'package:main/teams_tab.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './favorites_tab.dart';
import './players_tab.dart';
import './scores_tab.dart';
import './standings_tab.dart';
import './game.dart';
import './player.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'last_game_notifs.dart';

@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  String taskId = task.taskId;
  bool isTimeout = task.timeout;
  if (isTimeout) {
    print('[BackgroundFetch] Headless task timed-out: $taskId');
    BackgroundFetch.finish(taskId);
    return;
  }
  print('[BackgroundFetch] Headless event received.');

  DateTime now = DateTime.now();

  if (now.hour == 6 && now.weekday == 2) {
    await callAPI();
    await sendNotification();
  }

  BackgroundFetch.finish(taskId);
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) => FavoritesModel(),
      ),
      ChangeNotifierProvider(
        create: (context) => GamesModel(),
      ),
      ChangeNotifierProvider(
        create: (context) => DrawerModel(),
      )
    ],
    child: const MyApp(),
  ));

  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  List<Team> teams = [];
  List<Player> players = [];
  List<Game> games = [];
  late Future _future;
  late Future _notifications;
  final jakeHeaders = {'x-rapidapi-key': 'd5acb40e57a90447afa2bfcba8f332e2'};
  final shivenHeaders = {'x-rapidapi-key': '4bb22b892adc41f1e4eaa6800ff36ab9'};
  final himnishHeaders = {'x-rapidapi-key': '30206e5d618f7492ca4322ff246895a0'};
  final samHeaders = {'x-rapidapi-key': 'd8074a4ae693a14c977d3eec4b4f9c78'};

  Future getTeams() async {
    var requestTeams = http.Request(
        'GET',
        Uri.parse(
            'https://v1.american-football.api-sports.io/teams?league=1&season=2024'));
    requestTeams.headers.addAll(himnishHeaders);
    http.StreamedResponse response = await requestTeams.send();

    if (response.statusCode == 200) {
      var jsonData =
          jsonDecode(await response.stream.bytesToString())['response'];

      for (var i = 0; i < jsonData.length - 2; i++) {
        final team = Team(
          abbreviation: jsonData[i]['code'],
          name: jsonData[i]['name'],
          city: jsonData[i]['city'],
          coach: jsonData[i]['coach'],
          stadium: jsonData[i]['stadium'],
          logo: jsonData[i]['logo'],
          id: jsonData[i]['id'],
        );

        teams.add(team);
      }
      teams.sort((a, b) => a.name.compareTo(b.name));
    } else {
      print(response.reasonPhrase);
    }
  }

  Future getStandings() async {
    var requestStandings = http.Request(
        'GET',
        Uri.parse(
            'https://v1.american-football.api-sports.io/standings?league=1&season=2024'));
    requestStandings.headers.addAll(himnishHeaders);
    http.StreamedResponse response = await requestStandings.send();

    if (response.statusCode == 200) {
      var jsonData =
          jsonDecode(await response.stream.bytesToString())['response'];
      for (var i = 0; i < jsonData.length; i++) {
        var currJsonData = jsonData[i];
        var currTeamName = currJsonData['team']['name'];
        for (var x = 0; x < teams.length; x++) {
          var currSearchName = teams[x].name;
          if (currTeamName == currSearchName) {
            Team foundTeam = teams[x];
            foundTeam.setDivision(currJsonData['division']);
            foundTeam.setDivPosition(currJsonData['position']);
            foundTeam.setWins(currJsonData['won']);
            foundTeam.setLosses(currJsonData['lost']);
            foundTeam.setTies(currJsonData['ties']);
            break;
          }
        }
      }
    } else {
      print(response.reasonPhrase);
    }
  }

  Future getGames() async {
    var requestGames = http.Request(
        'GET',
        Uri.parse(
            'https://v1.american-football.api-sports.io/games?league=1&season=2024'));
    requestGames.headers.addAll(himnishHeaders);
    http.StreamedResponse response = await requestGames.send();

    if (response.statusCode == 200) {
      var jsonData =
          jsonDecode(await response.stream.bytesToString())['response'];
      for (var i = 0; i < jsonData.length; i++) {
        var currData = jsonData[i];
        final game = Game(
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
        var foundTeams = 0;
        for (Team team in teams) {
          if (team.name == game.homeTeam || team.name == game.awayTeam) {
            team.games.add(game);
            foundTeams++;
          }

          if (foundTeams >= 2) {
            break;
          }
        }
        games.add(game);
      }
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> requestPermissions() async {
    final bool? notificationsEnabled = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.areNotificationsEnabled();
    if (!notificationsEnabled!) {
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  void addSavedFavTeam(String teamName) {
    for (Team t in teams) {
      if (t.name == teamName) {
        print('adding');
        Provider.of<FavoritesModel>(context, listen: false).editFavTeams(t);
      }
    }
  }

  void addSavedFavPlayer(String playerName) {
    for (Player p in players) {
      if (p.name == playerName) {
        Provider.of<FavoritesModel>(context, listen: false).addFavPlayer(p);
      }
    }
  }

  Future<void> getFavorites() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    print('hi');
    final List<String> favTeams = prefs.getStringList('favoriteTeams') ?? [];
    final List<String> favPlayers =
        prefs.getStringList('favoritePlayers') ?? [];
    print(favTeams);
    for (String t in favTeams) {
      addSavedFavTeam(t);
    }
    for (String p in favPlayers) {
      addSavedFavPlayer(p);
    }
  }

  initBackgroundFetch() {
    BackgroundFetch.configure(
      BackgroundFetchConfig(
          minimumFetchInterval: 15,
          stopOnTerminate: false,
          enableHeadless: true,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresStorageNotLow: false,
          requiresDeviceIdle: false,
          requiredNetworkType: NetworkType.NONE),
      (String taskID) async {
        DateTime now = DateTime.now();

        if (now.hour == 6 && now.weekday == 2) {
          await callAPI();
          await sendNotification();
        }
        print('[BackgroundFetch] Task Complete: $taskID');
        BackgroundFetch.finish(taskID);
      },
      (String taskID) async {
        print("[BackgrounFetch] Task failed: $taskID");
        BackgroundFetch.finish(taskID);
      },
    ).catchError((e) {
      print('[BackgroundFetch] Configure error: $e');
      return e;
    });
  }

  @override
  void initState() {
    _future = getTeams().then((_) async {
      print('standings');
      await getStandings();
      print('games');
      await getGames();
      print('favs');
      await getFavorites();
      print('done');
    });
    _notifications = requestPermissions();
    initBackgroundFetch();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DrawerModel>(context, listen: false).setNotificationsOn();
    });

    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 5,
        child: SafeArea(
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              title: const Text('Sports App'),
              bottom: const TabBar(
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black,
                  indicatorPadding: EdgeInsets.symmetric(horizontal: 8.0),
                  labelPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  tabs: [
                    Tab(
                      text: 'Scores',
                      icon: Icon(
                        Icons.scoreboard_outlined,
                        size: 30,
                      ),
                    ),
                    Tab(
                      text: ('Standings'),
                      icon: Icon(
                        Icons.list,
                        size: 30,
                      ),
                    ),
                    Tab(
                      text: 'Teams',
                      icon: Icon(
                        Icons.sports_football_outlined,
                        size: 30,
                      ),
                    ),
                    Tab(
                      text: 'Players',
                      icon: Icon(
                        Icons.person_outlined,
                        size: 30,
                      ),
                    ),
                    Tab(
                      text: 'Favorites',
                      icon: Icon(
                        Icons.star,
                        size: 30,
                      ),
                    )
                  ]),
            ),
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const DrawerHeader(child: Text('Notification Settings')),
                  SwitchListTile(
                    title: const Text('Enable Notifications'),
                    value: Provider.of<DrawerModel>(context).notificationsOn,
                    onChanged:
                        Provider.of<DrawerModel>(context).toggleNotifications,
                  )
                ],
              ),
            ),
            body: FutureBuilder(
                future: Future.wait([_future, _notifications]),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return TabBarView(children: [
                      ScoresTab(teams: teams, games: games),
                      StandingsTab(teams: teams),
                      TeamsTab(
                        teams: teams,
                      ),
                      PlayersTab(players: players),
                      FavoritesTab(teams: teams, favoriteTeamId: 4),
                    ]);
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }),
          ),
        ),
      ),
    );
  }
}
