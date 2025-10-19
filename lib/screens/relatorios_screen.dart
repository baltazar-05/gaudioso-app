import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/relatorio.dart';
import '../services/relatorio_service.dart';

class RelatoriosScreen extends StatefulWidget {
  const RelatoriosScreen({super.key});

  @override
  State<RelatoriosScreen> createState() => _RelatoriosScreenState();
}

class _RelatoriosScreenState extends State<RelatoriosScreen> {
  final service = RelatorioService();
  List<Relatorio> relatorios = [];
  bool carregando = false;

  DateTime? inicio;
  DateTime? fim;

  Future<void> _selecionarData(bool isInicio) async {
    final DateTime? selecionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale("pt", "BR"),
    );
    if (selecionada != null) {
      if (!mounted) return;
      setState(() {
        if (isInicio) {
          inicio = selecionada;
        } else {
          fim = selecionada;
        }
      });
    }
  }

  Future<void> _gerarRelatorio() async {
    if (inicio == null || fim == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecione o período de datas")),
      );
      return;
    }

    setState(() => carregando = true);

    try {
      final dataInicio = DateFormat("yyyy-MM-dd").format(inicio!);
      final dataFim = DateFormat("yyyy-MM-dd").format(fim!);

      final dados = await service.gerar(dataInicio, dataFim);
      if (!mounted) return;
      setState(() {
        relatorios = dados;
        carregando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => carregando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Relatórios"),
        backgroundColor: Colors.green.shade800,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selecionarData(true),
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      inicio == null
                          ? "Data Início"
                          : DateFormat("dd/MM/yyyy").format(inicio!),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selecionarData(false),
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      fim == null
                          ? "Data Fim"
                          : DateFormat("dd/MM/yyyy").format(fim!),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _gerarRelatorio,
              icon: const Icon(Icons.bar_chart),
              label: const Text("Gerar Relatório"),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: carregando
                  ? const Center(child: CircularProgressIndicator())
                  : relatorios.isEmpty
                      ? const Center(child: Text("Nenhum dado encontrado"))
                      : ListView.builder(
                          itemCount: relatorios.length,
                          itemBuilder: (_, i) {
                            final r = relatorios[i];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                leading: const Icon(Icons.inventory),
                                title: Text(r.nomeMaterial),
                                subtitle: Text(
                                  "Entradas: ${r.totalEntradas} | Saídas: ${r.totalSaidas}",
                                ),
                                trailing: Text(
                                  "Saldo: ${r.saldo}",
                                  style: TextStyle(
                                    color: r.saldo >= 0
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            )
          ],
        ),
      ),
    );
  }
}
