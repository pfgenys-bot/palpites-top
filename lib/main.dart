// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';          // ← ESSA LINHA É OBRIGATÓRIA
import '../controllers/home_controller.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => HomeController()..loadMatches(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Palpites Top',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Palpites Top'),
        backgroundColor: Colors.green[700],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Jogos do Dia'),
            Tab(text: 'Palpites Manuais'),
            Tab(text: 'ODDs Altas 4x+'),
            Tab(text: 'Meus Acertos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          JogosDoDia(),
          PalpitesManuais(),
          OddsAltas(),
          MeusAcertos(),
        ],
      ),
      bottomNavigationBar: const RodapePalpites(),
    );
  }
}

// ==================================== ABA 1 ====================================
class JogosDoDia extends StatelessWidget {
  const JogosDoDia({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeController>(
      builder: (context, controller, child) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.leagues.isEmpty) {
          return const Center(child: Text('Sem jogos hoje'));
        }

        return ListView.builder(
          itemCount: controller.leagues.length,
          itemBuilder: (context, index) {
            final league = controller.leagues.keys.elementAt(index);
            final matches = controller.leagues[league]!;
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                title: Text(league, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${matches.length} jogos'),
                trailing: const Icon(Icons.chevron_right),
              ),
            );
          },
        );
      },
    );
  }
}

// ==================================== ABA 2 ====================================
class PalpitesManuais extends StatelessWidget {
  const PalpitesManuais({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Em breve: palpites manuais aqui',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}

// ==================================== ABA 3 ====================================
class OddsAltas extends StatelessWidget {
  const OddsAltas({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeController>(
      builder: (context, controller, child) {
        final odds = controller.encontrarOddsAltas();

        if (odds.isEmpty) {
          return const Center(child: Text('Sem odds altas no momento'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: odds.length,
          itemBuilder: (context, i) {
            final o = odds[i];
            return Card(
              child: ListTile(
                title: Text('${o['home']} × ${o['away']}'),
                subtitle: Text('${o['mercado']} • ${o['hora']}'),
                trailing: Text(
                  '${o['odd']}x',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                onTap: () async {
                  final uri = Uri.parse('https://www.bet365.com');
                  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Não foi possível abrir o link')),
                    );
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}

// ==================================== ABA 4 ====================================
class MeusAcertos extends StatelessWidget {
  const MeusAcertos({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Seus greens vão aparecer aqui',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}

// ==================================== RODAPÉ ====================================
class RodapePalpites extends StatelessWidget {
  const RodapePalpites({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeController>(
      builder: (context, controller, child) {
        final topOdds = controller.encontrarOddsAltas().take(3).toList();

        if (topOdds.isEmpty) {
          return Container(height: 60, color: Colors.green[800]);
        }

        return Container(
          height: 60,
          color: Colors.green[800],
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: topOdds.length,
            itemBuilder: (context, i) {
              final o = topOdds[i];
              return Padding(
                padding: const EdgeInsets.all(6),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () async {
                    final uri = Uri.parse('https://www.bet365.com');
                    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Erro ao abrir bet365')),
                      );
                    }
                  },
                  child: Text(
                    '${o['odd']}x',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}