# S4 · Tinta (simulado) — ADR-006

| Arquivo | O que é |
|---|---|
| `lib/bnk1.dart` | Codec BNK1 (Anexo 03 §9.6), Dart puro, erros tipados |
| `lib/suavizacao.dart` | Porte do perfect-freehand 1.2.3 (MIT) + pontas da tela 23 + 1 mm = 6,299 dp |
| `lib/simulador.dart` | Traços sintéticos realistas (manuscrito, sublinhado, círculo) a 60/120/240 Hz |
| `lib/latencia/medidor.dart` | Latência = evento de ponteiro → fim da rasterização do quadro seguinte |
| `lib/latencia_app.dart` | **App de medição em aparelho** (`flutter run --profile -t lib/latencia_app.dart`) |
| `bin/bench.dart` | Custo do codec e da suavização em Dart AOT → `dados/bench_host.json` |
| `ferramentas/gerar_referencia_pf.mjs` | Gera `dados/pf_referencia.json` com o pacote npm `perfect-freehand@1.2.3` |
| `test/` | 11 testes: ida e volta, formato congelado, erros, tamanho, paridade do porte, pontas, latência sintética, fumaça do app, custo do `Path` |

```powershell
cd spikes\S4_tinta; flutter test
dart compile exe bin/bench.dart -o build/bench.exe; cmd /c "build\bench.exe > dados\bench_host.json"
```
