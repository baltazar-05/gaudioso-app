import 'package:flutter/material.dart';
import 'fluxo_lotes_entradas_screen.dart';
import 'fluxo_lotes_saidas_screen.dart';

class FluxoLotesScreen extends StatelessWidget {
  const FluxoLotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: const [
            SizedBox(height: 8),
            TabBar(
              tabs: [
                Tab(text: 'Entradas'),
                Tab(text: 'Saídas'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  FluxoLotesEntradasScreen(),
                  FluxoLotesSaidasScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
