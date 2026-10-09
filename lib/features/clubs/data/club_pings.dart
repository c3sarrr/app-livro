// G21.3 — o tempo real dos clubes (docs/progresso/G21.md §2 e §5; D-225): o canal privado `club:<id>` traz só um
// aviso sem conteúdo ("mudou"); quem ouve relê o resumo. Avisos seguidos se juntam numa releitura. Os canais só
// ficam abertos com a 25 (ou, depois, uma tela do clube) aberta.
import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart'
    show RealtimeChannelConfig, SupabaseClient;

/// Abre o canal [topic] e chama [onPing] a cada aviso; devolve como fechar.
typedef ClubChannelOpener = Future<void> Function() Function(
  String topic,
  void Function() onPing,
);

/// O canal do Supabase: Broadcast privado (a política de `realtime.messages` confere quem é do clube), evento
/// `changed`. O token da sessão vai pelo próprio cliente (ele chama `realtime.setAuth` a cada login e renovação).
ClubChannelOpener supabaseClubChannels(SupabaseClient client) =>
    (topic, onPing) {
      final channel = client.channel(
        topic,
        opts: const RealtimeChannelConfig(private: true),
      );
      channel
          .onBroadcast(event: 'changed', callback: (_) => onPing())
          .subscribe();
      return () async {
        await client.removeChannel(channel);
      };
    };

/// O tópico do clube [clubId].
String clubTopic(String clubId) => 'club:$clubId';

final class ClubPings {
  ClubPings(this._open, {this.settle = const Duration(seconds: 2)});

  final ClubChannelOpener _open;

  /// A espera para juntar avisos seguidos numa só releitura.
  final Duration settle;

  final _changes = StreamController<String>.broadcast();
  final Map<String, Future<void> Function()> _closers = {};
  final Map<String, Timer> _waiting = {};
  bool _closed = false;

  /// O id do clube que mudou (um por rajada de avisos).
  Stream<String> get changes => _changes.stream;

  /// Os clubes ouvidos agora.
  Set<String> get watching => Set.unmodifiable(_closers.keys);

  /// Passa a ouvir exatamente [clubIds]: abre os novos e fecha os que saíram.
  Future<void> watch(Set<String> clubIds) async {
    if (_closed) return;
    for (final id
        in _closers.keys.where((k) => !clubIds.contains(k)).toList()) {
      await _stop(id);
    }
    for (final id in clubIds.where((k) => !_closers.containsKey(k))) {
      _closers[id] = _open(clubTopic(id), () => _ping(id));
    }
  }

  void _ping(String clubId) {
    if (_closed || !_closers.containsKey(clubId)) return;
    _waiting[clubId]?.cancel();
    _waiting[clubId] = Timer(settle, () {
      _waiting.remove(clubId);
      if (!_closed) _changes.add(clubId);
    });
  }

  Future<void> _stop(String clubId) async {
    _waiting.remove(clubId)?.cancel();
    await _closers.remove(clubId)?.call();
  }

  /// Fecha todos os canais; nenhum aviso sai depois.
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    for (final id in _closers.keys.toList()) {
      await _stop(id);
    }
    await _changes.close();
  }
}
