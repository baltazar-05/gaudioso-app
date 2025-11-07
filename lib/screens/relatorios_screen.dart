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
  final _buscaCtrl = TextEditingController();

  List<Relatorio> relatorios = [];
  List<Relatorio> filtrados = [];
  bool carregando = false;

  DateTime? inicio;
  DateTime? fim;

  @override
  void dispose() {
    _buscaCtrl.dispose();
    super.dispose();
  }

  Future<void> _selecionarData(bool isInicio) async {
    final selecionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('pt', 'BR'),
    );

    if (selecionada != null && mounted) {
      setState(() {
        if (isInicio) {
          inicio = selecionada;
        } else {
          fim = selecionada;
        }
      });
    }
  }

  Future<void> _gerarRelatorio({bool exibirAviso = true}) async {
    if (inicio == null || fim == null) {
      if (exibirAviso) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione o periodo de datas')),
        );
      }
      return;
    }

    setState(() => carregando = true);

    try {
      final dataInicio = DateFormat('yyyy-MM-dd').format(inicio!);
      final dataFim = DateFormat('yyyy-MM-dd').format(fim!);

      final dados = await service.gerar(dataInicio, dataFim);
      if (!mounted) return;
      setState(() {
        relatorios = dados;
        filtrados = _filtrar(_buscaCtrl.text, dados);
        carregando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => carregando = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }

  void _aplicarFiltro(String termo) {
    setState(() {
      filtrados = _filtrar(termo, relatorios);
    });
  }

  List<Relatorio> _filtrar(String termo, List<Relatorio> base) {
    final query = termo.trim().toLowerCase();
    if (query.isEmpty) return List<Relatorio>.from(base);
    return base.where((r) => r.matches(query)).toList();
  }

  Future<void> _refresh() => _gerarRelatorio(exibirAviso: false);

  String _formatDate(DateTime? value) {
    if (value == null) return '--';
    return DateFormat('dd/MM/yyyy').format(value);
  }

  String _formatPeso(double? value) {
    if (value == null) return '--';
    return '${value.toStringAsFixed(2)} kg';
  }

  String _formatCurrency(NumberFormat currency, double? value) {
    if (value == null) return '--';
    return currency.format(value);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = scheme.surface;
    final accent = scheme.onSurface;
    final buttonColor = scheme.tertiary;
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final subtitleStyle = const TextStyle(color: Colors.black87, fontSize: 13);

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
        title: const Text('Relatorios'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF81C784), Color(0xFF4CAF50)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selecionarData(true),
                    icon: Icon(Icons.date_range, color: accent),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: accent,
                      side: const BorderSide(color: Colors.black54),
                      backgroundColor: Colors.green.shade50,
                    ),
                    label: Text(
                      inicio == null
                          ? 'Data inicio'
                          : DateFormat('dd/MM/yyyy').format(inicio!),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selecionarData(false),
                    icon: Icon(Icons.date_range, color: accent),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: accent,
                      side: const BorderSide(color: Colors.black54),
                      backgroundColor: Colors.green.shade50,
                    ),
                    label: Text(
                      fim == null
                          ? 'Data fim'
                          : DateFormat('dd/MM/yyyy').format(fim!),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _gerarRelatorio,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.bar_chart),
              label: const Text('Gerar relatorio'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _buscaCtrl,
              onChanged: _aplicarFiltro,
              style: TextStyle(color: accent),
              decoration: InputDecoration(
                hintText: 'Buscar por lote, responsavel ou material',
                hintStyle: TextStyle(color: accent.withValues(alpha: 0.54)),
                prefixIcon: Icon(Icons.search, color: accent),
                filled: true,
                fillColor: cardColor,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: accent.withValues(alpha: 0.54)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: scheme.primary),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: carregando
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _refresh,
                      child: filtrados.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: const [
                                SizedBox(height: 120),
                                Center(
                                  child: Text(
                                    'Nenhum lote encontrado',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 16),
                              itemCount: filtrados.length,
                              itemBuilder: (_, i) {
                                final r = filtrados[i];
                                final pesoTexto = _formatPeso(r.pesoCalculado);
                                final valorTexto = _formatCurrency(
                                  currency,
                                  r.valorCalculado,
                                );
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: cardColor,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Theme(
                                    data: Theme.of(context).copyWith(
                                      dividerColor: Colors.transparent,
                                      splashColor: Colors.green.shade100
                                          .withValues(alpha: 0.3),
                                    ),
                                    child: ExpansionTile(
                                      tilePadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      textColor: accent,
                                      iconColor: accent,
                                      collapsedIconColor: accent,
                                      title: Text(
                                        r.identificador,
                                        style: TextStyle(
                                          color: accent,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Data: ${_formatDate(r.dataCadastro)}',
                                            style: subtitleStyle,
                                          ),
                                          Text(
                                            'Peso total: $pesoTexto  |  Valor total: $valorTexto',
                                            style: subtitleStyle,
                                          ),
                                          if (r.cadastradoPor != null)
                                            Text(
                                              'Cadastrado por: ${r.cadastradoPor}',
                                              style: subtitleStyle,
                                            ),
                                        ],
                                      ),
                                      childrenPadding:
                                          const EdgeInsets.fromLTRB(
                                            16,
                                            0,
                                            16,
                                            16,
                                          ),
                                      children: [
                                        _InfoRow(
                                          titulo: 'Fornecedor',
                                          valor: r.fornecedor ?? '--',
                                        ),
                                        _InfoRow(
                                          titulo: 'Saldo do periodo',
                                          valor: r.saldo != null
                                              ? '${r.saldo!.toStringAsFixed(2)} kg'
                                              : '--',
                                        ),
                                        if (r.totalEntradas != null ||
                                            r.totalSaidas != null) ...[
                                          const SizedBox(height: 12),
                                          Text(
                                            'Resumo de movimentacao',
                                            style: TextStyle(
                                              color: accent,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          if (r.totalEntradas != null)
                                            _InfoRow(
                                              titulo: 'Entradas',
                                              valor:
                                                  '${r.totalEntradas!.toStringAsFixed(2)} kg',
                                            ),
                                          if (r.totalSaidas != null)
                                            _InfoRow(
                                              titulo: 'Saidas',
                                              valor:
                                                  '${r.totalSaidas!.toStringAsFixed(2)} kg',
                                            ),
                                        ],
                                        if (r.observacao != null &&
                                            r.observacao!.isNotEmpty) ...[
                                          const SizedBox(height: 12),
                                          Text(
                                            'Observacoes',
                                            style: TextStyle(
                                              color: accent,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            r.observacao!,
                                            style: TextStyle(
                                              color: accent.withValues(alpha: 0.87),
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 12),
                                        if (r.itens.isEmpty)
                                          const Text(
                                            'Nao ha itens cadastrados para este lote.',
                                            style: TextStyle(
                                              color: Colors.black87,
                                            ),
                                          )
                                        else
                                          Column(
                                            children: r.itens
                                                .map(
                                                  (item) => _LoteItemCard(
                                                    item: item,
                                                    currency: currency,
                                                  ),
                                                )
                                                .toList(),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String titulo;
  final String valor;

  const _InfoRow({required this.titulo, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$titulo: ',
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(valor, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}

class _LoteItemCard extends StatelessWidget {
  final RelatorioItem item;
  final NumberFormat currency;

  const _LoteItemCard({required this.item, required this.currency});

  @override
  Widget build(BuildContext context) {
    final peso = item.peso ?? item.quantidade;
    final valorUnitario = item.valorUnitario;
    final valorTotal = item.valorTotal;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.descricao,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              if (item.quantidade != null &&
                  (item.peso == null ||
                      item.quantidade!.toStringAsFixed(2) !=
                          item.peso!.toStringAsFixed(2)))
                Text(
                  'Qtd: ${item.quantidade!.toStringAsFixed(2)}',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.87)),
                ),
              if (peso != null)
                Text(
                  'Peso: ${peso.toStringAsFixed(2)} kg',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.87)),
                ),
              if (valorUnitario != null)
                Text(
                  'Valor unit.: ${currency.format(valorUnitario)}',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.87)),
                ),
              if (valorTotal != null)
                Text(
                  'Valor total: ${currency.format(valorTotal)}',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.87)),
                ),
            ],
          ),
          if (item.observacao != null && item.observacao!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Obs: ${item.observacao}',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.87)),
            ),
          ],
        ],
      ),
    );
  }
}

