import 'package:flutter/material.dart';
import '../models/saida.dart';
import '../services/saida_service.dart';

class SaidaFormScreen extends StatefulWidget {
  final Saida? saida;
  const SaidaFormScreen({super.key, this.saida});

  @override
  State<SaidaFormScreen> createState() => _SaidaFormScreenState();
}

class _SaidaFormScreenState extends State<SaidaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = SaidaService();

  late TextEditingController _materialCtrl;
  late TextEditingController _clienteCtrl;
  late TextEditingController _pesoCtrl;
  late TextEditingController _dataCtrl;
  late TextEditingController _registradoPorCtrl;

  @override
  void initState() {
    super.initState();
    _materialCtrl = TextEditingController(text: widget.saida?.idMaterial.toString() ?? "");
    _clienteCtrl  = TextEditingController(text: widget.saida?.idCliente.toString() ?? "");
    _pesoCtrl     = TextEditingController(text: widget.saida?.peso.toString() ?? "");
    _dataCtrl     = TextEditingController(text: widget.saida?.data ?? "");
    _registradoPorCtrl = TextEditingController(text: widget.saida?.registradoPor.toString() ?? "");
  }

  @override
  void dispose() {
    _materialCtrl.dispose();
    _clienteCtrl.dispose();
    _pesoCtrl.dispose();
    _dataCtrl.dispose();
    _registradoPorCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final s = Saida(
      id: widget.saida?.id,
      idMaterial: int.tryParse(_materialCtrl.text) ?? 0,
      idCliente: int.tryParse(_clienteCtrl.text) ?? 0,
      peso: double.tryParse(_pesoCtrl.text) ?? 0,
      data: _dataCtrl.text.trim(), // formato: AAAA-MM-DD
      registradoPor: int.tryParse(_registradoPorCtrl.text) ?? 0,
    );

    try {
      if (widget.saida == null) {
        await _service.adicionar(s);
      } else {
        await _service.atualizar(s);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao salvar saída: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.saida != null;

    return Scaffold(
      appBar: AppBar(title: Text(editando ? "Editar Saída" : "Nova Saída")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _materialCtrl,
                decoration: const InputDecoration(labelText: "ID do Material"),
                validator: (v) => v == null || v.isEmpty ? "Informe o idMaterial" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _clienteCtrl,
                decoration: const InputDecoration(labelText: "ID do Cliente"),
                validator: (v) => v == null || v.isEmpty ? "Informe o idCliente" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pesoCtrl,
                decoration: const InputDecoration(labelText: "Peso (kg)"),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => v == null || v.isEmpty ? "Informe o peso" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dataCtrl,
                decoration: const InputDecoration(labelText: "Data (AAAA-MM-DD)"),
                validator: (v) => v == null || v.isEmpty ? "Informe a data" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _registradoPorCtrl,
                decoration: const InputDecoration(labelText: "Registrado por (ID usuário)"),
                validator: (v) => v == null || v.isEmpty ? "Informe o id do usuário" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _salvar,
                icon: const Icon(Icons.save),
                label: Text(editando ? "Salvar alterações" : "Cadastrar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
