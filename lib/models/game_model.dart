class GameModel {
  final String homeTeam;
  final String awayTeam;
  final String league;
  final String status;      // "LIVE", "FINISHED", "SCHEDULED"
  final String? scoreHome;
  final String? scoreAway;
  final int? minute;

  GameModel({
    required this.homeTeam,
    required this.awayTeam,
    required this.league,
    this.status = "SCHEDULED",
    this.scoreHome,
    this.scoreAway,
    this.minute,
  });
}