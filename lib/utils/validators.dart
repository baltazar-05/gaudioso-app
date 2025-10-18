// lib/utils/validators.dart

/// Mantém apenas dígitos 0-9
String onlyDigits(String s) => s.replaceAll(RegExp(r'[^0-9]'), '');

/// Retorna true quando todos os dígitos são iguais (ex.: 00000000000)
bool _allSame(String digits) => RegExp(r'^(\d)\1*$').hasMatch(digits);

bool isValidCPF(String? value) {
  if (value == null) return false;
  final cpf = onlyDigits(value);
  if (cpf.length != 11) return false;
  if (_allSame(cpf)) return false;

  var sum = 0;
  for (var i = 0; i < 9; i++) {
    sum += int.parse(cpf[i]) * (10 - i);
  }
  var mod = sum % 11;
  final dv1 = (mod < 2) ? 0 : 11 - mod;
  if (dv1 != int.parse(cpf[9])) return false;

  sum = 0;
  for (var i = 0; i < 10; i++) {
    sum += int.parse(cpf[i]) * (11 - i);
  }
  mod = sum % 11;
  final dv2 = (mod < 2) ? 0 : 11 - mod;
  if (dv2 != int.parse(cpf[10])) return false;

  return true;
}

bool isValidCNPJ(String? value) {
  if (value == null) return false;
  final cnpj = onlyDigits(value);
  if (cnpj.length != 14) return false;
  if (_allSame(cnpj)) return false;

  const w1 = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
  const w2 = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];

  var sum = 0;
  for (var i = 0; i < 12; i++) {
    sum += int.parse(cnpj[i]) * w1[i];
  }
  var mod = sum % 11;
  final dv1 = (mod < 2) ? 0 : 11 - mod;
  if (dv1 != int.parse(cnpj[12])) return false;

  sum = 0;
  for (var i = 0; i < 13; i++) {
    sum += int.parse(cnpj[i]) * w2[i];
  }
  mod = sum % 11;
  final dv2 = (mod < 2) ? 0 : 11 - mod;
  if (dv2 != int.parse(cnpj[13])) return false;

  return true;
}

/// Valida CPF ou CNPJ automaticamente conforme a quantidade de dígitos.
String? docCpfCnpjValidator(String? v) {
  if (v == null || v.trim().isEmpty) return 'Digite o documento';
  final digits = onlyDigits(v);
  if (digits.length == 11) {
    return isValidCPF(digits) ? null : 'CPF inválido';
  } else if (digits.length == 14) {
    return isValidCNPJ(digits) ? null : 'CNPJ inválido';
  } else {
    return 'Documento deve ter 11 (CPF) ou 14 (CNPJ) dígitos';
  }
}

/// Valida telefone (10 ou 11 dígitos)
String? telefoneValidator(String? v) {
  if (v == null || v.trim().isEmpty) return 'Digite o telefone';
  final digits = onlyDigits(v);
  if (digits.length < 10 || digits.length > 11) {
    return 'Telefone deve ter 10 ou 11 dígitos';
  }
  return null;
}

