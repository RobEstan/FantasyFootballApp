// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;

class Game {
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
