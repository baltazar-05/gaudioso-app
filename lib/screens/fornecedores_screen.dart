import 'package:flutter/material.dart';
import '../models/fornecedor.dart';
import '../services/fornecedor_service.dart';
import 'fornecedor_form_screen.dart';

class FornecedoresScreen extends StatefulWidget {
  const FornecedoresScreen({super.key});

  @override
  State<FornecedoresScreen> createState() => _FornecedoresScreenState();
}

class _FornecedoresScreenState extends State<FornecedoresScreen> {
  final service = FornecedorService();
  final _buscaCtrl = TextEditingController();
  List<Fornecedor> fornecedores = [];
  List<Fornecedor> filtrados = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregar();
  }

  @override
  void dispose() {
    _buscaCtrl.dispose();
    super.dispose();
  }

  Future<void> carregar() async {
    final data = await service.listar();
    data.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    setState(() {
      fornecedores = data;
      filtrados = _filtrar(_buscaCtrl.text, data);
      carregando = false;
    });
  }

  Future<void> _abrirFormulario({Fornecedor? f}) async {
    final mudou = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FornecedorFormScreen(fornecedor: f)),
    );
    if (!mounted) return;
    if (mudou == true) carregar();
  }

  @override
  Widget build(BuildContext context) {
    final bg = Colors.green.shade300;
    final card = Colors.green.shade50;
    final accent = Colors.black;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(title: const Text('Fornecedores'), backgroundColor: bg, foregroundColor: Colors.black),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: TextField(
                    controller: _buscaCtrl,
                    onChanged: (q) => setState(() {
                      filtrados = _filtrar(q, fornecedores);
                    }),
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Buscar por nome do fornecedor',
                      hintStyle: const TextStyle(color: Colors.black54),
                      prefixIcon: const Icon(Icons.search, color: Colors.black),
                      filled: true,
                      fillColor: Colors.green.shade50,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.black54),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: carregar,
                    child: filtrados.isEmpty
                        ? ListView(
                            children: const [
                              Padding(
                                padding: EdgeInsets.only(top: 80),
                                child: Center(
                                  child: Text('Nenhum fornecedor encontrado',
                                      style: TextStyle(color: Colors.black)),
                                ),
                              )
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            itemCount: filtrados.length,
                            itemBuilder: (_, i) {
                              final f = filtrados[i];
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: card,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(f.nome,
                                              style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w700)),
                                          const SizedBox(height: 4),
                                          Text('Doc: ${f.documento} | Tel: ${f.telefone}',
                                              style: const TextStyle(color: Colors.black87)),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.edit, color: accent),
                                      onPressed: () => _abrirFormulario(f: f),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: accent),
                                      onPressed: () async {
                                        await service.excluir(f.id!);
                                        if (!context.mounted) return;
                                        carregar();
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        backgroundColor: Colors.green.shade800,
        child: const Icon(Icons.add),
      ),
    );
  }
}

extension _FornecedorFiltro on _FornecedoresScreenState {
  List<Fornecedor> _filtrar(String q, List<Fornecedor> base) {
    final termo = q.trim().toLowerCase();
    if (termo.isEmpty) {
      final copy = List<Fornecedor>.from(base);
      copy.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
      return copy;
    }
    final result = base.where((f) => f.nome.toLowerCase().contains(termo)).toList();
    result.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    return result;
  }
}
