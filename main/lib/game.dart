import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class Game {
  final String stage;
  final String week;
  final String date;
  final String time;
  final String status;
  final String venue;
  final String homeTeam;
  final String awayTeam;
  final String? homeScore;
  final String? awayScore;

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
  });

  void convertTime(String date, String time) {
    tz.initializeTimeZones();

    
  }
}