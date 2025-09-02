import 'package:flutter/material.dart';
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
  late TextEditingController _unidadeCtrl;
  late TextEditingController _precoRefCtrl;

  @override
  void initState() {
    super.initState();
    _nomeCtrl = TextEditingController(text: widget.item?.nome ?? "");
    _unidadeCtrl = TextEditingController(text: widget.item?.unidade ?? "");
    _precoRefCtrl = TextEditingController(
        text: widget.item?.precoRef.toString() ?? "");
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _unidadeCtrl.dispose();
    _precoRefCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final item = MaterialItem(
      id: widget.item?.id,
      nome: _nomeCtrl.text.trim(),
      unidade: _unidadeCtrl.text.trim(),
      precoRef: double.tryParse(_precoRefCtrl.text) ?? 0,
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
    return Scaffold(
      appBar: AppBar(title: Text(editando ? "Editar Material" : "Novo Material")),
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
                controller: _unidadeCtrl,
                decoration: const InputDecoration(labelText: "Unidade (ex: kg, un)"),
                validator: (v) => v == null || v.isEmpty ? "Digite a unidade" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _precoRefCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: "Preço de Referência"),
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
