class LoteEntradaResumo {
  final String numeroLote;
  final int qtd;
  final double pesoTotal;
  final double? valorTotal;
  final DateTime? ultimoRegistro;

  LoteEntradaResumo({
    required this.numeroLote,
    required this.qtd,
    required this.pesoTotal,
    this.valorTotal,
    this.ultimoRegistro,
  });

  factory LoteEntradaResumo.fromJson(Map<String, dynamic> json) {
    final numero = (json['numeroLote'] ?? json['numero_lote'] ?? json['numero'])?.toString() ?? '';
    final qtd = (json['qtd'] ?? json['quantidade'] ?? 0) as num;
    final peso = (json['pesoTotal'] ?? json['peso_total'] ?? json['peso'] ?? 0) as num;
    final valor = json['valorTotal'] ?? json['valor_total'];
    final ultimo = (json['ultimoRegistro'] ?? json['ultimo_registro'] ?? json['data']);
    DateTime? ultimoDt;
    if (ultimo is String && ultimo.isNotEmpty) {
      try {
        ultimoDt = DateTime.parse(ultimo);
      } catch (_) {
        ultimoDt = null;
      }
    }
    return LoteEntradaResumo(
      numeroLote: numero,
      qtd: qtd.toInt(),
      pesoTotal: peso.toDouble(),
      valorTotal: (valor is num) ? valor.toDouble() : null,
      ultimoRegistro: ultimoDt,
    );
  }

  Map<String, dynamic> toJson() => {
        'numeroLote': numeroLote,
        'qtd': qtd,
        'pesoTotal': pesoTotal,
        if (valorTotal != null) 'valorTotal': valorTotal,
        if (ultimoRegistro != null) 'ultimoRegistro': ultimoRegistro!.toIso8601String(),
      };
}

