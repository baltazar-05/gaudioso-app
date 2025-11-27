class LucroRealData {
  final DateTime dataInicio;
  final DateTime dataFim;
  final double totalCompra;
  final double totalVenda;
  final double lucroBruto;
  final double despesas;
  final double lucroLiquido;
  final double margemLucro;
  final double totalPesoComprado;
  final double totalPesoVendido;
  final double diferencaPeso;
  final List<LucroRealMaterial> materiais;

  const LucroRealData({
    required this.dataInicio,
    required this.dataFim,
    required this.totalCompra,
    required this.totalVenda,
    required this.lucroBruto,
    required this.despesas,
    required this.lucroLiquido,
    required this.margemLucro,
    required this.totalPesoComprado,
    required this.totalPesoVendido,
    required this.diferencaPeso,
    required this.materiais,
  });

  factory LucroRealData.fromJson(Map<String, dynamic> json) {
    return LucroRealData(
      dataInicio: DateTime.parse(json['dataInicio'] as String),
      dataFim: DateTime.parse(json['dataFim'] as String),
      totalCompra: _toDouble(json['totalCompra']),
      totalVenda: _toDouble(json['totalVenda']),
      lucroBruto: _toDouble(json['lucroBruto']),
      despesas: _toDouble(json['despesas']),
      lucroLiquido: _toDouble(json['lucroLiquido']),
      margemLucro: _toDouble(json['margemLucro']),
      totalPesoComprado: _toDouble(json['totalPesoComprado']),
      totalPesoVendido: _toDouble(json['totalPesoVendido']),
      diferencaPeso: _toDouble(json['diferencaPeso']),
      materiais: (json['porMaterial'] as List<dynamic>? ?? const [])
          .map((e) => LucroRealMaterial.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class LucroRealMaterial {
  final String nome;
  final double pesoComprado;
  final double pesoVendido;
  final double precoCompra;
  final double precoVenda;
  final double lucro;

  const LucroRealMaterial({
    required this.nome,
    required this.pesoComprado,
    required this.pesoVendido,
    required this.precoCompra,
    required this.precoVenda,
    required this.lucro,
  });

  factory LucroRealMaterial.fromJson(Map<String, dynamic> json) {
    return LucroRealMaterial(
      nome: (json['nomeMaterial'] ?? '') as String,
      pesoComprado: _toDouble(json['pesoComprado']),
      pesoVendido: _toDouble(json['pesoVendido']),
      precoCompra: _toDouble(json['precoMedioCompra']),
      precoVenda: _toDouble(json['precoMedioVenda']),
      lucro: _toDouble(json['lucro']),
    );
  }
}

double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}
