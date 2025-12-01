import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../models/saida.dart';
import '../../models/cliente.dart';
import '../../models/material.dart';
import '../../services/auth_service.dart';
import '../../services/saida_service.dart';
import '../../services/cliente_service.dart';
import '../../services/material_service.dart';
import 'package:gaudioso_app/screens/menu_screen.dart';

class SaidaFormScreen extends StatefulWidget {
  final Saida? saida;
  const SaidaFormScreen({super.key, this.saida});

  @override
  State<SaidaFormScreen> createState() => _SaidaFormScreenState();
}

class _SaidaFormScreenState extends State<SaidaFormScreen> {
  static const _primaryColor = Color(0xFF4CAF50);
  static const _secondaryBackground = Color(0xFFA5D6A7);
  static const _cardBackground = Color(0xFFF5F5F5);
  static const _highlightColor = Color(0xFF2E7D32);
  static const _textColor = Color(0xFF212121);
  static const _iconColor = _textColor;
  static const _deleteColor = Color(0xFFE53935);

  TextStyle _poppins({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? height,
  }) {
    final base = Theme.of(context).textTheme.bodyMedium ?? const TextStyle();
    return base.copyWith(
      color: color ?? _textColor,
      fontSize: fontSize,
      fontWeight: fontWeight ?? FontWeight.w400,
      fontStyle: fontStyle,
      height: height,
    );
  }
  final _formKey = GlobalKey<FormState>();
  final _saidaService = SaidaService();
  final _auth = AuthService();
  final _materialService = MaterialService();
  final _clienteService = ClienteService();

  List<Cliente> _clientees = [];
  List<MaterialItem> _materiais = [];

  Cliente? _clienteSelecionado;
  final List<_SaidaItem> _itens = [];

  late DateTime _registroData;
  bool _carregandoDados = false;

