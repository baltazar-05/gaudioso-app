class Cliente {
  final int? id;
  final String nome;
  final String documento;
  final String telefone;
  final String endereco;

  Cliente({
    this.id,
    required this.nome,
    required this.documento,
    required this.telefone,
    required this.endereco,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'],
      nome: json['nome'],
      documento: json['documento'],
      telefone: json['telefone'] ?? '',
      endereco: json['endereco'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "nome": nome,
        "documento": documento,
        "telefone": telefone,
        "endereco": endereco,
      };
}
