import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/material.dart';
import '../services/material_service.dart';

class MaterialFormScreen extends StatefulWidget {
  final MaterialItem? item;
  const MaterialFormScreen({super.key, this.item});

  @override
  State<MaterialFormScreen> createState() => _MaterialFormScreenState();
}

class _MaterialFormScreenState extends State<MaterialFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = MaterialService();

  late TextEditingController _nomeCtrl;
  late TextEditingController _precoCompraCtrl;
  late TextEditingController _precoVendaCtrl;
  
  // Helpers para reduzir repetição mantendo o visual
  static const _textColor = Colors.black87;

  TextStyle _poppins({
    double? fontSize,
    FontWeight weight = FontWeight.w400,
    Color color = _textColor,
  }) {
    final base = Theme.of(context).textTheme.bodyMedium ?? const TextStyle();
    return base.copyWith(fontSize: fontSize, fontWeight: weight, color: color);
  }

  @override
  void initState() {
    super.initState();
    _nomeCtrl = TextEditingController(text: widget.item?.nome ?? "");
    _precoCompraCtrl = TextEditingController(
      text: widget.item?.precoCompra.toString() ?? "",
    );
    _precoVendaCtrl = TextEditingController(
      text: widget.item?.precoVenda.toString() ?? "",
    );
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _precoCompraCtrl.dispose();
    _precoVendaCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final item = MaterialItem(
      id: widget.item?.id,
      nome: _nomeCtrl.text.trim(),
      precoCompra:
          double.tryParse(_precoCompraCtrl.text.replaceAll(',', '.')) ?? 0,
      precoVenda:
          double.tryParse(_precoVendaCtrl.text.replaceAll(',', '.')) ?? 0,
    );

    if (widget.item == null) {
      await _service.adicionar(item);
    } else {
      await _service.atualizar(item);
    }

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.item != null;

    final br12 = BorderRadius.circular(12);
    InputDecoration inputDecoration({IconData? prefix}) => InputDecoration(
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          prefixIcon: prefix != null ? Icon(prefix, color: _textColor) : null,
          enabledBorder: OutlineInputBorder(
            borderRadius: br12,
            borderSide: BorderSide(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.54),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: br12,
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 1.2,
            ),
          ),
        );

    Widget label(String text) => Text(text, style: _poppins());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
        foregroundColor: _textColor,
        centerTitle: true,
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
          child: Row(
            key: ValueKey(editando),
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(editando ? LucideIcons.pencil : LucideIcons.plus, size: 22, color: _textColor),
              const SizedBox(width: 8),
              Text(
                editando ? 'Editar Material' : 'Novo Material',
                style: _poppins(fontSize: 22, weight: FontWeight.w500),
              ),
            ],
          ),
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
        child: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Hero(
                      tag: 'material_${widget.item?.id ?? 'novo'}',
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.grey.shade200,
                        child: const Icon(
                          LucideIcons.recycle,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    label('Nome'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _nomeCtrl,
                      style: _poppins(),
                      decoration: inputDecoration(prefix: LucideIcons.recycle),
                      validator: (v) => v == null || v.isEmpty ? 'Digite o nome' : null,
                    ),
                    const SizedBox(height: 12),
                    label('Preço de Compra'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _precoCompraCtrl,
                      style: _poppins(),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: inputDecoration(prefix: LucideIcons.shoppingCart),
                    ),
                    const SizedBox(height: 12),
                    label('Preço de Venda'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _precoVendaCtrl,
                      style: _poppins(),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: inputDecoration(prefix: LucideIcons.badgeDollarSign),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: _salvar,
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        textStyle: _poppins(weight: FontWeight.w600, color: Colors.white),
                      ),
                      icon: const Icon(LucideIcons.save, color: Color.fromARGB(255, 7, 7, 7)),
                      label: Text(
                        editando ? 'Salvar alteracoes' : 'Cadastrar',
                        style: _poppins(
                          color: const Color.fromARGB(255, 2, 2, 2),
                          weight: FontWeight.w500,
                        ),
                      ),
                    )
                  ],
          ),
        ),
          ),
        ),
      ),
      ),
    );
  }
}






