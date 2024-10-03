import './game.dart';

class Team {
  final String abbreviation;
  final String name;
  final String city;
  final String coach;
  final String stadium;
  final String logo;
  final int id;
  String? division;
  int? divPosition;
  int? wins;
  int? losses;
  int? ties;
  List<Game> games = [];


  Team({
    required this.abbreviation,
    required this.name,
    required this.city,
    required this.coach,
    required this.stadium,
    required this.logo,
    required this.id,
    this.division,
    this.divPosition,
    this.wins,
    this.losses,
    this.ties,
  });

  void setDivision(String division) {
    this.division = division;
  }

  void setDivPosition(int position) {
    divPosition = position;
  }

  void setWins(int wins) {
    this.wins = wins;
  }

  void setLosses(int losses) {
    this.losses = losses;
  }

  void setTies(int ties) {
    this.ties = ties;
  }

  Game? getLastGame() {
    Game? lastGame;
    for (var i = 0; i < games.length; i++) {
      if (games[i].status == 'Finished') {
        lastGame = games[i];
      } else {
        break;
      }
    }
    return lastGame;
  }

  Game? getNextGame() {
    Game? nextGame;
    for (var i = 0; i < games.length; i++) {
      if (games[i].status == 'Not Started') {
        nextGame = games[i];
        break;
      }
    }

    return nextGame;
  }
}