// lib/screens/game_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/game_model.dart';

class GameDetailScreen extends StatelessWidget {
  final GameModel game;
  const GameDetailScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final home = game.homeTeam;
    final away = game.awayTeam;

    // Palpites prontos (depois vamos colocar IA de verdade)
    final palpites = {
      "Over 2.5 gols": "78%",
      "Ambas marcam": "Sim – 82%",
      "$home vence": "71%",
      "Mais de 9.5 escanteios": "65%",
      "Mais de 4.5 cartões": "69%",
      "Dupla chance 1X": "89%",
    };

    final textoParaCopiar = """
PALPITES TOP – $home × $away
Over 2.5 gols → 78%
Ambas marcam → Sim (82%)
$home vence → 71%
+9.5 escanteios → 65%
+4.5 cartões → 69%
Dupla chance 1X → 89%
    """.trim();

    return Scaffold(
      appBar: AppBar(
        title: Text("$home × $away"),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (game.status == "LIVE")
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                color: Colors.red,
                child: Text(
                  "AO VIVO • ${game.minute}' • ${game.scoreHome}–${game.scoreAway}",
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 20),
            const Text("PALPITES PRONTOS", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...palpites.entries.map((e) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.check_circle, color: Colors.green),
                    title: Text(e.key, style: const TextStyle(fontWeight: FontWeight.w600)),
                    trailing: Text(e.value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
                  ),
                )),
            const Spacer(),
            ElevatedButton.icon(
              icon: const Icon(Icons.copy, color: Colors.white),
              label: const Text("COPIAR TUDO PRA BET", style: TextStyle(fontSize: 20)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                padding: const EdgeInsets.symmetric(vertical: 18),
                minimumSize: const Size(double.infinity, 70),
              ),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: textoParaCopiar));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Palpites copiados! Cola na Bet365 agora!")),
                );
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}