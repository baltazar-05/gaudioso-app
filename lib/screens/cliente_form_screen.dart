import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../models/cliente.dart';
import '../services/cliente_service.dart';
import '../utils/cpf_cnpj_input_formatter.dart';
import '../utils/validators.dart';
import '../widgets/app_bottom_nav.dart';

class ClienteFormScreen extends StatefulWidget {
  final Cliente? cliente;
  const ClienteFormScreen({super.key, this.cliente});

  @override
  State<ClienteFormScreen> createState() => _ClienteFormScreenState();
}

class _ClienteFormScreenState extends State<ClienteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = ClienteService();
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
    _nomeCtrl = TextEditingController(text: widget.cliente?.nome ?? '');
    _docCtrl = TextEditingController(text: widget.cliente?.documento ?? '');
    _telCtrl = TextEditingController(text: widget.cliente?.telefone ?? '');
    _endCtrl = TextEditingController(text: widget.cliente?.endereco ?? '');
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

    final c = Cliente(
      id: widget.cliente?.id,
      nome: _nomeCtrl.text.trim(),
      documento: _docCtrl.text.trim(),
      telefone: _telCtrl.text.trim(),
      endereco: _endCtrl.text.trim(),
    );

    bool salvando = false;
    final confirmou = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDlg) {
            final editando = widget.cliente != null;
            return AlertDialog(
              title: Text(editando ? 'Confirmar alteração' : 'Confirmar cadastro'),
              content: Text(
                'Deseja ${editando ? 'salvar as alterações' : 'cadastrar o novo cliente'}?',
              ),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: Colors.black),
                  onPressed: salvando ? null : () => Navigator.pop(ctx, false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(foregroundColor: Colors.black),
                  onPressed: salvando
                      ? null
                      : () async {
                          setDlg(() => salvando = true);
                          try {
                            if (widget.cliente == null) {
                              await _service.adicionar(c);
                            } else {
                              await _service.atualizar(c);
                            }
                            if (!ctx.mounted) return;
                            Navigator.pop(ctx, true);
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Erro ao salvar: $e')),
                              );
                            }
                            setDlg(() => salvando = false);
                          }
                        },
                  child: salvando
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmou == true && mounted) Navigator.pop(context, true);
  }

  
  @override
  Widget build(BuildContext context) {
    final editando = widget.cliente != null;
    final colors = Theme.of(context).colorScheme;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final titleTextStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          color: colors.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w500,
        );
    final TextStyle buttonTextStyle =
        (Theme.of(context).textTheme.bodyMedium ?? const TextStyle())
            .copyWith(color: colors.onPrimary, fontSize: 16);

    InputDecoration inputDecoration({
      IconData? prefix,
    }) =>
        InputDecoration(
          filled: true,
          fillColor: colors.surface,
          prefixIcon: prefix != null ? Icon(prefix, color: colors.onSurface) : null,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colors.onSurface.withValues(alpha: 0.54)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colors.primary, width: 1.2),
          ),
        );

    Widget label(String text) => Text(
          text,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: colors.onSurface, fontWeight: FontWeight.w400),
        );

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        centerTitle: true,
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
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, anim) =>
              FadeTransition(opacity: anim, child: child),
          child: editando
              ? Row(
                  key: const ValueKey('editar'),
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.pencil, size: 20, color: colors.onSurface),
                    const SizedBox(width: 8),
                    Text('Editar Cliente', style: titleTextStyle),
                  ],
                )
              : Row(
                  key: const ValueKey('novo'),
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.plus, size: 20, color: colors.onSurface),
                    const SizedBox(width: 8),
                    Text('Novo Cliente', style: titleTextStyle),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.all(16),
                child: ListView(
                  children: [
                    Hero(
                      tag: 'cliente_${widget.cliente?.id ?? 'novo'}',
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.grey.shade200,
                        child: Icon(LucideIcons.user, color: Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 20),
                    label('Nome'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _nomeCtrl,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: colors.onSurface, fontWeight: FontWeight.w400),
                      decoration: inputDecoration(prefix: LucideIcons.user),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Digite o nome' : null,
                    ),
                    const SizedBox(height: 12),
                    label('CPF ou CNPJ'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _docCtrl,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: colors.onSurface, fontWeight: FontWeight.w400),
                      decoration: inputDecoration(prefix: LucideIcons.idCard),
                      keyboardType: TextInputType.number,
                      inputFormatters: [CpfCnpjInputFormatter()],
                      validator: docCpfCnpjValidator,
                    ),
                    const SizedBox(height: 12),
                    label('Telefone'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _telCtrl,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: colors.onSurface, fontWeight: FontWeight.w400),
                      decoration: inputDecoration(prefix: LucideIcons.phone),
                      keyboardType: TextInputType.phone,
                      inputFormatters: [telMask],
                      validator: telefoneValidator,
                    ),
                    const SizedBox(height: 12),
                    label('Endereco'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _endCtrl,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: colors.onSurface, fontWeight: FontWeight.w400),
                      decoration: inputDecoration(prefix: LucideIcons.mapPin),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: _salvar,
                      icon: Icon(LucideIcons.save, color: colors.onSurface),
                      label: Text(
                        editando ? 'Salvar altera??es' : 'Cadastrar',
                        style: buttonTextStyle.copyWith(color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(),
    );
  }
}
