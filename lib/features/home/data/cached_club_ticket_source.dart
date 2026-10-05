// Ticket do Clube a partir do cache do social no aparelho (D-80): a G21 grava, por dono, o resumo do clube da
// Início em `social_cache` (para abrir offline); até lá a chave não existe e o ticket some. Conteúdo que não
// se entende vira "sem clube" — nunca derruba a Início.
import 'dart:convert';
import 'dart:ui' show Color;

import '../../../core/data/database/app_database.dart';
import '../../../core/data/database/codecs.dart';
import '../domain/models.dart';
import 'home_sources.dart';
import 'local_home_repository.dart' show UtcOffsetAt, deviceUtcOffset;

/// Formato do resumo (JSON) que a G21 grava em [CachedClubTicketSource.keyFor]:
///
/// ```json
/// {"id": "…", "name_prefix": "Leitoras de", "name_highlight": "Capitu",
///  "book": {"id": "…", "title": "…", "author": "…", "cover_ref": "ol:…", "isbn13": "978…"},
///  "until_chapter": 50, "participants": [{"initial": "A", "color": "#B6ACE4"}],
///  "participants_count": 11, "group_progress": 0.54, "user_progress": 0.62, "user_initial": "M",
///  "unread_messages": 3, "next_meeting": "2026-09-24T23:00:00.000000Z"}
/// ```
final class CachedClubTicketSource implements ClubTicketSource {
  CachedClubTicketSource(this._database, {this._utcOffsetAt = deviceUtcOffset});

  final Future<AppDatabase> Function() _database;
  final UtcOffsetAt _utcOffsetAt;

  /// Chave por dono (D-68): um clube de outra conta guardada no aparelho não aparece.
  static String keyFor(String owner) => 'inicio.clube:$owner';

  @override
  Future<BookClub?> current(String owner) async {
    final db = await _database();
    final row = await (db.select(
      db.socialCache,
    )..where((t) => t.key.equals(keyFor(owner)))).getSingleOrNull();
    if (row == null) return null;
    try {
      return _parse(jsonDecode(row.payload));
    } on Object {
      return null;
    }
  }

  BookClub? _parse(Object? json) {
    if (json is! Map<String, Object?>) return null;
    final book = json['book']! as Map<String, Object?>;
    final meeting = parseInstant(json['next_meeting']! as String);
    final local = meeting.add(_utcOffsetAt(meeting));
    return BookClub(
      id: json['id']! as String,
      namePrefix: json['name_prefix']! as String,
      nameHighlight: json['name_highlight']! as String,
      book: Book(
        id: book['id']! as String,
        title: book['title']! as String,
        author: book['author']! as String,
        cover: PhotoCover(
          ref: book['cover_ref'] as String?,
          isbn13: book['isbn13'] as String?,
        ),
      ),
      untilChapter: (json['until_chapter']! as num).toInt(),
      shownParticipants: List.unmodifiable([
        for (final p in json['participants']! as List<Object?>)
          _participant(p! as Map<String, Object?>),
      ]),
      participantsCount: (json['participants_count']! as num).toInt(),
      groupProgress: (json['group_progress']! as num).toDouble(),
      userProgress: (json['user_progress']! as num).toDouble(),
      userInitial: json['user_initial']! as String,
      unreadMessages: (json['unread_messages']! as num).toInt(),
      nextMeeting: DateTime(
        local.year,
        local.month,
        local.day,
        local.hour,
        local.minute,
      ),
    );
  }

  static ClubParticipant _participant(Map<String, Object?> p) =>
      ClubParticipant(
        initial: p['initial']! as String,
        color: _color(p['color']! as String),
      );

  static Color _color(String hex) {
    if (!RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(hex)) {
      throw FormatException('cor', hex);
    }
    return Color(0xFF000000 | int.parse(hex.substring(1), radix: 16));
  }
}
