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
  List<MaterialItem> materiais = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future<void> carregar() async {
    final data = await service.listar();
    setState(() {
      materiais = data;
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
    return Scaffold(
      appBar: AppBar(title: const Text("Materiais")),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: carregar,
              child: ListView.builder(
                itemCount: materiais.length,
                itemBuilder: (_, i) {
                  final m = materiais[i];
                  return ListTile(
                    title: Text(m.nome),
                    subtitle: Text(
                        "Unidade: ${m.unidade} | Preço Ref: ${m.precoRef}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _abrirFormulario(item: m),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await service.excluir(m.id!);
                            carregar();
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
