import 'package:flutter/services.dart';

/// Formata dinamicamente CPF (###.###.###-##) ou CNPJ (##.###.###/####-##)
/// conforme a quantidade de dígitos digitados.
class CpfCnpjInputFormatter extends TextInputFormatter {
  String _formatCPF(String digits) {
    final b = StringBuffer();
    for (var i = 0; i < digits.length && i < 11; i++) {
      if (i == 3 || i == 6) b.write('.');
      if (i == 9) b.write('-');
      b.write(digits[i]);
    }
    return b.toString();
  }

  String _formatCNPJ(String digits) {
    final b = StringBuffer();
    for (var i = 0; i < digits.length && i < 14; i++) {
      if (i == 2 || i == 5) b.write('.');
      if (i == 8) b.write('/');
      if (i == 12) b.write('-');
      b.write(digits[i]);
    }
    return b.toString();
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    String formatted;
    if (digits.length <= 11) {
      formatted = _formatCPF(digits);
    } else {
      formatted = _formatCNPJ(digits);
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

