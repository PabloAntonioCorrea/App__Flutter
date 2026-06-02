int parseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

double parseDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) {
    final normalized =
        value.replaceAll(RegExp(r'[^\d,.-]'), '').replaceAll(',', '.');
    return double.tryParse(normalized) ?? 0;
  }
  return 0;
}

String prioridadeParaApi(String? label, String? db) {
  if (db != null && db.isNotEmpty) return db;
  switch (label) {
    case 'Baixa':
      return 'Baixa';
    case 'Alta':
      return 'Alta';
    default:
      return 'Media';
  }
}
