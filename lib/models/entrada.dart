class Entrada {
  final int? id;
  final int idMaterial;
  final int idFornecedor;
  final String? numeroLote; // opcional

  // Pesagens e preço
  final List<double> pesosJson; // enviado ao backend
  final double precoUnitario;

  // Campos calculados pelo banco e retornados pela API
  final int? qtdPesagens;
  final double peso; // soma vinda do banco (não calcular no app)
  final double? valorTotal; // calculado no banco (peso * precoUnitario)

  // Mantemos 'data' como string para compatibilidade com telas existentes.
  // Mapeia para o campo 'criadoEm' retornado pela API (ISO 8601).
  final String data;
  final int registradoPor;

  Entrada({
    this.id,
    required this.idMaterial,
    required this.idFornecedor,
    this.numeroLote,
    required this.pesosJson,
    required this.precoUnitario,
    this.qtdPesagens,
    required this.peso,
    this.valorTotal,
    required this.data,
    required this.registradoPor,
  });

  factory Entrada.fromJson(Map<String, dynamic> json) {
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

    return Entrada(
      id: parseInt(
        json['id'] ??
            json['idEntrada'] ??
            json['entradaId'] ??
            json['entrada_id'],
      ),
      idMaterial: parseInt(json['idMaterial'] ?? json['id_material']) ?? 0,
      idFornecedor:
          parseInt(json['idFornecedor'] ?? json['id_fornecedor']) ?? 0,
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

  // toJson não envia 'data'/'criadoEm' (servidor preenche)
  Map<String, dynamic> toJson() => {
    "id": id,
    "idMaterial": idMaterial,
    "idFornecedor": idFornecedor,
    if (numeroLote != null && numeroLote!.isNotEmpty) "numeroLote": numeroLote,
    "pesosJson": pesosJson,
    "precoUnitario": precoUnitario,
    "registradoPor": registradoPor,
    // regra de compat: se pesosJson vazio, alguns fluxos antigos esperam 'peso'
    if (pesosJson.isEmpty) "peso": peso,
  };
}
