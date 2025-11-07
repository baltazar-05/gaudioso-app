import 'package:intl/intl.dart';

class Relatorio {
  final String identificador;
  final DateTime? dataCadastro;
  final String? cadastradoPor;
  final double? pesoTotal;
  final double? valorTotal;
  final String? fornecedor;
  final double? totalEntradas;
  final double? totalSaidas;
  final double? saldo;
  final List<RelatorioItem> itens;
  final Map<String, dynamic> raw;

  Relatorio({
    required this.identificador,
    required this.dataCadastro,
    required this.cadastradoPor,
    required this.pesoTotal,
    required this.valorTotal,
    required this.fornecedor,
    required this.totalEntradas,
    required this.totalSaidas,
    required this.saldo,
    required this.itens,
    required this.raw,
  });

  factory Relatorio.fromJson(Map<String, dynamic> json) {
    final itens =
        _extractList(json, const [
          'itens',
          'materiais',
          'conteudo',
          'detalhes',
          'materiaisLote',
        ]).map((e) {
          if (e is Map<String, dynamic>) {
            return RelatorioItem.fromJson(e);
          }
          return RelatorioItem.fromJson({'descricao': e});
        }).toList();

    return Relatorio(
      identificador: _resolveIdentificador(json),
      dataCadastro: _parseDate(
        json['dataCadastro'] ??
            json['data'] ??
            json['createdAt'] ??
            json['dataRegistro'],
      ),
      cadastradoPor: _resolveResponsavel(json),
      pesoTotal: _toDouble(
        json['pesoTotal'] ??
            json['totalPeso'] ??
            json['peso'] ??
            json['pesoKg'],
      ),
      valorTotal: _toDouble(
        json['valorTotal'] ??
            json['totalValor'] ??
            json['valor'] ??
            json['valorBruto'],
      ),
      fornecedor: _resolveFornecedor(json),
      totalEntradas: _toDouble(json['totalEntradas']),
      totalSaidas: _toDouble(json['totalSaidas']),
      saldo: _toDouble(json['saldo'] ?? json['saldoAtual']),
      itens: itens,
      raw: json,
    );
  }

  double? get pesoCalculado =>
      pesoTotal ?? _sumNullable(itens.map((e) => e.peso ?? e.quantidade));
  double? get valorCalculado =>
      valorTotal ?? _sumNullable(itens.map((e) => e.valorTotal));
  String? get observacao =>
      raw['observacao']?.toString() ??
      raw['obs']?.toString() ??
      raw['descricao']?.toString();

  bool matches(String termo) {
    if (termo.isEmpty) return true;
    final lower = termo.toLowerCase();
    bool containsTerm(String? value) {
      if (value == null) return false;
      return value.toLowerCase().contains(lower);
    }
    if (containsTerm(identificador) ||
        containsTerm(cadastradoPor) ||
        containsTerm(fornecedor) ||
        containsTerm(observacao)) {
      return true;
    }
    final numbers = <double?>[
      totalEntradas,
      totalSaidas,
      saldo,
      pesoTotal,
      valorTotal,
    ];
    for (final number in numbers) {
      if (number != null &&
          number.toString().toLowerCase().contains(lower)) {
        return true;
      }
    }
    for (final item in itens) {
      if (item.matches(lower)) {
        return true;
      }
    }
    return false;
  }
}

class RelatorioItem {
  final String descricao;
  final double? quantidade;
  final double? peso;
  final double? valorUnitario;
  final double? valorTotal;
  final String? observacao;
  final Map<String, dynamic> raw;

  RelatorioItem({
    required this.descricao,
    required this.quantidade,
    required this.peso,
    required this.valorUnitario,
    required this.valorTotal,
    required this.observacao,
    required this.raw,
  });

