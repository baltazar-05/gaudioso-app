class Entrada {
  final int? id;
  final int idMaterial;
  final int idFornecedor;
  final double peso;
  final String data;
  final int registradoPor;

  Entrada({
    this.id,
    required this.idMaterial,
    required this.idFornecedor,
    required this.peso,
    required this.data,
    required this.registradoPor,
  });

  factory Entrada.fromJson(Map<String, dynamic> json) {
    return Entrada(
      id: json['id'],
      idMaterial: json['idMaterial'],
      idFornecedor: json['idFornecedor'],
      peso: double.tryParse(json['peso'].toString()) ?? 0,
      data: json['data'],
      registradoPor: json['registradoPor'],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "idMaterial": idMaterial,
        "idFornecedor": idFornecedor,
        "peso": peso,
        "data": data,
        "registradoPor": registradoPor,
      };
}
