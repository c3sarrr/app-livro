/// Falhas tipadas das escritas no banco local.
sealed class LocalDataFailure implements Exception {
  const LocalDataFailure();
}

/// Já existe outra linha ativa (não apagada) do mesmo usuário com o mesmo valor numa coluna que o
/// servidor exige única (índices únicos parciais de `personal.*`: o mesmo arquivo na estante, a mesma
/// cor nos rótulos). Sem esta checagem o upload falharia (23505) e, em cascata, as linhas filhas.
final class DuplicateActiveRow extends LocalDataFailure {
  const DuplicateActiveRow({
    required this.table,
    required this.column,
    required this.existingId,
  });

  final String table;
  final String column;
  final String existingId;

  @override
  String toString() =>
      'DuplicateActiveRow($table.$column já usada pela linha $existingId)';
}