  factory RelatorioItem.fromJson(Map<String, dynamic> json) {
    final desc =
        json['descricao'] ??
        json['material'] ??
        json['nomeMaterial'] ??
        json['nome'] ??
        json['titulo'] ??
        json['item'] ??
        'Item';

    final qtd = _toDouble(
      json['quantidade'] ?? json['qtd'] ?? json['quantidadeItens'],
    );
    final peso = _toDouble(
      json['peso'] ?? json['pesoKg'] ?? json['quantidadeKg'],
    );
    final valorUnitario = _toDouble(
      json['valorUnitario'] ??
          json['precoUnitario'] ??
          json['valorKg'] ??
          json['preco'],
    );
    double? valorTotal = _toDouble(
      json['valorTotal'] ?? json['total'] ?? json['valor'] ?? json['subtotal'],
    );
    if (valorTotal == null && valorUnitario != null && (peso ?? qtd) != null) {
      valorTotal = valorUnitario * (peso ?? qtd)!;
    }

    return RelatorioItem(
      descricao: desc.toString(),
      quantidade: qtd,
      peso: peso,
      valorUnitario: valorUnitario,
      valorTotal: valorTotal,
      observacao: json['observacao']?.toString() ?? json['obs']?.toString(),
      raw: json,
    );
  }

  bool matches(String termoLower) {
    if (descricao.toLowerCase().contains(termoLower)) {
      return true;
    }
    if (observacao != null &&
        observacao!.toLowerCase().contains(termoLower)) {
      return true;
    }
    final numbers = <double?>[quantidade, peso, valorUnitario, valorTotal];
    for (final number in numbers) {
      if (number != null &&
          number.toString().toLowerCase().contains(termoLower)) {
        return true;
      }
    }
    return false;
  }
}

String _resolveIdentificador(Map<String, dynamic> json) {
  final candidates = [
    json['codigoLote'],
    json['codigo'],
    json['nomeLote'],
    json['lote'],
    json['identificador'],
    json['numero'],
    json['titulo'],
    json['nomeMaterial'],
  ];
  for (final candidate in candidates) {
    if (candidate == null) continue;
    final text = candidate.toString().trim();
    if (text.isNotEmpty) return text;
  }
  return 'Lote';
}

String? _resolveResponsavel(Map<String, dynamic> json) {
  final candidates = [
    json['cadastradoPor'],
    json['usuario'],
    json['responsavel'],
    json['registradoPorNome'],
    json['nomeUsuario'],
    json['nomeResponsavel'],
  ];
  for (final candidate in candidates) {
    if (candidate == null) continue;
    final text = candidate.toString().trim();
    if (text.isNotEmpty) return text;
  }
  final registradoId = json['registradoPor'];
  if (registradoId != null) {
    final text = registradoId.toString().trim();
    if (text.isNotEmpty) return 'ID $text';
  }
  return null;
}

String? _resolveFornecedor(Map<String, dynamic> json) {
  final candidates = [
    json['fornecedor'],
    json['nomeFornecedor'],
    json['fornecedorNome'],
  ];
  for (final candidate in candidates) {
    if (candidate == null) continue;
    final text = candidate.toString().trim();
    if (text.isNotEmpty) return text;
  }
  return null;
}

Iterable<dynamic> _extractList(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is List) {
      return value.cast<dynamic>();
    }
  }
  return const [];
}

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  final str = value.toString().trim();
  if (str.isEmpty) return null;
  return double.tryParse(str.replaceAll(',', '.'));
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  final str = value.toString().trim();
  if (str.isEmpty) return null;
  try {
    return DateTime.parse(str);
  } catch (_) {
    for (final pattern in ['dd/MM/yyyy', 'dd-MM-yyyy', 'MM/dd/yyyy']) {
      try {
        return DateFormat(pattern).parse(str);
      } catch (_) {
        // segue tentando outros formatos
      }
    }
  }
  return null;
}

double? _sumNullable(Iterable<double?> values) {
  var acc = 0.0;
  var hasValue = false;
  for (final value in values) {
    if (value == null) continue;
    acc += value;
    hasValue = true;
  }
  return hasValue ? acc : null;
}
