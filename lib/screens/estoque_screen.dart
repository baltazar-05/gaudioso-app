import 'package:flutter/material.dart';
import '../models/estoque.dart';
import '../services/estoque_service.dart';

class EstoqueScreen extends StatefulWidget {
  const EstoqueScreen({super.key});

  @override
  State<EstoqueScreen> createState() => _EstoqueScreenState();
}

class _EstoqueScreenState extends State<EstoqueScreen> {
  final service = EstoqueService();
  List<Estoque> itens = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future<void> carregar() async {
    try {
      final data = await service.listar();
      setState(() {
        itens = data;
        carregando = false;
      });
    } catch (e) {
      setState(() => carregando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao carregar estoque: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Estoque Atual"),
        backgroundColor: Colors.green.shade800,
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : itens.isEmpty
              ? const Center(child: Text("Nenhum material no estoque"))
              : RefreshIndicator(
                  onRefresh: carregar,
                  child: ListView.builder(
                    itemCount: itens.length,
                    itemBuilder: (_, i) {
                      final e = itens[i];
                      return Card(
                        margin:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: const Icon(Icons.inventory, color: Colors.green),
                          title: Text(e.nomeMaterial,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("ID: ${e.idMaterial}"),
                          trailing: Text(
                            "${e.saldo.toStringAsFixed(2)} kg",
                            style: TextStyle(
                                color: e.saldo > 0 ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
