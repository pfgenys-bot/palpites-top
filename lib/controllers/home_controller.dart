// lib/controllers/home_controller.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HomeController extends ChangeNotifier {
  bool isLoading = true;
  Map<String, List<dynamic>> leagues = {};
  String errorMessage = '';

  Future<void> loadMatches() async {
    try {
      isLoading = true;
      errorMessage = '';
      leagues.clear();
      notifyListeners();

      final allMatches = await ApiService.getAllMatchesToday();

      if (allMatches.isEmpty) {
        errorMessage = 'Nenhum jogo encontrado para hoje';
      } else {
        leagues = ApiService.groupByLeague(allMatches);
      }
    } catch (e) {
      errorMessage = 'Erro ao carregar jogos: $e';
      debugPrint('Erro no HomeController: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// ================================================
  /// FUNÇÃO MÁGICA: ENCONTRA TODAS AS ODDS ≥ 4.00x
  /// ================================================
  List<Map<String, dynamic>> encontrarOddsAltas({double minimo = 4.0}) {
    List<Map<String, dynamic>> oddsAltas = [];

    for (var listaJogos in leagues.values) {
      for (var jogo in listaJogos) {
        try {
          final bookmakers = jogo['bookmakers'] as List<dynamic>?;
          if (bookmakers == null || bookmakers.isEmpty) continue;

          final bets = bookmakers[0]['bets'] as List<dynamic>;

          for (var bet in bets) {
            final mercadoNome = bet['name'] as String? ?? 'Mercado';
            final values = bet['values'] as List<dynamic>;

            for (var v in values) {
              final oddStr = v['odd'].toString();
              final odd = double.tryParse(oddStr.replaceAll(',', '.')) ?? 0.0;

              if (odd >= minimo) {
                final home = jogo['teams']['home']['name'] ?? 'Time Casa';
                final away = jogo['teams']['away']['name'] ?? 'Time Fora';
                final fixtureId = jogo['fixture']['id'].toString();
                final date = DateTime.parse(jogo['fixture']['date']).toLocal();
                final hora = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

                String descricao = '';
                switch (mercadoNome) {
                  case 'Match Winner':
                    descricao = v['value'] == 'Home' ? 'Vitória $home' : 'Vitória $away';
                    break;
                  case 'Goals Over/Under':
                    descricao = '${v['value']} gols';
                    break;
                  case 'Both Teams to Score':
                    descricao = v['value'] == 'Yes' ? 'Ambas marcam' : 'Apenas um marca';
                    break;
                  case 'Asian Handicap':
                    descricao = 'Handicap ${v['value']}';
                    break;
                  case 'Total Corners':
                    descricao = '${v['value']} escanteios';
                    break;
                  case 'Cards':
                    descricao = '${v['value']} cartões';
                    break;
                  default:
                    descricao = '$mercadoNome ${v['value']}';
                }

                oddsAltas.add({
                  'home': home,
                  'away': away,
                  'mercado': descricao,
                  'odd': odd.toStringAsFixed(2),
                  'oddNumero': odd,
                  'fixtureId': fixtureId,
                  'hora': hora,
                  'data': date,
                  'jogoCompleto': jogo, // pra usar depois se quiser
                });
              }
            }
          }
        } catch (e) {
          // ignora erro de um jogo só
          continue;
        }
      }
    }

    // Ordena do maior para o menor
    oddsAltas.sort((a, b) => (b['oddNumero'] as double).compareTo(a['oddNumero'] as double));

    return oddsAltas;
  }
}