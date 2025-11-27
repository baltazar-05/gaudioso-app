import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../services/relatorio_service.dart';
import 'menu_screen.dart';

const _topBarGradient = LinearGradient(
  colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

const _bodyGradient = LinearGradient(
  colors: [Color(0xFF81C784), Color(0xFF66BB6A)],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

final ButtonStyle _outlineButtonStyle = OutlinedButton.styleFrom(
  foregroundColor: Colors.black87,
  side: const BorderSide(color: Colors.black54),
  padding: const EdgeInsets.symmetric(vertical: 14),
  textStyle: const TextStyle(fontWeight: FontWeight.w600),
);

final ButtonStyle _primaryButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: Colors.white,
  foregroundColor: Colors.black87,
  side: const BorderSide(color: Color(0xFF2E7D32)),
  minimumSize: const Size.fromHeight(48),
  textStyle: const TextStyle(fontWeight: FontWeight.w700),
);

PreferredSizeWidget _buildRelatorioAppBar(String title) {
  return AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    foregroundColor: Colors.black,
    flexibleSpace: Container(
      decoration: const BoxDecoration(gradient: _topBarGradient),
    ),
    title: Text(
      title,
      style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
    ),
  );
}

Widget _relatorioBackground({required Widget child}) {
  return Container(
    decoration: const BoxDecoration(gradient: _bodyGradient),
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    ),
  );
}

class _RelatorioPanel extends StatelessWidget {
  final Widget child;
  const _RelatorioPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _RelatorioBottomBar extends StatelessWidget {
  final int currentIndex;
  final String username;
  const _RelatorioBottomBar({required this.currentIndex, required this.username});

  void _go(BuildContext context, int index) {
    if (index == currentIndex) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => MenuScreen(username: username, initialIndex: index)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final inactive = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
    final active = Theme.of(context).colorScheme.primary;
    Widget item(IconData icon, String label, int index) {
      final selected = index == currentIndex;
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _go(context, index),
        child: SizedBox(
          width: 80,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: selected ? active : inactive, size: 22),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontSize: 11, color: selected ? active : inactive)),
            ],
          ),
        ),
      );
    }

    return BottomAppBar(
      color: Colors.white,
      elevation: 8,
      child: SizedBox(
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            item(Icons.home_outlined, 'Resumo', 0),
            item(LucideIcons.arrowDownUp, 'Fluxo', 1),
            item(LucideIcons.database, 'Estoque', 2),
            item(LucideIcons.chartBar, 'Relatorios', 3),
          ],
        ),
      ),
    );
  }
}

class RelatoriosScreen extends StatelessWidget {
  final String username;
  final bool hideBottomBar;
  const RelatoriosScreen({super.key, required this.username, this.hideBottomBar = false});

  static final _relatorios = [
    _RelatorioTipo(
      id: 'lucro_real',
      titulo: 'Lucro Real',
      descricao: 'Seleciona o periodo e gera o PDF completo.',
      icone: Icons.assignment,
    ),
    _RelatorioTipo(
      id: 'lucro_esperado',
      titulo: 'Lucro Esperado',
      descricao: 'Projecao do estoque atual no modelo HTML/PDF.',
      icone: Icons.trending_up,
    ),
    _RelatorioTipo(
      id: 'movimentacao_30',
      titulo: 'Movimentacao',
      descricao: 'Consulta o periodo para gerar o relatorio.',
      icone: Icons.swap_vert_circle_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildRelatorioAppBar('Relatorios'),
      bottomNavigationBar: hideBottomBar ? null : _RelatorioBottomBar(currentIndex: 3, username: username),
      body: _relatorioBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                'Escolha qual relatorio deseja gerar',
                style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              child: _RelatorioPanel(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _relatorios.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, index) {
                    final tipo = _relatorios[index];
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _abrir(context, tipo),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                          ),
                          child: Row(
                            children: [
                              Icon(tipo.icone, color: Colors.black87),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tipo.titulo,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      tipo.descricao,
                                      style: TextStyle(color: Colors.grey.shade700),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: Colors.black87),
                            ],
                          ),
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
    );
  }

  void _abrir(BuildContext context, _RelatorioTipo tipo) {
    Widget page;
    switch (tipo.id) {
      case 'lucro_real':
        page = RelatorioLucroRealPage(username: username);
        break;
      case 'lucro_esperado':
        page = RelatorioLucroEsperadoPage(username: username);
        break;
      case 'movimentacao_30':
        page = RelatorioMovimentacaoPage(username: username);
        break;
      default:
        page = RelatorioPlaceholderPage(titulo: tipo.titulo, username: username);
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }
}

class RelatorioLucroRealPage extends StatelessWidget {
  final String username;
  const RelatorioLucroRealPage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    final service = RelatorioService();
    return _RelatorioBasePage(
      username: username,
      title: 'Lucro Real',
      description: 'Selecione o periodo e gere o PDF de lucro real (compras, vendas, despesas e margens).',
      filePrefix: 'Relatorio_Lucro',
      onGeneratePdf: (ini, fim) => service.gerarPdf(ini, fim, usuario: username),
    );
  }
}

class RelatorioLucroEsperadoPage extends StatelessWidget {
  final String username;
  const RelatorioLucroEsperadoPage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    final service = RelatorioService();
    return _RelatorioBasePage(
      username: username,
      title: 'Lucro Esperado',
      description: 'Relatorio baseado no estoque atual. Nao requer selecao de datas.',
      filePrefix: 'Relatorio_Lucro_Esperado',
      requiresDateRange: false,
      onGeneratePdf: (ini, fim) => service.gerarLucroEsperadoPdf(usuario: username, dataInicio: ini, dataFim: fim),
    );
  }
}

