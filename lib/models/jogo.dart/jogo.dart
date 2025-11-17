class Jogo {
  final int id;
  final String data;
  final String hora;
  final String liga;
  final String timeCasa;
  final String timeVisitante;
  final int placarCasa;
  final int placarVisitante;

  Jogo({
    required this.id,
    required this.data,
    required this.hora,
    required this.liga,
    required this.timeCasa,
    required this.timeVisitante,
    this.placarCasa = 0,
    this.placarVisitante = 0,
  });

  factory Jogo.fromJson(Map<String, dynamic> json) {
    var fixture = json['fixture'];
    var teams = json['teams'];
    var league = json['league'];

    return Jogo(
      id: fixture['id'],
      data: fixture['date'],
      hora: fixture['date'].split('T')[1].split(':').sublist(0, 2).join(':'),
      liga: league['name'],
      timeCasa: teams['home']['name'],
      timeVisitante: teams['away']['name'],
      placarCasa: fixture['goals']['home'] ?? 0,
      placarVisitante: fixture['goals']['away'] ?? 0,
    );
  }
}