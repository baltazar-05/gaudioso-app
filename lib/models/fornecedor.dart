class Fornecedor {
  final int? id;
  final String nome;
  final String documento;
  final String telefone;
  final String endereco;
  final bool ativo;

  Fornecedor({
    this.id,
    required this.nome,
    required this.documento,
    required this.telefone,
    required this.endereco,
    this.ativo = true,
  });

  factory Fornecedor.fromJson(Map<String, dynamic> json) {
    return Fornecedor(
      id: json['id'],
      nome: json['nome'],
      documento: json['documento'],
      telefone: json['telefone'] ?? '',
      endereco: json['endereco'] ?? '',
      ativo: json['ativo'] != null ? json['ativo'] == true || json['ativo'] == 1 || json['ativo'] == '1' : true,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "nome": nome,
        "documento": documento,
        "telefone": telefone,
        "endereco": endereco,
        "ativo": ativo,
      };
}
