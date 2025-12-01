class Saida {
  final int? id;
  final int idMaterial;
  final int idCliente;
  final String? numeroLote; // opcional

  // Pesagens/Preço enviados
  final List<double> pesosJson;
  final double precoUnitario;

  // Derivados do banco
  final int? qtdPesagens;
  final double peso; // soma calculada no banco
  final double? valorTotal; // calculado no banco

  // Compatibilidade: manter 'data' como string, vindo de 'criadoEm'
  final String data;
  final int registradoPor;

  Saida({
    this.id,
    required this.idMaterial,
    required this.idCliente,
    this.numeroLote,
    required this.pesosJson,
    required this.precoUnitario,
    this.qtdPesagens,
    required this.peso,
    this.valorTotal,
    required this.data,
    required this.registradoPor,
  });

  factory Saida.fromJson(Map<String, dynamic> json) {
    final pesos =
        (json['pesosJson'] as List?)?.map((e) {
          if (e is num) return e.toDouble();
          if (e is String) return double.tryParse(e.replaceAll(',', '.')) ?? 0;
          return 0.0;
        }).toList() ??
        const [];

    int? parseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v);
      return null;
    }

    double parseDouble(dynamic v) {
      if (v == null) return 0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v.replaceAll(',', '.')) ?? 0;
      return 0;
    }

    return Saida(
      id: parseInt(
        json['id'] ?? json['idSaida'] ?? json['saidaId'] ?? json['saida_id'],
      ),
      idMaterial: parseInt(json['idMaterial'] ?? json['id_material']) ?? 0,
      idCliente: parseInt(json['idCliente'] ?? json['id_cliente']) ?? 0,
      numeroLote: (json['numeroLote'] ?? json['numero_lote'] ?? json['lote'])
          ?.toString(),
      pesosJson: pesos,
      precoUnitario: parseDouble(
        json['precoUnitario'] ??
            json['preco_unitario'] ??
            json['preco'] ??
            json['precoRef'],
      ),
      qtdPesagens: parseInt(
        json['qtdPesagens'] ?? json['qtd_pesagens'] ?? json['qtd'],
      ),
      peso: parseDouble(
        json['pesoTotal'] ?? json['peso_total'] ?? json['peso'],
      ),
      valorTotal: (json['valorTotal'] ?? json['valor_total']) == null
          ? null
          : parseDouble(json['valorTotal'] ?? json['valor_total']),
      data: json['criadoEm'] ?? json['data'] ?? json['dataCadastro'] ?? '',
      registradoPor:
          parseInt(
            json['registradoPor'] ?? json['usuarioId'] ?? json['usuario_id'],
          ) ??
          0,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "idMaterial": idMaterial,
    "idCliente": idCliente,
    if (numeroLote != null && numeroLote!.isNotEmpty) "numeroLote": numeroLote,
    "pesosJson": pesosJson,
    "precoUnitario": precoUnitario,
    "registradoPor": registradoPor,
    if (pesosJson.isEmpty) "peso": peso,
  };
}
