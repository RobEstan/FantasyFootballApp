class Game {
  final int id;
  final String stage;
  final String week;
  final String date;
  final String time;
  final String status;
  final String? venue;
  final String? homeTeam;
  final String? awayTeam;
  final int? homeScore;
  final int? awayScore;
  final List<int> awayBox;
  final List<int> homeBox;

  Game({
    required this.id,
    required this.stage,
    required this.week,
    required this.date,
    required this.time,
    required this.status,
    required this.venue,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeScore,
    required this.awayScore,
    required this.awayBox,
    required this.homeBox,
  });
}
