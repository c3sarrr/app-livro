// G02 · S4 — codec BNK1 dos traços de tinta (Anexo 03 §9.6). Dart puro (sem dart:ui).
//
//   cabeçalho: "BNK1" | versão u8 | nº de traços varint
//   traço:     ferramenta u8 | ponta u8 | cor RGB 3 bytes | alpha u8 | largura (centésimos de mm) u16 LE
//              nº de pontos varint
//              pontos: x, y quantizados (1/escala da unidade da camada) em delta zigzag varint,
//                      pressão u8 (0–255), Δt ms varint (o 1º ponto guarda o Δt desde o início do traço)
//
// Unidade da camada (D-29): `over_text` → em da palavra-âncora (escala 100 = 1/100 em);
// `space` → caixa do espaço normalizada (escala 10000 = 1/10000 da caixa).
// Quantização: |x − x'| ≤ 0,5 / escala; pressão ±0,5/255; tempo em ms inteiros. Arredondamento
// "meio para longe do zero" (`double.round()` do Dart = `Math.round` do JS para positivos); outra
// implementação (servidor, exportação) precisa usar o mesmo — o teste do formato congelado pega.
import 'dart:typed_data';

const versaoBnk1 = 1;

/// Limite por camada (CHECK no banco: 256 KiB).
const limiteCamadaBytes = 256 * 1024;

enum UnidadeCamada {
  em(100),
  caixa(10000);

  const UnidadeCamada(this.escala);
  final int escala;
}

class PontoTinta {
  const PontoTinta(this.x, this.y, this.pressao, this.tMs);

  final double x;
  final double y;

  /// 0–1.
  final double pressao;

  /// Milissegundos desde o início do traço.
  final int tMs;
}

class Traco {
  const Traco({
    required this.ferramenta,
    required this.ponta,
    required this.argb,
    required this.larguraCentesimosMm,
    required this.pontos,
  });

  final int ferramenta;
  final int ponta;
  final int argb;
  final int larguraCentesimosMm;
  final List<PontoTinta> pontos;
}

sealed class FalhaBnk1 implements Exception {
  const FalhaBnk1(this.mensagem);
  final String mensagem;
  @override
  String toString() => 'FalhaBnk1: $mensagem';
}

class AssinaturaInvalida extends FalhaBnk1 {
  const AssinaturaInvalida() : super('não começa com "BNK1"');
}

class VersaoDesconhecida extends FalhaBnk1 {
  const VersaoDesconhecida(this.versao) : super('versão $versao desconhecida');
  final int versao;
}

class DadosTruncados extends FalhaBnk1 {
  const DadosTruncados() : super('dados terminam no meio de um campo');
}

class LixoNoFim extends FalhaBnk1 {
  const LixoNoFim(int n) : super('$n bytes sobrando depois do último traço');
}

class ValorForaDaFaixa extends FalhaBnk1 {
  const ValorForaDaFaixa(super.mensagem);
}

class _Escritor {
  final _b = BytesBuilder();

  void u8(int v) => _b.addByte(v & 0xFF);

  void u16(int v) {
    _b
      ..addByte(v & 0xFF)
      ..addByte((v >> 8) & 0xFF);
  }

  void varint(int v) {
    assert(v >= 0);
    while (v >= 0x80) {
      _b.addByte((v & 0x7F) | 0x80);
      v >>= 7;
    }
    _b.addByte(v);
  }

  void zigzag(int v) => varint(v >= 0 ? v << 1 : ((-v) << 1) - 1);

  void bytes(List<int> b) => _b.add(b);

  Uint8List pronto() => _b.takeBytes();
}

class _Leitor {
  _Leitor(this._d);
  final Uint8List _d;
  int _i = 0;

  int get restante => _d.length - _i;

  int u8() {
    if (_i >= _d.length) throw const DadosTruncados();
    return _d[_i++];
  }

  int u16() => u8() | (u8() << 8);

  int varint() {
    var r = 0;
    var s = 0;
    while (true) {
      final b = u8();
      r |= (b & 0x7F) << s;
      if (b < 0x80) return r;
      s += 7;
      if (s > 63) throw const ValorForaDaFaixa('varint longo demais');
    }
  }

  int zigzag() {
    final v = varint();
    return (v & 1) == 0 ? v >> 1 : -((v + 1) >> 1);
  }
}

int quantizar(double v, UnidadeCamada u) => (v * u.escala).round();
int quantizarPressao(double p) => (p.clamp(0.0, 1.0) * 255).round();

Uint8List codificarBnk1(List<Traco> tracos, UnidadeCamada unidade) {
  final w = _Escritor()
    ..bytes(const [0x42, 0x4E, 0x4B, 0x31]) // "BNK1"
    ..u8(versaoBnk1)
    ..varint(tracos.length);
  for (final t in tracos) {
    if (t.larguraCentesimosMm < 0 || t.larguraCentesimosMm > 0xFFFF) {
      throw ValorForaDaFaixa('largura ${t.larguraCentesimosMm}');
    }
    w
      ..u8(t.ferramenta)
      ..u8(t.ponta)
      ..u8(t.argb >> 16)
      ..u8(t.argb >> 8)
      ..u8(t.argb)
      ..u8(t.argb >> 24)
      ..u16(t.larguraCentesimosMm)
      ..varint(t.pontos.length);
    var px = 0;
    var py = 0;
    var pt = 0;
    for (final p in t.pontos) {
      final qx = quantizar(p.x, unidade);
      final qy = quantizar(p.y, unidade);
      final dt = p.tMs - pt;
      if (dt < 0) throw ValorForaDaFaixa('tempo voltou: ${p.tMs} < $pt');
      w
        ..zigzag(qx - px)
        ..zigzag(qy - py)
        ..u8(quantizarPressao(p.pressao))
        ..varint(dt);
      px = qx;
      py = qy;
      pt = p.tMs;
    }
  }
  return w.pronto();
}

List<Traco> decodificarBnk1(Uint8List dados, UnidadeCamada unidade) {
  final r = _Leitor(dados);
  if (dados.length < 4 ||
      r.u8() != 0x42 ||
      r.u8() != 0x4E ||
      r.u8() != 0x4B ||
      r.u8() != 0x31) {
    throw const AssinaturaInvalida();
  }
  final versao = r.u8();
  if (versao != versaoBnk1) throw VersaoDesconhecida(versao);
  final n = r.varint();
  final tracos = <Traco>[];
  for (var k = 0; k < n; k++) {
    final ferramenta = r.u8();
    final ponta = r.u8();
    final rr = r.u8();
    final gg = r.u8();
    final bb = r.u8();
    final aa = r.u8();
    final largura = r.u16();
    final np = r.varint();
    final pontos = <PontoTinta>[];
    var x = 0;
    var y = 0;
    var t = 0;
    for (var i = 0; i < np; i++) {
      x += r.zigzag();
      y += r.zigzag();
      final pr = r.u8();
      t += r.varint();
      pontos.add(
        PontoTinta(x / unidade.escala, y / unidade.escala, pr / 255, t),
      );
    }
    tracos.add(
      Traco(
        ferramenta: ferramenta,
        ponta: ponta,
        argb: (aa << 24) | (rr << 16) | (gg << 8) | bb,
        larguraCentesimosMm: largura,
        pontos: pontos,
      ),
    );
  }
  if (r.restante != 0) throw LixoNoFim(r.restante);
  return tracos;
}
