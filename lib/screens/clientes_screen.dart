import 'package:flutter/material.dart';
import '../models/cliente.dart';
import '../services/cliente_service.dart';
import 'cliente_form_screen.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final service = ClienteService();
  final _buscaCtrl = TextEditingController();
  List<Cliente> clientes = [];
  List<Cliente> filtrados = [];
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
    try {
      final data = await service.listar();
      if (!mounted) return;
      data.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
      setState(() {
        clientes = data;
        filtrados = _filtrar(_buscaCtrl.text, data);
        carregando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        carregando = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erro ao carregar clientes: $e')));
    }
  }

  Future<void> _abrirFormulario({Cliente? c}) async {
    final mudou = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ClienteFormScreen(cliente: c)),
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
      appBar: AppBar(
        title: const Text('Clientes'),
        backgroundColor: bg,
        foregroundColor: Colors.black,
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: TextField(
                    controller: _buscaCtrl,
                    onChanged: (q) => setState(() {
                      filtrados = _filtrar(q, clientes);
                    }),
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Buscar por nome do cliente',
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
                                  child: Text('Nenhum cliente encontrado',
                                      style: TextStyle(color: Colors.black)),
                                ),
                              )
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            itemCount: filtrados.length,
                            itemBuilder: (_, i) {
                              final c = filtrados[i];
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
                                          Text(c.nome,
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w700)),
                                          const SizedBox(height: 4),
                                          Text('Doc: ${c.documento} | Tel: ${c.telefone}',
                                              style: const TextStyle(color: Colors.black87)),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.edit, color: accent),
                                      onPressed: () => _abrirFormulario(c: c),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: accent),
                                      onPressed: () async {
                                        try {
                                          await service.excluir(c.id!);
                                          if (!context.mounted) return;
                                          carregar();
                                        } catch (e) {
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(content: Text('Erro ao excluir: $e')));
                                        }
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

extension _ClienteFiltro on _ClientesScreenState {
  List<Cliente> _filtrar(String q, List<Cliente> base) {
    final termo = q.trim().toLowerCase();
    if (termo.isEmpty) {
      final copy = List<Cliente>.from(base);
      copy.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
      return copy;
    }
    final result = base.where((c) => c.nome.toLowerCase().contains(termo)).toList();
    result.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    return result;
  }
}
