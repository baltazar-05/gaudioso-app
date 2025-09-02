class Relatorio {
  final String nomeMaterial;
  final double totalEntradas;
  final double totalSaidas;
  final double saldo;

  Relatorio({
    required this.nomeMaterial,
    required this.totalEntradas,
    required this.totalSaidas,
    required this.saldo,
  });

  factory Relatorio.fromJson(Map<String, dynamic> json) {
    return Relatorio(
      nomeMaterial: json['nomeMaterial'],
      totalEntradas: double.tryParse(json['totalEntradas'].toString()) ?? 0,
      totalSaidas: double.tryParse(json['totalSaidas'].toString()) ?? 0,
      saldo: double.tryParse(json['saldo'].toString()) ?? 0,
    );
  }
}
