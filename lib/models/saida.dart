class Saida {
  final int? id;
  final int idMaterial;
  final int idCliente;
  final double peso;
  final String data;        // "AAAA-MM-DD"
  final int registradoPor;

  Saida({
    this.id,
    required this.idMaterial,
    required this.idCliente,
    required this.peso,
    required this.data,
    required this.registradoPor,
  });

  factory Saida.fromJson(Map<String, dynamic> json) {
    return Saida(
      id: json['id'],
      idMaterial: json['idMaterial'],
      idCliente: json['idCliente'],
      peso: double.tryParse(json['peso'].toString()) ?? 0,
      data: json['data'],
      registradoPor: json['registradoPor'],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "idMaterial": idMaterial,
        "idCliente": idCliente,
        "peso": peso,
        "data": data,
        "registradoPor": registradoPor,
      };
}
