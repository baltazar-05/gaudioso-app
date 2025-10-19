import 'package:flutter/material.dart';
import '../models/material.dart';
import '../services/material_service.dart';
import 'material_form_screen.dart';

class MateriaisScreen extends StatefulWidget {
  const MateriaisScreen({super.key});

  @override
  State<MateriaisScreen> createState() => _MateriaisScreenState();
}

class _MateriaisScreenState extends State<MateriaisScreen> {
  final service = MaterialService();
  final _buscaCtrl = TextEditingController();
  List<MaterialItem> materiais = [];
  List<MaterialItem> filtrados = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future<void> carregar() async {
    final data = await service.listar();
    data.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    setState(() {
      materiais = data;
      filtrados = _filtrar(_buscaCtrl.text, data);
      carregando = false;
    });
  }

  Future<void> _abrirFormulario({MaterialItem? item}) async {
    final mudou = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MaterialFormScreen(item: item)),
    );
    if (mudou == true) carregar();
  }

  @override
  Widget build(BuildContext context) {
    final bg = Colors.green.shade300;
    final cardColor = Colors.green.shade50;
    final accent = Colors.black;
    final fabBg = Colors.green.shade800;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Materiais'),
        backgroundColor: bg,
        foregroundColor: Colors.black,
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: TextField(
                    controller: _buscaCtrl,
                    onChanged: (q) => setState(() {
                      filtrados = _filtrar(q, materiais);
                    }),
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Buscar por nome do material',
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
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 12),
                      itemCount: filtrados.length,
                      itemBuilder: (_, i) {
                        final m = filtrados[i];
                        return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                m.nome,
                                style: TextStyle(
                                  color: accent,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Compra: R\$ ${m.precoCompra.toStringAsFixed(2)} | Venda: R\$ ${m.precoVenda.toStringAsFixed(2)}',
                                style: TextStyle(color: accent.withValues(alpha: 0.9)),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: accent),
                              onPressed: () => _abrirFormulario(item: m),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: accent),
                              onPressed: () async {
                                await service.excluir(m.id!);
                                carregar();
                              },
                            ),
                          ],
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
        backgroundColor: fabBg,
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
    );
  }
}

extension _Filtro on _MateriaisScreenState {
  List<MaterialItem> _filtrar(String q, List<MaterialItem> base) {
    final termo = q.trim().toLowerCase();
    if (termo.isEmpty) {
      final copy = List<MaterialItem>.from(base);
      copy.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
      return copy;
    }
    final result = base.where((m) => m.nome.toLowerCase().contains(termo)).toList();
    result.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    return result;
  }
}





