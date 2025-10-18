import 'package:flutter/material.dart';
import '../models/cliente.dart';
import '../services/cliente_service.dart';
import '../utils/validators.dart';
import '../utils/cpf_cnpj_input_formatter.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

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
    _nomeCtrl = TextEditingController(text: widget.cliente?.nome ?? "");
    _docCtrl = TextEditingController(text: widget.cliente?.documento ?? "");
    _telCtrl = TextEditingController(text: widget.cliente?.telefone ?? "");
    _endCtrl = TextEditingController(text: widget.cliente?.endereco ?? "");
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

    try {
      if (widget.cliente == null) {
        await _service.adicionar(c);
      } else {
        await _service.atualizar(c);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erro ao salvar cliente: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.cliente != null;
    final bg = Colors.green.shade300;

    InputDecoration inputDecoration() => InputDecoration(
          filled: true,
          fillColor: Colors.green.shade50,
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black54),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 1.2),
          ),
        );

    Widget label(String text) => Text(text,
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500));

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        foregroundColor: Colors.black,
        title: Text(editando ? 'Editar Cliente' : 'Novo Cliente'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              label('Nome'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nomeCtrl,
                style: const TextStyle(color: Colors.black),
                decoration: inputDecoration(),
                validator: (v) => v == null || v.isEmpty ? 'Digite o nome' : null,
              ),
              const SizedBox(height: 12),
              label('CPF ou CNPJ'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _docCtrl,
                style: const TextStyle(color: Colors.black),
                decoration: inputDecoration(),
                keyboardType: TextInputType.number,
                inputFormatters: [CpfCnpjInputFormatter()],
                validator: docCpfCnpjValidator,
              ),
              const SizedBox(height: 12),
              label('Telefone'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _telCtrl,
                style: const TextStyle(color: Colors.black),
                decoration: inputDecoration(),
                keyboardType: TextInputType.phone,
                inputFormatters: [telMask],
                validator: telefoneValidator,
              ),
              const SizedBox(height: 12),
              label('Endereço'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _endCtrl,
                style: const TextStyle(color: Colors.black),
                decoration: inputDecoration(),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _salvar,
                icon: const Icon(Icons.save),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade50,
                  foregroundColor: Colors.black,
                ),
                label: Text(editando ? 'Salvar alterações' : 'Cadastrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
