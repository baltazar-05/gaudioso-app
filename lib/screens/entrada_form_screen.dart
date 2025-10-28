import 'package:flutter/material.dart';
import '../models/entrada.dart';
import '../models/material.dart';
import '../services/entrada_service.dart';
import '../services/material_service.dart';

class EntradaFormScreen extends StatefulWidget {
  final Entrada? entrada;
  const EntradaFormScreen({super.key, this.entrada});

  @override
  State<EntradaFormScreen> createState() => _EntradaFormScreenState();
}

class _EntradaFormScreenState extends State<EntradaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = EntradaService();
  final _materialService = MaterialService();

  List<MaterialItem> _materiais = [];
  MaterialItem? _materialSelecionado;

  late TextEditingController _fornecedorCtrl;
  late TextEditingController _pesoCtrl;
  late TextEditingController _dataCtrl;
  late TextEditingController _registradoPorCtrl;

  bool _carregandoMateriais = true;

  @override
  void initState() {
    super.initState();

    _fornecedorCtrl = TextEditingController(
      text: widget.entrada?.idFornecedor.toString() ?? "",
    );
    _pesoCtrl = TextEditingController(
      text: widget.entrada?.peso.toString() ?? "",
    );
    _dataCtrl = TextEditingController(text: widget.entrada?.data ?? "");
    _registradoPorCtrl = TextEditingController(
      text: widget.entrada?.registradoPor.toString() ?? "",
    );

    _carregarMateriais();
  }

  Future<void> _carregarMateriais() async {
    try {
      final lista = await _materialService.listar();
      setState(() {
        _materiais = lista;
        _carregandoMateriais = false;

        // Se estiver editando, seleciona o material atual
        if (widget.entrada != null) {
          _materialSelecionado = lista.firstWhere(
            (m) => m.id == widget.entrada!.idMaterial,
            orElse: () => lista.first,
          );
        }
      });
    } catch (e) {
      setState(() => _carregandoMateriais = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar materiais: $e')));
    }
  }

  @override
  void dispose() {
    _fornecedorCtrl.dispose();
    _pesoCtrl.dispose();
    _dataCtrl.dispose();
    _registradoPorCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_materialSelecionado == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Selecione um material")));
      return;
    }

    final e = Entrada(
      id: widget.entrada?.id,
      idMaterial: _materialSelecionado!.id ?? 0,
      idFornecedor: int.tryParse(_fornecedorCtrl.text) ?? 0,
      peso: double.tryParse(_pesoCtrl.text) ?? 0,
      data: _dataCtrl.text.trim(),
      registradoPor: int.tryParse(_registradoPorCtrl.text) ?? 0,
    );

    try {
      if (widget.entrada == null) {
        await _service.adicionar(e);
      } else {
        await _service.atualizar(e);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro ao salvar entrada: $err")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.entrada != null;

    return Scaffold(
      appBar: AppBar(title: Text(editando ? "Editar Entrada" : "Nova Entrada")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _carregandoMateriais
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    DropdownButtonFormField<MaterialItem>(
                      value: _materialSelecionado,
                      items: _materiais
                          .map(
                            (m) =>
                                DropdownMenuItem(value: m, child: Text(m.nome)),
                          )
                          .toList(),
                      onChanged: (valor) {
                        setState(() => _materialSelecionado = valor);
                      },
                      decoration: const InputDecoration(
                        labelText: "Selecione o material",
                      ),
                      validator: (v) =>
                          v == null ? "Selecione um material" : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _fornecedorCtrl,
                      decoration: const InputDecoration(
                        labelText: "ID do Fornecedor",
                      ),
                      validator: (v) => v == null || v.isEmpty
                          ? "Informe o idFornecedor"
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _pesoCtrl,
                      decoration: const InputDecoration(labelText: "Peso (kg)"),
                      validator: (v) =>
                          v == null || v.isEmpty ? "Informe o peso" : null,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _dataCtrl,
                      decoration: const InputDecoration(
                        labelText: "Data (AAAA-MM-DD)",
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? "Informe a data" : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _registradoPorCtrl,
                      decoration: const InputDecoration(
                        labelText: "Registrado por (ID usuário)",
                      ),
                      validator: (v) => v == null || v.isEmpty
                          ? "Informe o id do usuário"
                          : null,
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
