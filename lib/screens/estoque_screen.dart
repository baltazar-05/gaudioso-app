import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/estoque.dart';
import '../services/estoque_service.dart';

class EstoqueScreen extends StatefulWidget {
  const EstoqueScreen({super.key});

  @override
  State<EstoqueScreen> createState() => _EstoqueScreenState();
}

class _EstoqueScreenState extends State<EstoqueScreen> {
  final service = EstoqueService();
  final _buscaCtrl = TextEditingController();
  List<Estoque> itens = [];
  List<Estoque> filtrados = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregar();
  }

  @override
  void dispose() {
    _buscaCtrl.dispose();
    super.dispose();
  }

  Future<void> carregar() async {
    try {
      final data = await service.listar();
      final ordenados = _ordenar(data);
      if (!mounted) return;
      setState(() {
        itens = ordenados;
        filtrados = _filtrar(_buscaCtrl.text, ordenados);
        carregando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => carregando = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro ao carregar estoque: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = scheme.surface;
    final accent = scheme.onSurface;

    Widget listaVazia(String mensagem) => ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 120),
      children: [
        Center(
          child: Text(
            mensagem,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: accent,
                  fontSize: 16,
                ),
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: accent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        title: const Text("Estoque Atual"),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF81C784), Color(0xFF4CAF50)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: carregando
            ? const Center(child: CircularProgressIndicator())
            : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: TextField(
                    controller: _buscaCtrl,
                    onChanged: (q) => setState(() {
                      filtrados = _filtrar(q, itens);
                    }),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: accent),
                    decoration: InputDecoration(
                      hintText: 'Buscar por nome do material',
                      hintStyle: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: accent.withValues(alpha: 0.54)),
                      prefixIcon: Icon(LucideIcons.search, color: accent),
                      filled: true,
                      fillColor: cardColor,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: accent.withValues(alpha: 0.54)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: carregar,
                    child: itens.isEmpty
                        ? listaVazia('Nenhum material no estoque')
                        : (filtrados.isEmpty
                            ? listaVazia('Nenhum material encontrado')
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                itemCount: filtrados.length,
                                itemBuilder: (_, i) {
                                  final e = filtrados[i];
                                  final saldoPositivo = e.saldo > 0;
                                  final saldoColor =
                                      saldoPositivo ? Theme.of(context).colorScheme.tertiary : Colors.red.shade700;
                                  final saldoVisivel = e.saldo > 0 ? e.saldo : 0.0;
                                  return Container(
                                    margin: const EdgeInsets.symmetric(vertical: 6),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: cardColor,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.6),
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                          child: Icon(
                                            LucideIcons.package,
                                            color: accent,
                                            size: 28,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                e.nomeMaterial,
                                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                      color: accent,
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                "ID: ${e.idMaterial}",
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                      color: accent.withValues(alpha: 0.75),
                                                      fontSize: 14,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              "${saldoVisivel.toStringAsFixed(2)} kg",
                                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                    color: saldoColor,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              saldoPositivo ? "Disponível" : "Sem saldo",
                                              style: TextStyle(
                                                color: accent.withValues(alpha: 0.65),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              )),
                  ),
                ),
              ],
            ),
      ),
    );
  }

  List<Estoque> _ordenar(List<Estoque> base) {
    final copy = List<Estoque>.from(base);
    copy.sort((a, b) {
      final aDisponivel = a.saldo > 0;
      final bDisponivel = b.saldo > 0;
      if (aDisponivel != bDisponivel) {
        return aDisponivel ? -1 : 1;
      }
      return a.nomeMaterial.toLowerCase().compareTo(b.nomeMaterial.toLowerCase());
    });
    return copy;
  }

  List<Estoque> _filtrar(String query, List<Estoque> base) {
    final termo = query.trim().toLowerCase();
    if (termo.isEmpty) return List<Estoque>.from(base);
    return base
        .where((e) => e.nomeMaterial.toLowerCase().contains(termo))
        .toList();
  }
}
