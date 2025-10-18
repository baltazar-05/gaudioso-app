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
  late TextEditingController _precoCompraCtrl;
  late TextEditingController _precoVendaCtrl;

  @override
  void initState() {
    super.initState();
    _nomeCtrl = TextEditingController(text: widget.item?.nome ?? "");
    _precoCompraCtrl =
        TextEditingController(text: widget.item?.precoCompra.toString() ?? "");
    _precoVendaCtrl =
        TextEditingController(text: widget.item?.precoVenda.toString() ?? "");
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
    final bg = Colors.green.shade300;

    InputDecoration inputDecoration() => InputDecoration(
          filled: true,
          fillColor: Colors.green.shade50,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.black54),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.black, width: 1.2),
          ),
        );

    Widget label(String text) => Text(text,
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500));

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        foregroundColor: Colors.black,
        title: Text(editando ? 'Editar Material' : 'Novo Material'),
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
              label('Preço de Compra'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _precoCompraCtrl,
                style: const TextStyle(color: Colors.black),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: inputDecoration(),
              ),
              const SizedBox(height: 12),
              label('Preço de Venda'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _precoVendaCtrl,
                style: const TextStyle(color: Colors.black),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
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
              )
            ],
          ),
        ),
      ),
    );
  }
}

