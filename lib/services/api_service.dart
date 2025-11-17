// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ⇣ SUA CHAVE REAL ⇣
  static const String _apiKey = '22b00bb8c68304c41186043402157772';

  static const String _baseUrl = 'https://v3.football.api-sports.io';

  static final Map<String, String> _headers = {
    'x-rapidapi-key': _apiKey,
    'x-rapidapi-host': 'v3.football.api-sports.io',
  };

  // Pega jogos de hoje + últimos 2 dias (pra garantir DataFIFA e ligas do mundo todo)
  static Future<List<dynamic>> getAllMatchesToday({String? specificDate}) async {
    List<String> dates = [];

    if (specificDate != null && specificDate.isNotEmpty) {
      dates.add(specificDate);
    } else {
      final now = DateTime.now();
      for (int i = 0; i < 3; i++) {
        final d = now.subtract(Duration(days: i));
        dates.add(
            '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}');
      }
    }

    List<dynamic> allMatches = [];

    for (String date in dates) {
      final url = Uri.parse(
          '$_baseUrl/fixtures?date=$date&timezone=America/Sao_Paulo');

      try {
        print('🔍 Buscando jogos para $date...');
        final response = await http.get(url, headers: _headers);

        if (response.statusCode == 200) {
          final json = jsonDecode(response.body);
          final List<dynamic> matches = json['response'] ?? [];

          print('✅ $date → ${matches.length} jogos encontrados');

          // Filtra só jogos de hoje em diante (ou últimos 4h)
          final filtered = matches.where((m) {
            final gameTime = DateTime.parse(m['fixture']['date']);
            return gameTime.isAfter(DateTime.now().subtract(const Duration(hours: 4)));
          }).toList();

          allMatches.addAll(filtered);
        } else {
          print('❌ Erro $date: ${response.statusCode} → ${response.body}');
        }
      } catch (e) {
        print('💥 Exceção em $date: $e');
      }

      // Respeita o limite do plano free
      await Future.delayed(const Duration(milliseconds: 1200));
    }

    // Remove duplicatas por ID
    final uniqueMatches = allMatches
        .toSet()
        .toList(growable: false);

    print('🎯 TOTAL FINAL DE JOGOS: ${uniqueMatches.length}');
    return uniqueMatches;
  }

  // Agrupa por campeonato (dá destaque especial pra DataFIFA e amistosos)
  static Map<String, List<dynamic>> groupByLeague(List<dynamic> matches) {
    final Map<String, List<dynamic>> grouped = {};

    for (var match in matches) {
      final league = match['league'];
      final leagueName = league['name'] ?? 'Desconhecido';
      final country = league['country'] ?? 'Internacional';
      final isInternational = (league['type'] ?? '')
              .toString()
              .toLowerCase()
              .contains('international') ||
          leagueName.toLowerCase().contains('friendly') ||
          leagueName.toLowerCase().contains('fifa');

      final key = isInternational
          ? 'DataFIFA / Amistosos - $country'
          : '$leagueName - $country';

      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(match);
    }

    // Ordena alfabeticamente
    final sortedKeys = grouped.keys.toList()..sort();
    return {for (var k in sortedKeys) k: grouped[k]!};
  }
}