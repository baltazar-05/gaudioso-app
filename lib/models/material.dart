class MaterialItem {
  final int? id;
  final String nome;
  final double precoCompra;
  final double precoVenda;

  MaterialItem({
    this.id,
    required this.nome,
    required this.precoCompra,
    required this.precoVenda,
  });

  static double _parseNum(dynamic v) {
    if (v == null) return 0;
    final s = v.toString().replaceAll(',', '.');
    return double.tryParse(s) ?? 0;
  }

  factory MaterialItem.fromJson(Map<String, dynamic> json) {
    // Suporta payloads antigos com precoRef
    final precoRef = _parseNum(json['precoRef']);
    return MaterialItem(
      id: json['id'],
      nome: json['nome'] ?? '',
      precoCompra: _parseNum(json['precoCompra'] ?? json['preco_compra']),
      precoVenda:
          _parseNum(json['precoVenda'] ?? json['preco_venda'] ?? precoRef),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "nome": nome,
        "precoCompra": precoCompra,
        "precoVenda": precoVenda,
      };
}
