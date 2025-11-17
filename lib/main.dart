// lib/main.dart → VERSÃO FINAL COM ABAS + ODDs ALTAS + RODAPÉ
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/home_controller.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const PalpitesTopApp());

class PalpitesTopApp extends StatelessWidget {
  const PalpitesTopApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeController()..loadMatches(),
      child: MaterialApp(
        title: 'Palpites Top',
        theme: ThemeData(primarySwatch: Colors.green),
        home: const HomeComAbas(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class HomeComAbas extends StatefulWidget {
  const HomeComAbas({Key? key}) : super(key: key);
  @override
  State<HomeComAbas> createState() => _HomeComAbasState();
}

class _HomeComAbasState extends State<HomeComAbas> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Palpites Top', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[700],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.yellow,
          tabs: const [
            Tab(text: 'JOGOS DO DIA'),
            Tab(text: 'PALPITES MANUAIS'),
            Tab(text: 'ODDs ALTAS 4x-1000x'),
            Tab(text: 'MEUS ACERTOS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          JogosDoDiaTab(),
          PalpitesManuaisTab(),
          OddsAltasTab(),
          HistoricoTab(),
        ],
      ),
      bottomNavigationBar: const RodapeMelhoresPalpites(),
    );
  }
}

// ABA 1 – Jogos do dia (já tinha)
class JogosDoDiaTab extends StatelessWidget {
  const JogosDoDiaTab({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // aqui vai o código da lista de jogos que já temos
    // (pode colar o ListView.builder que já estava funcionando)
    return Consumer<HomeController>(
      builder: (context, controller, _) {
        if (controller.isLoading) return const Center(child: CircularProgressIndicator());
        if (controller.leagues.isEmpty) return const Center(child: Text('Sem jogos hoje'));
        return const Text('JOGOS DO DIA – já funcionando'); // substitui depois
      },
    );
  }
}

// ABA 2 – Palpites manuais (já tinha)
class PalpitesManuaisTab extends StatelessWidget {
  const PalpitesManuaisTab({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Center(child: Text('Escolha seu palpite manual aqui'));
}

// ABA 3 – ODDs ALTAS AUTOMÁTICAS (A ABA QUE VAI MUDAR TUDO)
class OddsAltasTab extends StatelessWidget {
  const OddsAltasTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeController>(
      builder: (context, controller, _) {
        final oddsAltas = controller.encontrarOddsAltas(); // nova função no controller

        if (oddsAltas.isEmpty) {
          return const Center(child: Text('Nenhuma odd alta encontrada agora\nVolte em 5 minutos!', textAlign: TextAlign.center));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: oddsAltas.length,
          itemBuilder: (context, i) {
            final o = oddsAltas[i];
            return Card(
              color: Colors.green[50],
              child: ListTile(
                leading: const Icon(Icons.trending_up, color: Colors.green, size: 40),
                title: Text('${o['home']} × ${o['away']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${o['mercado']} → ${o['valor']}\nHorário: ${o['hora']}'),
                trailing: Text('${o['odd']}x', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
                onTap: () {
                  final url = 'https://www.bet365.com/#/AC/B1/C1/F^${o['fixtureId']}';
                  launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                },
              ),
            );
          },
        );
      },
    );
  }
}

// ABA 4 – Histórico (futuro)
class HistoricoTab extends StatelessWidget {
  const HistoricoTab({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Center(child: Text('Seus acertos vão aparecer aqui'));
}

// RODAPÉ FIXO COM OS MELHORES DO DIA
class RodapeMelhoresPalpites extends StatelessWidget {
  const RodapeMelhoresPalpites({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeController>(
      builder: (context, controller, _) {
        final top5 = controller.encontrarOddsAltas().take(5).toList();
        if (top5.isEmpty) return const SizedBox.shrink();

        return Container(
          height: 80,
          color: Colors.green[800],
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: top5.length,
            itemBuilder: (context, i) {
              final o = top5[i];
              return Padding(
                padding: const EdgeInsets.all(8),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow[700]),
                  child: Text('${o['odd']}x\n${o['mercado']}', style: const TextStyle(color: Colors.black)),
                  onPressed: () {
                    launchUrl(Uri.parse('https://www.bet365.com/#/AC/B1/C1/F^${o['fixtureId']}'),
                        mode: LaunchMode.externalApplication);
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}