class RelatorioMovimentacaoPage extends StatelessWidget {
  final String username;
  const RelatorioMovimentacaoPage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    final service = RelatorioService();
    return _RelatorioBasePage(
      username: username,
      title: 'Movimentacao',
      description: 'Selecione o periodo e gere o PDF consolidado de entradas e saidas (pesos e valores).',
      filePrefix: 'Relatorio_Movimentacao',
      onGeneratePdf: (ini, fim) => service.gerarMovimentacaoPdf(ini, fim),
    );
  }
}

class _RelatorioBasePage extends StatefulWidget {
  final String username;
  final String title;
  final String description;
  final String filePrefix;
  final Future<Uint8List> Function(String dataInicio, String dataFim) onGeneratePdf;
  final bool requiresDateRange;

  const _RelatorioBasePage({
    required this.username,
    required this.title,
    required this.description,
    required this.filePrefix,
    required this.onGeneratePdf,
    this.requiresDateRange = true,
  });

  @override
  State<_RelatorioBasePage> createState() => _RelatorioBasePageState();
}

class _RelatorioBasePageState extends State<_RelatorioBasePage> {
  final DateFormat _apiDate = DateFormat('yyyy-MM-dd');
  DateTime? inicio;
  DateTime? fim;
  bool baixando = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildRelatorioAppBar(widget.title),
      bottomNavigationBar: _RelatorioBottomBar(currentIndex: 3, username: widget.username),
      body: _relatorioBackground(
        child: _RelatorioPanel(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      Text(
                        widget.description,
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      if (widget.requiresDateRange) ...[
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _PresetButton(label: 'Ultimos 7 dias', onTap: () => _aplicarPreset(7)),
                            _PresetButton(label: 'Ultimos 30 dias', onTap: () => _aplicarPreset(30)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                style: _outlineButtonStyle,
                                onPressed: () => _selecionarData(true),
                                icon: const Icon(Icons.date_range, color: Colors.black87),
                                label: Text(
                                  inicio == null ? 'Data inicio' : DateFormat('dd/MM/yyyy').format(inicio!),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                style: _outlineButtonStyle,
                                onPressed: () => _selecionarData(false),
                                icon: const Icon(Icons.date_range, color: Colors.black87),
                                label: Text(
                                  fim == null ? 'Data fim' : DateFormat('dd/MM/yyyy').format(fim!),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.inventory_2_outlined, color: Colors.black87),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Relatorio baseado no estoque atual. Nao requer selecao de datas.',
                                  style: TextStyle(color: Colors.black87),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: _primaryButtonStyle,
                  onPressed: baixando ? null : _baixarPdf,
                  icon: baixando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        )
                      : const Icon(Icons.picture_as_pdf, color: Colors.black87),
                  label: Text(baixando ? 'Gerando PDF...' : 'Gerar relatorio'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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

  void _aplicarPreset(int dias) {
    final today = DateTime.now();
    final end = DateTime(today.year, today.month, today.day);
    final start = end.subtract(Duration(days: dias - 1));
    setState(() {
      inicio = start;
      fim = end;
    });
  }

  Future<void> _baixarPdf() async {
    if (!_rangeValido()) return;
    setState(() => baixando = true);
    try {
      final ini = inicio != null ? _apiDate.format(inicio!) : '';
      final end = fim != null ? _apiDate.format(fim!) : '';
      final bytes = await widget.onGeneratePdf(ini, end);
      final dir = await getTemporaryDirectory();
      final arquivo = File(
        "${dir.path}/${widget.filePrefix}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf",
      );
      await arquivo.writeAsBytes(bytes, flush: true);
      if (!mounted) return;
      _mostrarAviso('PDF salvo em ${arquivo.path}');
      await OpenFilex.open(arquivo.path);
    } catch (e) {
      if (!mounted) return;
      _mostrarAviso('Erro ao gerar PDF: $e');
    } finally {
      if (mounted) setState(() => baixando = false);
    }
  }

  bool _rangeValido() {
    if (!widget.requiresDateRange) return true;
    if (inicio == null || fim == null) {
      _mostrarAviso('Selecione as datas de inicio e fim.');
      return false;
    }
    if (inicio!.isAfter(fim!)) {
      _mostrarAviso('Data inicial deve ser anterior ou igual a data final.');
      return false;
    }
    return true;
  }

  void _mostrarAviso(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensagem)));
  }
}

class _PresetButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PresetButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        side: BorderSide(color: Colors.black.withValues(alpha: 0.2)),
      ),
      onPressed: onTap,
      child: Text(label),
    );
  }
}

class RelatorioPlaceholderPage extends StatelessWidget {
  final String titulo;
  final String username;
  const RelatorioPlaceholderPage({super.key, required this.titulo, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildRelatorioAppBar(titulo),
      bottomNavigationBar: _RelatorioBottomBar(currentIndex: 3, username: username),
      body: _relatorioBackground(
        child: _RelatorioPanel(
          child: const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Este relatorio estara disponivel em breve.',
                style: TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RelatorioTipo {
  final String id;
  final String titulo;
  final String descricao;
  final IconData icone;

  const _RelatorioTipo({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.icone,
  });
}
