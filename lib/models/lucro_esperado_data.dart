class LucroEsperadoData {
  final DateTime dataGeracao;
  final String usuarioSolicitante;
  final double valorCustoTotal;
  final double valorVendaTotal;
  final double lucroEsperadoTotal;
  final double margemEsperadaTotal;
  final int quantidadeMateriais;
  final String materialMaisRentavel;
  final String materialMenosRentavel;
  final String materialMaiorLucro;
  final String materialMaiorPrejuizo;
  final List<LucroEsperadoMaterial> materiais;

  const LucroEsperadoData({
    required this.dataGeracao,
    required this.usuarioSolicitante,
    required this.valorCustoTotal,
    required this.valorVendaTotal,
    required this.lucroEsperadoTotal,
    required this.margemEsperadaTotal,
    required this.quantidadeMateriais,
    required this.materialMaisRentavel,
    required this.materialMenosRentavel,
    required this.materialMaiorLucro,
    required this.materialMaiorPrejuizo,
    required this.materiais,
  });

  factory LucroEsperadoData.fromJson(Map<String, dynamic> json) {
    return LucroEsperadoData(
      dataGeracao: DateTime.parse(json['dataGeracao'] as String),
      usuarioSolicitante: (json['usuarioSolicitante'] ?? 'Sistema') as String,
      valorCustoTotal: _toDouble(json['valorCustoTotal']),
      valorVendaTotal: _toDouble(json['valorVendaTotal']),
      lucroEsperadoTotal: _toDouble(json['lucroEsperadoTotal']),
      margemEsperadaTotal: _toDouble(json['margemEsperadaTotal']),
      quantidadeMateriais: (json['quantidadeMateriais'] ?? 0) as int,
      materialMaisRentavel: (json['materialMaisRentavel'] ?? 'N/A') as String,
      materialMenosRentavel: (json['materialMenosRentavel'] ?? 'N/A') as String,
      materialMaiorLucro: (json['materialMaiorLucro'] ?? 'N/A') as String,
      materialMaiorPrejuizo: (json['materialMaiorPrejuizo'] ?? 'N/A') as String,
      materiais: (json['materiais'] as List<dynamic>? ?? const [])
          .map((e) => LucroEsperadoMaterial.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class LucroEsperadoMaterial {
  final String nome;
  final double pesoEstoque;
  final double precoCompra;
  final double precoVenda;
  final double valorCusto;
  final double valorVenda;
  final double lucroEsperado;
  final double margemEsperada;

  const LucroEsperadoMaterial({
    required this.nome,
    required this.pesoEstoque,
    required this.precoCompra,
    required this.precoVenda,
    required this.valorCusto,
    required this.valorVenda,
    required this.lucroEsperado,
    required this.margemEsperada,
  });

  factory LucroEsperadoMaterial.fromJson(Map<String, dynamic> json) {
    return LucroEsperadoMaterial(
      nome: (json['nomeMaterial'] ?? '') as String,
      pesoEstoque: _toDouble(json['pesoEstoque']),
      precoCompra: _toDouble(json['precoCompra']),
      precoVenda: _toDouble(json['precoVenda']),
      valorCusto: _toDouble(json['valorCusto']),
      valorVenda: _toDouble(json['valorVenda']),
      lucroEsperado: _toDouble(json['lucroEsperado']),
      margemEsperada: _toDouble(json['margemEsperada']),
    );
  }
}

double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}
