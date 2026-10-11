// Formato canônico dos valores no SQLite (ADR-002 §7) e conversores do drift.
//   timestamptz → TEXT "YYYY-MM-DDTHH:MM:SS.ffffffZ" (6 casas, sempre — é o que volta do servidor);
//   jsonb       → TEXT JSON;   numeric → TEXT decimal (sem perder precisão);   enum → código do SQL;
//   version_hlc → TEXT do HLC (ordenável byte a byte).
import 'dart:convert';

import 'package:drift/drift.dart';

import '../clock/hlc.dart';
import '../model/checks.dart';
import '../../../features/reader/domain/locator.dart';

/// Data/hora UTC com 6 casas decimais.
String formatInstant(DateTime value) {
  if (!value.isUtc) {
    throw ArgumentError.value(value, 'value', 'precisa ser UTC');
  }
  String two(int n) => n.toString().padLeft(2, '0');
  final micros = value.millisecond * 1000 + value.microsecond;
  return '${value.year.toString().padLeft(4, '0')}-${two(value.month)}-'
      '${two(value.day)}T${two(value.hour)}:${two(value.minute)}:'
      '${two(value.second)}.${micros.toString().padLeft(6, '0')}Z';
}

/// Aceita o formato canônico e as variações que o servidor/PowerSync podem mandar
/// (espaço no lugar do "T", "+00:00" no lugar do "Z", menos casas decimais).
DateTime parseInstant(String text) {
  final parsed = DateTime.tryParse(text);
  if (parsed == null || !_hasZone.hasMatch(text)) {
    throw FormatException('data/hora sem fuso ou inválida', text);
  }
  return parsed.toUtc();
}

final RegExp _hasZone = RegExp(r'(Z|[+-]\d\d:?\d\d)$');

final class InstantConverter extends TypeConverter<DateTime, String> {
  const InstantConverter();

  @override
  DateTime fromSql(String fromDb) => parseInstant(fromDb);

  @override
  String toSql(DateTime value) => formatInstant(value);
}

final class HlcConverter extends TypeConverter<Hlc, String> {
  const HlcConverter();

  @override
  Hlc fromSql(String fromDb) => Hlc.parse(fromDb);

  @override
  String toSql(Hlc value) => value.toString();
}

/// Enum ↔ código do CHECK do SQL.
final class CodeConverter<T extends DbCode> extends TypeConverter<T, String> {
  const CodeConverter(this._fromCode);

  final T Function(String code) _fromCode;

  @override
  T fromSql(String fromDb) => _fromCode(fromDb);

  @override
  String toSql(T value) => value.code;
}

/// `numeric(p,s)` como TEXT com [fractionDigits] casas fixas ("0.62113", "1.2").
final class DecimalTextConverter extends TypeConverter<double, String> {
  const DecimalTextConverter(this.fractionDigits);

  final int fractionDigits;

  @override
  double fromSql(String fromDb) => double.parse(fromDb);

  @override
  String toSql(double value) => value.toStringAsFixed(fractionDigits);
}

final class LocatorConverter extends TypeConverter<Locator, String> {
  const LocatorConverter();

  @override
  Locator fromSql(String fromDb) =>
      Locator.fromJson((jsonDecode(fromDb) as Map).cast<String, Object?>());

  @override
  String toSql(Locator value) => jsonEncode(value.toJson());
}

final class AnchorConverter extends TypeConverter<TextAnchor, String> {
  const AnchorConverter();

  @override
  TextAnchor fromSql(String fromDb) =>
      TextAnchor.fromJson((jsonDecode(fromDb) as Map).cast<String, Object?>());

  @override
  String toSql(TextAnchor value) => jsonEncode(value.toJson());
}

/// Lista de textos em JSON (`pen_presets.favorite_colors`).
final class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) =>
      List.unmodifiable((jsonDecode(fromDb) as List).cast<String>());

  @override
  String toSql(List<String> value) => jsonEncode(value);
}
