import 'package:flutter/material.dart';
import '../models/saida.dart';
import '../services/saida_service.dart';
import 'saida_form_screen.dart';

class SaidasScreen extends StatefulWidget {
  const SaidasScreen({super.key});

  @override
  State<SaidasScreen> createState() => _SaidasScreenState();
}

class _SaidasScreenState extends State<SaidasScreen> {
  final service = SaidaService();
  List<Saida> saidas = [];
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
        saidas = data;
        carregando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => carregando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao carregar saídas: $e")),
      );
    }
  }

  Future<void> _abrirFormulario({Saida? s}) async {
    final mudou = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SaidaFormScreen(saida: s)),
    );
    if (!mounted) return;
    if (mudou == true) carregar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Saídas de Materiais")),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : saidas.isEmpty
              ? const Center(child: Text("Nenhuma saída registrada"))
              : RefreshIndicator(
                  onRefresh: carregar,
                  child: ListView.builder(
                    itemCount: saidas.length,
                    itemBuilder: (_, i) {
                      final s = saidas[i];
                      return ListTile(
                        title: Text("Material ID: ${s.idMaterial} - Cliente ID: ${s.idCliente}"),
                        subtitle: Text("Peso: ${s.peso} kg | Data: ${s.data}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _abrirFormulario(s: s),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                try {
                                  await service.excluir(s.id!);
                                  if (!mounted) return;
                                  carregar();
                                } catch (e) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Erro ao excluir: $e")),
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
