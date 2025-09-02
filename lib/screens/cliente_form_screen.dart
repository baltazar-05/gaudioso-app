import 'package:flutter/material.dart';
import '../models/cliente.dart';
import '../services/cliente_service.dart';

class ClienteFormScreen extends StatefulWidget {
  final Cliente? cliente;
  const ClienteFormScreen({super.key, this.cliente});

  @override
  State<ClienteFormScreen> createState() => _ClienteFormScreenState();
}

class _ClienteFormScreenState extends State<ClienteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = ClienteService();

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao salvar cliente: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.cliente != null;
    return Scaffold(
      appBar: AppBar(title: Text(editando ? "Editar Cliente" : "Novo Cliente")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomeCtrl,
                decoration: const InputDecoration(labelText: "Nome"),
                validator: (v) => v == null || v.isEmpty ? "Digite o nome" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _docCtrl,
                decoration: const InputDecoration(labelText: "CPF ou CNPJ"),
                validator: (v) => v == null || v.isEmpty ? "Digite o documento" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _telCtrl,
                decoration: const InputDecoration(labelText: "Telefone"),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _endCtrl,
                decoration: const InputDecoration(labelText: "Endereço"),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _salvar,
                icon: const Icon(Icons.save),
                label: Text(editando ? "Salvar alterações" : "Cadastrar"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
