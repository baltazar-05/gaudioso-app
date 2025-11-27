class MovimentacaoData {
  final DateTime dataInicio;
  final DateTime dataFim;
  final double pesoTotalEntradas;
  final double pesoTotalSaidas;
  final double valorTotalEntradas;
  final double valorTotalSaidas;
  final List<MovimentacaoMaterial> materiais;

  const MovimentacaoData({
    required this.dataInicio,
    required this.dataFim,
    required this.pesoTotalEntradas,
    required this.pesoTotalSaidas,
    required this.valorTotalEntradas,
    required this.valorTotalSaidas,
    required this.materiais,
  });

  factory MovimentacaoData.fromJson(Map<String, dynamic> json) {
    return MovimentacaoData(
      dataInicio: DateTime.parse(json['dataInicio'] as String),
      dataFim: DateTime.parse(json['dataFim'] as String),
      pesoTotalEntradas: _toDouble(json['pesoTotalEntradas']),
      pesoTotalSaidas: _toDouble(json['pesoTotalSaidas']),
      valorTotalEntradas: _toDouble(json['valorTotalEntradas']),
      valorTotalSaidas: _toDouble(json['valorTotalSaidas']),
      materiais: (json['materiais'] as List<dynamic>? ?? const [])
          .map((e) => MovimentacaoMaterial.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class MovimentacaoMaterial {
  final String nome;
  final double pesoEntradas;
  final double pesoSaidas;
  final double valorEntradas;
  final double valorSaidas;

  const MovimentacaoMaterial({
    required this.nome,
    required this.pesoEntradas,
    required this.pesoSaidas,
    required this.valorEntradas,
    required this.valorSaidas,
  });

  factory MovimentacaoMaterial.fromJson(Map<String, dynamic> json) {
    return MovimentacaoMaterial(
      nome: (json['nomeMaterial'] ?? '') as String,
      pesoEntradas: _toDouble(json['pesoEntradas']),
      pesoSaidas: _toDouble(json['pesoSaidas']),
      valorEntradas: _toDouble(json['valorEntradas']),
      valorSaidas: _toDouble(json['valorSaidas']),
    );
  }

  double get saldoPeso => pesoEntradas - pesoSaidas;
  double get saldoValor => valorEntradas - valorSaidas;
}

double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}
