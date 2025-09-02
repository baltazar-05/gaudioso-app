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
  List<Fornecedor> fornecedores = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future<void> carregar() async {
    final data = await service.listar();
    setState(() {
      fornecedores = data;
      carregando = false;
    });
  }

  Future<void> _abrirFormulario({Fornecedor? f}) async {
    final mudou = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FornecedorFormScreen(fornecedor: f)),
    );
    if (mudou == true) carregar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Fornecedores")),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: carregar,
              child: ListView.builder(
                itemCount: fornecedores.length,
                itemBuilder: (_, i) {
                  final f = fornecedores[i];
                  return ListTile(
                    title: Text(f.nome),
                    subtitle: Text("Doc: ${f.documento} | Tel: ${f.telefone}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _abrirFormulario(f: f),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await service.excluir(f.id!);
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
