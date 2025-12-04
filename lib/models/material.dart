class MaterialItem {
  final int? id;
  final String nome;
  final double precoCompra;
  final double precoVenda;
  final bool ativo;

  MaterialItem({
    this.id,
    required this.nome,
    required this.precoCompra,
    required this.precoVenda,
    this.ativo = true,
  });

  static double _parseNum(dynamic v) {
    if (v == null) return 0;
    final s = v.toString().replaceAll(',', '.');
    return double.tryParse(s) ?? 0;
  }

  static bool _parseBool(dynamic v) {
    if (v == null) return true;
    if (v is bool) return v;
    if (v is num) return v != 0;
    final s = v.toString().toLowerCase().trim();
    if (s == 'true' || s == '1' || s == 'ativo' || s == 'yes') return true;
    if (s == 'false' || s == '0' || s == 'inativo' || s == 'no') return false;
    return true;
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
      ativo: _parseBool(json['ativo']),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "nome": nome,
        "precoCompra": precoCompra,
        "precoVenda": precoVenda,
        "ativo": ativo,
      };
}
