import 'package:flutter/material.dart';
import '../models/entrada.dart';
import '../services/entrada_service.dart';
import 'entrada_form_screen.dart';

class EntradasScreen extends StatefulWidget {
  const EntradasScreen({super.key});

  @override
  State<EntradasScreen> createState() => _EntradasScreenState();
}

class _EntradasScreenState extends State<EntradasScreen> {
  final service = EntradaService();
  List<Entrada> entradas = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future<void> carregar() async {
    try {
      final data = await service.listar();
      if (!mounted) return;
      setState(() {
        entradas = data;
        carregando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => carregando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao carregar entradas: $e")),
      );
    }
  }

  Future<void> _abrirFormulario({Entrada? e}) async {
    final mudou = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EntradaFormScreen(entrada: e)),
    );
    if (!mounted) return;
    if (mudou == true) carregar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Entradas de Materiais")),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : entradas.isEmpty
              ? const Center(child: Text("Nenhuma entrada registrada"))
              : RefreshIndicator(
                  onRefresh: carregar,
                  child: ListView.builder(
                    itemCount: entradas.length,
                    itemBuilder: (_, i) {
                      final e = entradas[i];
                      return ListTile(
                        title: Text("Material ID: ${e.idMaterial} - Fornecedor ID: ${e.idFornecedor}"),
                        subtitle: Text("Peso: ${e.peso} kg | Data: ${e.data}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _abrirFormulario(e: e),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                try {
                                  await service.excluir(e.id!);
                                  if (!mounted) return;
                                  carregar();
                                } catch (err) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Erro ao excluir: $err")),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
