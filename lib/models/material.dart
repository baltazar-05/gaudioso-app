class MaterialItem {
  final int? id;
  final String nome;
  final String unidade;
  final double precoRef;

  MaterialItem({
    this.id,
    required this.nome,
    required this.unidade,
    required this.precoRef,
  });

  factory MaterialItem.fromJson(Map<String, dynamic> json) {
    return MaterialItem(
      id: json['id'],
      nome: json['nome'],
      unidade: json['unidade'],
      precoRef: double.tryParse(json['precoRef'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "nome": nome,
        "unidade": unidade,
        "precoRef": precoRef,
      };
}