  @override
  void initState() {
    super.initState();
    _registroData = widget.saida != null
        ? _parseDateTime(widget.saida!.data)
        : DateTime.now();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => _carregandoDados = true);
    try {
      final results = await Future.wait([
        _clienteService.listar(),
        _materialService.listar(),
      ]);
      final clientees = (results[0] as List<Cliente>)
        ..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
      final materiais = (results[1] as List<MaterialItem>)
        ..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));

      setState(() {
        _clientees = clientees;
        _materiais = materiais;
      });

      final saida = widget.saida;
      if (saida != null) {
        try {
          final cliente = clientees.firstWhere((f) => f.id == saida.idCliente);
          setState(() => _clienteSelecionado = cliente);
        } catch (_) {}
        try {
          final material = materiais.firstWhere((m) => m.id == saida.idMaterial);
          setState(() {
            _itens
              ..clear()
              ..add(
                _SaidaItem(
                  material: material,
                  // Preserva pesagens múltiplas existentes; se vazio, usa o peso total
                  pesos: (saida.pesosJson.isNotEmpty)
                      ? saida.pesosJson
                      : (saida.peso > 0 ? [saida.peso] : <double>[]),
                  // Usa o preço salvo na saída em vez do preço padrão do material
                  precoUnitario: saida.precoUnitario,
                ),
              );
          });
        } catch (_) {}
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: _deleteColor,
          content: Text('Erro ao carregar dados: $e'),
        ),
      );
    } finally {
      if (mounted) setState(() => _carregandoDados = false);
    }
  }

  Future<void> _salvar() async {
    if (_clienteSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: _deleteColor,
          content: const Text('Selecione o cliente'),
        ),
      );
      return;
    }
    if (_itens.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: _deleteColor,
          content: const Text('Adicione pelo menos um item'),
        ),
      );
      return;
    }

    final user = await _auth.currentUser();
    final registradoPor = _extractUserId(user);
    final registroBase = widget.saida != null ? _registroData : DateTime.now();
    final dataStr = _formatForApi(registroBase); // compat interna

    try {
      final existing = widget.saida;
      if (existing != null) {
        final item = _itens.first;
        final saidaAtualizada = Saida(
          id: existing.id,
          idMaterial: item.material.id!,
          idCliente: _clienteSelecionado!.id!,
          numeroLote: null,
          pesosJson: item.pesos,
          precoUnitario: item.precoUnitario,
          qtdPesagens: null,
          peso: item.pesoTotal,
          valorTotal: null,
          data: dataStr,
          registradoPor: registradoPor,
        );
        await _saidaService.atualizar(saidaAtualizada);
      } else {
        for (final item in _itens) {
          final nova = Saida(
            id: null,
            idMaterial: item.material.id!,
            idCliente: _clienteSelecionado!.id!,
            numeroLote: null,
            pesosJson: item.pesos,
            precoUnitario: item.precoUnitario,
            qtdPesagens: null,
            peso: item.pesoTotal,
            valorTotal: null,
            data: dataStr,
            registradoPor: registradoPor,
          );
          await _saidaService.adicionar(nova);
        }
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: _deleteColor,
          content: Text('Erro ao salvar: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.saida != null;
    final baseTheme = Theme.of(context);
    final customScheme = baseTheme.colorScheme.copyWith(
      primary: _primaryColor,
      secondary: _secondaryBackground,
      surface: _cardBackground,
      onPrimary: _textColor,
      onSecondary: _textColor,
      onSurface: _textColor,
    );
    final bg = _secondaryBackground;
    final surface = _cardBackground;
    final actionColor = _primaryColor;
    final primaryActionIcon = LucideIcons.save;
    final primaryActionLabel =
        editando ? 'Salvar alteracoes' : 'Cadastrar lote';
    final labelStyle = _poppins(color: _textColor.withValues(alpha: 0.85));
    final themedData = baseTheme.copyWith(
      colorScheme: customScheme,
      scaffoldBackgroundColor: bg,
      appBarTheme: baseTheme.appBarTheme.copyWith(
        backgroundColor: _primaryColor,
        foregroundColor: _textColor,
        elevation: 0,
        iconTheme: IconThemeData(color: _iconColor),
        titleTextStyle: _poppins(
          color: _textColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: baseTheme.textTheme.apply(bodyColor: _textColor, displayColor: _textColor),
      primaryTextTheme: baseTheme.primaryTextTheme,
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(_iconColor),
          overlayColor: WidgetStateProperty.all(
            _iconColor.withValues(alpha: 0.12),
          ),
        ),
      ),
      textSelectionTheme: baseTheme.textSelectionTheme.copyWith(
        cursorColor: _highlightColor,
        selectionColor: _primaryColor.withValues(alpha: 0.25),
        selectionHandleColor: _highlightColor,
      ),
      snackBarTheme: baseTheme.snackBarTheme.copyWith(
        backgroundColor: _highlightColor,
        behavior: SnackBarBehavior.floating,
        contentTextStyle: _poppins(color: _cardBackground),
        actionTextColor: _cardBackground,
      ),
      progressIndicatorTheme: baseTheme.progressIndicatorTheme.copyWith(
        color: _primaryColor,
      ),
      bottomSheetTheme: baseTheme.bottomSheetTheme.copyWith(
        backgroundColor: _cardBackground,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      inputDecorationTheme: baseTheme.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: _cardBackground,
        labelStyle: _poppins(color: _textColor.withValues(alpha: 0.7)),
        hintStyle: _poppins(color: _textColor.withValues(alpha: 0.6)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _textColor.withValues(alpha: 0.2)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: _highlightColor, width: 1.8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: actionColor,
          foregroundColor: _textColor,
          textStyle: _poppins(color: _textColor),
          elevation: 1,
        ),
      ),
    );

    return Theme(
      data: themedData,
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: _primaryColor,
          foregroundColor: _textColor,
          centerTitle: true,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                editando ? LucideIcons.pencil : LucideIcons.plus,
                size: 22,
                color: _iconColor,
              ),
              const SizedBox(width: 8),
              Text(
                editando ? 'Editar Saida' : 'Nova Saida',
                style: _poppins(fontSize: 22, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF81C784), Color(0xFF4CAF50)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: _carregandoDados
              ? const Center(
                  child: CircularProgressIndicator(color: _primaryColor),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: _textColor.withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                        Text('Cliente', style: labelStyle),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<Cliente>(
                          value: _clienteSelecionado,
                          dropdownColor: _cardBackground,
                          iconEnabledColor: _highlightColor,
                          iconDisabledColor:
                              _textColor.withValues(alpha: 0.35),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            filled: true,
                          ),
                          hint: Text(
                            'Selecione um cliente',
                            style: _poppins(
                              color: _textColor.withValues(alpha: 0.6),
                            ),
                          ),
                          style: _poppins(),
                          items: _clientees
                              .map(
                                (f) => DropdownMenuItem(
                                  value: f,
                                  child: Text(f.nome, style: _poppins()),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _clienteSelecionado = value),
                        ),
                        const SizedBox(height: 16),
                        if (_itens.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _textColor.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Text(
                              'Nenhum item adicionado',
                              style: _poppins(
                                color: _textColor.withValues(alpha: 0.6),
                              ),
                            ),
                          )
                        else
                          Column(
                            children: [
                              for (int i = 0; i < _itens.length; i++)
                                _buildItemCard(_itens[i], i),
                            ],
                          ),
                        const SizedBox(height: 12),
                        if (!editando)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: ElevatedButton.icon(
                              onPressed: () => _abrirEditorItem(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: actionColor,
                                foregroundColor: _textColor,
                                elevation: 1,
                              ),
                              icon: Icon(
                                LucideIcons.plus,
                                color: _textColor,
                              ),
                              label: Text(
                                'Adicionar item',
                                style: _poppins(color: _textColor),
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        _buildResumo(),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _salvar,
                          icon: Icon(primaryActionIcon, color: _textColor),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: actionColor,
                            foregroundColor: _textColor,
                            elevation: 1,
                          ),
                          label: Text(
                            primaryActionLabel,
                            style: _poppins(color: _textColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ),
        ),
        bottomNavigationBar: _shortcutBottomBar(context),
    ));
  }

  Widget _shortcutBottomBar(BuildContext context) {
    final inactive = _textColor.withValues(alpha: 0.6);
    Future<void> go(int index) async {
      final user = await _auth.currentUser();
      final display = (user?['nome'] ?? user?['username'] ?? '') as String;
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => MenuScreen(username: display, initialIndex: index)),
        (route) => false,
      );
    }
    Widget navItem({required IconData icon, required String label, required int index}) {
      return GestureDetector(
        onTap: () => go(index),
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 72,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: inactive, size: 22),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontSize: 11, color: inactive)),
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
            navItem(icon: Icons.home_outlined, label: 'Resumo', index: 0),
            navItem(icon: LucideIcons.arrowDownUp, label: 'Fluxo', index: 1),
            navItem(icon: LucideIcons.database, label: 'Estoque', index: 2),
            navItem(icon: LucideIcons.chartBar, label: 'Relatórios', index: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildResumo() {
    final totalPesagens = _itens.fold<int>(0, (acc, item) => acc + item.bagCount);
    final totalPeso = _itens.fold<double>(0, (acc, item) => acc + item.pesoTotal);
    final totalValor = _itens.fold<double>(0, (acc, item) => acc + item.valorTotal);

  return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _textColor.withValues(alpha: 0.35)),
      ),
      child: Text(
        'Itens: ${_itens.length}   |   Pesagens: $totalPesagens   |   Peso total: ${totalPeso.toStringAsFixed(2)} kg   |   Valor total: R\$ ${totalValor.toStringAsFixed(2)}',
        style: _poppins(),
      ),
    );
  }

  Widget _buildItemCard(_SaidaItem item, int index) {
    final pesosDescricao = item.pesos.map((p) => '${p.toStringAsFixed(2)} kg').join(', ');
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _textColor.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CircleIconButton(
            icon: LucideIcons.pencil,
            iconColor: _iconColor,
            tooltip: 'Editar item',
            onTap: () => _abrirEditorItem(item: item, index: index),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.material.nome,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pesagens: ${item.bagCount}   |   Peso total: ${item.pesoTotal.toStringAsFixed(2)} kg',
                  style: const TextStyle(color: Colors.black87),
                ),
                const SizedBox(height: 2),
                Text(
                  'Preço unitário: R\$ ${item.precoUnitario.toStringAsFixed(2)}   |   Valor total: R\$ ${item.valorTotal.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.black87),
                ),
                if (pesosDescricao.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Pesos: $pesosDescricao',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          _CircleIconButton(
            icon: LucideIcons.trash2,
            iconColor: _deleteColor,
            tooltip: 'Remover item',
            onTap: () => setState(() => _itens.removeAt(index)),
          ),
        ],
      ),
    );
  }

  void _abrirEditorItem({_SaidaItem? item, int? index}) async {
    MaterialItem? sel = item?.material;
    final pesosCtrl = TextEditingController(
      text: item?.pesos.map((p) => p.toStringAsFixed(2)).join(' + ') ?? '',
    );
    final precoCtrl = TextEditingController(
      text: (item?.precoUnitario ?? sel?.precoVenda ?? 0).toStringAsFixed(2),
    );

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModal) {
            final localLabelStyle = Theme.of(ctx)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600);
            final pesos = _parsePesos(pesosCtrl.text);
            final pesoTotal = pesos.fold<double>(0, (sum, p) => sum + p);
            final bagCount = pesos.length;
            final precoUnitario = double.tryParse(precoCtrl.text.replaceAll(',', '.')) ?? 0;
            final valorTotal = precoUnitario * pesoTotal;

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Item da saída',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        _CircleIconButton(
                          icon: LucideIcons.x,
                          iconColor: _iconColor,
                          tooltip: 'Fechar',
                          onTap: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Material', style: localLabelStyle),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<MaterialItem>(
                          value: sel,
                          decoration: const InputDecoration(
                            hintText: 'Selecione um material',
                            border: OutlineInputBorder(),
                            filled: true,
                          ),
                          items: _materiais
                              .map(
                                (m) => DropdownMenuItem(
                                  value: m,
                                  child: Text(m.nome),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            sel = value;
                            if (sel != null) {
                              precoCtrl.text = sel!.precoVenda.toStringAsFixed(2);
                            }
                            setModal(() {});
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pesagens (ex: 23+52+45)', style: localLabelStyle),
                        const SizedBox(height: 6),
                        TextField(
                          controller: pesosCtrl,
                          decoration: const InputDecoration(
                            hintText: 'Informe as pesagens separadas por +',
                            border: OutlineInputBorder(),
                            filled: true,
                          ),
                          onChanged: (_) => setModal(() {}),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Preço unitário (R\$)', style: localLabelStyle),
                        const SizedBox(height: 6),
                        TextField(
                          controller: precoCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            hintText: 'Informe o preço unitário',
                            border: OutlineInputBorder(),
                            filled: true,
                          ),
                          onChanged: (_) => setModal(() {}),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('Pesagens: $bagCount   |   Peso total: ${pesoTotal.toStringAsFixed(2)} kg'),
                    Text('Valor total: R\$ ${valorTotal.toStringAsFixed(2)}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        textStyle: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.black87),
                      ),
                      onPressed: () {
                        final pesosValidos = _parsePesos(pesosCtrl.text);
                        final preco = double.tryParse(precoCtrl.text.replaceAll(',', '.')) ?? 0;
                        if (sel == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Selecione o material')),
                          );
                          return;
                        }
                        if (pesosValidos.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Informe ao menos uma pesagem válida')),
                          );
                          return;
                        }
                        if (preco <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Informe um preço válido')),
                          );
                          return;
                        }
                        final novo = _SaidaItem(
                          material: sel!,
                          pesos: pesosValidos,
                          precoUnitario: preco,
                        );
                        setState(() {
                          if (index != null) {
                            _itens[index] = novo;
                          } else {
                            _itens.add(novo);
                          }
                        });
                        Navigator.pop(ctx);
                      },
                      child: Text(
                        'Salvar item',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<double> _parsePesos(String texto) {
    final partes = texto
        .split(RegExp('[+;\\r\\n]'))
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
    final pesos = <double>[];
    for (final parte in partes) {
      final valor = double.tryParse(parte.replaceAll(',', '.'));
      if (valor != null && valor > 0) {
        pesos.add(valor);
      }
    }
    return pesos;
  }

  int _extractUserId(Map<String, dynamic>? json) {
    if (json == null) return 0;
    for (final chave in const ['id', 'userId', 'idUsuario']) {
      final valor = json[chave];
      if (valor is int) return valor;
      if (valor is num) return valor.toInt();
      if (valor is String) {
        final convertido = int.tryParse(valor);
        if (convertido != null) return convertido;
      }
    }
    return 0;
  }

  String _formatForApi(DateTime dt) =>
      DateFormat('yyyy-MM-dd HH:mm:ss').format(dt);

  DateTime _parseDateTime(String data) {
    final texto = data.trim();
    if (texto.isEmpty) return DateTime.fromMillisecondsSinceEpoch(0);
    try {
      return DateTime.parse(texto);
    } catch (_) {
      final normalizado = texto.replaceAll(' ', 'T');
      try {
        return DateTime.parse(normalizado);
      } catch (_) {
        if (texto.length == 10) {
          try {
            return DateTime.parse('${texto}T00:00:00');
          } catch (_) {}
        }
      }
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;
  final String? tooltip;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.iconColor = const Color(0xFF212121),
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final overlay = iconColor.withValues(alpha: 0.12);
    final button = Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        hoverColor: overlay,
        highlightColor: overlay,
        splashColor: overlay,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: iconColor, size: 20),
        ),
      ),
    );

    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}

class _SaidaItem {
  final MaterialItem material;
  final List<double> pesos;
  final double precoUnitario;

  _SaidaItem({
    required this.material,
    required this.pesos,
    required this.precoUnitario,
  });

  int get bagCount => pesos.length;
  double get pesoTotal => pesos.fold<double>(0, (sum, p) => sum + p);
  double get valorTotal => precoUnitario * pesoTotal;
}
