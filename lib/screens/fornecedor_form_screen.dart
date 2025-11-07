import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../models/fornecedor.dart';
import '../services/fornecedor_service.dart';
import '../utils/cpf_cnpj_input_formatter.dart';
import '../utils/validators.dart';

class FornecedorFormScreen extends StatefulWidget {
  final Fornecedor? fornecedor;
  const FornecedorFormScreen({super.key, this.fornecedor});

  @override
  State<FornecedorFormScreen> createState() => _FornecedorFormScreenState();
}

class _FornecedorFormScreenState extends State<FornecedorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = FornecedorService();
  final telMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  late TextEditingController _nomeCtrl;
  late TextEditingController _docCtrl;
  late TextEditingController _telCtrl;
  late TextEditingController _endCtrl;

  @override
  void initState() {
    super.initState();
    _nomeCtrl = TextEditingController(text: widget.fornecedor?.nome ?? '');
    _docCtrl = TextEditingController(text: widget.fornecedor?.documento ?? '');
    _telCtrl = TextEditingController(text: widget.fornecedor?.telefone ?? '');
    _endCtrl = TextEditingController(text: widget.fornecedor?.endereco ?? '');
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _docCtrl.dispose();
    _telCtrl.dispose();
    _endCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final fornecedor = Fornecedor(
      id: widget.fornecedor?.id,
      nome: _nomeCtrl.text.trim(),
      documento: _docCtrl.text.trim(),
      telefone: _telCtrl.text.trim(),
      endereco: _endCtrl.text.trim(),
    );

    if (widget.fornecedor == null) {
      await _service.adicionar(fornecedor);
    } else {
      await _service.atualizar(fornecedor);
    }

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.fornecedor != null;
    final scheme = Theme.of(context).colorScheme;
    final bg = Theme.of(context).scaffoldBackgroundColor;

    InputDecoration inputDecoration({IconData? prefix}) => InputDecoration(
          filled: true,
          fillColor: scheme.surface,
          prefixIcon:
              prefix != null ? Icon(prefix, color: Colors.black87) : null,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: scheme.onSurface.withValues(alpha: 0.54)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: scheme.primary, width: 1.2),
          ),
        );

    Widget label(String text) => Text(
          text,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w500),
        );

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, anim) =>
              FadeTransition(opacity: anim, child: child),
          child: Row(
            key: ValueKey(editando),
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                editando ? LucideIcons.pencil : LucideIcons.plus,
                size: 20,
                color: const Color.fromARGB(255, 0, 0, 0),
              ),
              const SizedBox(width: 8),
              Text(
                editando ? 'Editar Fornecedor' : 'Novo Fornecedor',
                style: const TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
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
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  Hero(
                    tag: 'fornecedor_${widget.fornecedor?.id ?? 'novo'}',
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.grey.shade200,
                      child: const Icon(LucideIcons.user, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 20),
                  label('Nome'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nomeCtrl,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurface),
                    decoration: inputDecoration(prefix: LucideIcons.user),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Digite o nome' : null,
                  ),
                  const SizedBox(height: 12),
                  label('CPF ou CNPJ'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _docCtrl,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurface),
                    keyboardType: TextInputType.number,
                    inputFormatters: [CpfCnpjInputFormatter()],
                    decoration: inputDecoration(prefix: LucideIcons.idCard),
                    validator: docCpfCnpjValidator,
                  ),
                  const SizedBox(height: 12),
                  label('Telefone'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _telCtrl,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurface),
                    keyboardType: TextInputType.phone,
                    inputFormatters: [telMask],
                    decoration: inputDecoration(prefix: LucideIcons.phone),
                    validator: telefoneValidator,
                  ),
                  const SizedBox(height: 12),
                  label('Endereco'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _endCtrl,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurface),
                    decoration: inputDecoration(prefix: LucideIcons.mapPin),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: _salvar,
                    style: FilledButton.styleFrom(
                      backgroundColor: scheme.primary,
                      foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                    ),
                    icon: const Icon(LucideIcons.save, color: Color.fromARGB(255, 2, 2, 2)),
                    label: Text(editando ? 'Salvar altera\u00E7\u00F5es' : 'Cadastrar'),
                  ),
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

