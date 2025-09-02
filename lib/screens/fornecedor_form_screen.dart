import 'package:flutter/material.dart';
import '../models/fornecedor.dart';
import '../services/fornecedor_service.dart';

class FornecedorFormScreen extends StatefulWidget {
  final Fornecedor? fornecedor;
  const FornecedorFormScreen({super.key, this.fornecedor});

  @override
  State<FornecedorFormScreen> createState() => _FornecedorFormScreenState();
}

class _FornecedorFormScreenState extends State<FornecedorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = FornecedorService();

  late TextEditingController _nomeCtrl;
  late TextEditingController _docCtrl;
  late TextEditingController _telCtrl;
  late TextEditingController _endCtrl;

  @override
  void initState() {
    super.initState();
    _nomeCtrl = TextEditingController(text: widget.fornecedor?.nome ?? "");
    _docCtrl = TextEditingController(text: widget.fornecedor?.documento ?? "");
    _telCtrl = TextEditingController(text: widget.fornecedor?.telefone ?? "");
    _endCtrl = TextEditingController(text: widget.fornecedor?.endereco ?? "");
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

    final f = Fornecedor(
      id: widget.fornecedor?.id,
      nome: _nomeCtrl.text.trim(),
      documento: _docCtrl.text.trim(),
      telefone: _telCtrl.text.trim(),
      endereco: _endCtrl.text.trim(),
    );

    if (widget.fornecedor == null) {
      await _service.adicionar(f);
    } else {
      await _service.atualizar(f);
    }

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.fornecedor != null;
    return Scaffold(
      appBar: AppBar(title: Text(editando ? "Editar Fornecedor" : "Novo Fornecedor")),
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
