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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Entradas'),
              Tab(text: 'Saídas'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            FluxoLotesEntradasScreen(),
            FluxoLotesSaidasScreen(),
          ],
        ),
      ),
    );
  }
}
