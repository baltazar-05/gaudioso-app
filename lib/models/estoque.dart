class Estoque {
  final int idMaterial;
  final String nomeMaterial;
  final double saldo;

  Estoque({
    required this.idMaterial,
    required this.nomeMaterial,
    required this.saldo,
  });

  factory Estoque.fromJson(Map<String, dynamic> json) {
    return Estoque(
      idMaterial: json['idMaterial'],
      nomeMaterial: json['nomeMaterial'],
      saldo: double.tryParse(json['saldo'].toString()) ?? 0,
    );
  }
}
