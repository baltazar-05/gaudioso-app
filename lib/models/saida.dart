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
    final pesos = (json['pesosJson'] as List?)?.map((e) => (e as num).toDouble()).toList() ?? const [];
    int? _int(dynamic v) => v == null ? null : (v as num).toInt();
    double _double(dynamic v) => (v is num) ? v.toDouble() : (double.tryParse(v?.toString() ?? '') ?? 0);

    return Saida(
      id: _int(json['id'] ?? json['idSaida'] ?? json['saidaId'] ?? json['saida_id']),
      idMaterial: _int(json['idMaterial'] ?? json['id_material']) ?? 0,
      idCliente: _int(json['idCliente'] ?? json['id_cliente']) ?? 0,
      numeroLote: (json['numeroLote'] ?? json['numero_lote'] ?? json['lote'])?.toString(),
      pesosJson: pesos,
      precoUnitario: _double(json['precoUnitario'] ?? json['preco_unitario'] ?? json['preco'] ?? json['precoRef']),
      qtdPesagens: _int(json['qtdPesagens'] ?? json['qtd_pesagens'] ?? json['qtd']),
      peso: _double(json['pesoTotal'] ?? json['peso_total'] ?? json['peso']),
      valorTotal: (json['valorTotal'] ?? json['valor_total']) == null ? null : _double(json['valorTotal'] ?? json['valor_total']),
      data: json['criadoEm'] ?? json['data'] ?? json['dataCadastro'] ?? '',
      registradoPor: _int(json['registradoPor'] ?? json['usuarioId'] ?? json['usuario_id']) ?? 0,
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
