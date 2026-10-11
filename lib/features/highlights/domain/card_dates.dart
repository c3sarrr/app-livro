// G19.1 — as datas dos cartões da tela 25 (R5), no fuso do aparelho: "hoje", "2 set" e, de outro ano, "2 set 2025"
// (o dia anterior já tem a data, como o arquivo: "19 set" no dia 20). A exportação pede sempre o ano ("2 set 2026").
// Dart puro.
const List<String> _months = [
  'jan',
  'fev',
  'mar',
  'abr',
  'mai',
  'jun',
  'jul',
  'ago',
  'set',
  'out',
  'nov',
  'dez',
];

DateTime _local(DateTime t, Duration Function(DateTime utc) offsetAt) {
  final u = t.toUtc();
  return u.add(offsetAt(u));
}

String cardDate(
  DateTime at, {
  required DateTime now,
  required Duration Function(DateTime utc) offsetAt,
  bool withYear = false,
}) {
  final d = _local(at, offsetAt);
  final today = _local(now, offsetAt);
  final day = DateTime.utc(d.year, d.month, d.day);
  final t0 = DateTime.utc(today.year, today.month, today.day);
  if (!withYear && day == t0) return 'hoje';
  final base = '${d.day} ${_months[d.month - 1]}';
  return withYear || d.year != today.year ? '$base ${d.year}' : base;
}
