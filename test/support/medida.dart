// Medidas de desempenho nos testes (Anexo 03 §12). Com BOOKNEST_MEDIR=1 — a rodada de medida, sozinha e com
// `--concurrency=1` — valem os orçamentos do anexo; na suíte normal os arquivos rodam em paralelo e o relógio
// de parede inclui o tempo em que o processo esperou a CPU, então só vale um teto de sanidade (pega um
// desastre, não uma flutuação).
import 'dart:io';

bool get medindo => Platform.environment['BOOKNEST_MEDIR'] == '1';

/// O orçamento do anexo na rodada de medida; [folga] na suíte normal.
num orcamento(num anexo, {required num folga}) => medindo ? anexo : folga;
