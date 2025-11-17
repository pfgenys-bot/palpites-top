import 'api_football_service.dart';

void main() async {
  final api = ApiFootballService();

  try {
    print('Carregando jogos de hoje...');
    final games = await api.getGamesToday(); // ← MÉTODO CERTO

    if (games.isEmpty) {
      print('Nenhum jogo hoje.');
    } else {
      print('JOGOS HOJE: ${games.length}');
      for (var g in games) {
        final home = g['teams']['home']['name'];
        final away = g['teams']['away']['name'];
        final league = g['league']['name'];
        print('• $home vs $away ($league)');
      }
    }
  } catch (e) {
    print('ERRO: $e');
  }
}