# ADR-006 — Tinta: `Listener` cru + suavização própria (porte do perfect-freehand) + codec BNK1

- **Status:** aceita pelo spike S4 **simulado** (G02) · **pendente:** latência medida em aparelho (comando abaixo)
- **Data:** 03/10/2026
- **Prova:** `spikes/S4_tinta/` (`dados/resultado_bnk1.json`, `dados/bench_host.json`, `dados/resultado_caminho.json`)
- **Escolha do Cesar (início da G02):** "simular agora" — codec, suavização e custo por ponto em teste; a latência no aparelho fica pendente com o comando exato.

## Contexto

Telas 22–24b: caneta, marca-texto, borracha, laço, reta e espaço aberto; a tinta "acompanha se a fonte
mudar" (D-29). Orçamento (Anexo 03 §12): latência do traço p95 ≤ 16,7 ms a 60 Hz e ≤ 8,3 ms a 120 Hz;
camada ≤ 256 KiB (CHECK no banco).

## Decisão

1. **Entrada:** `Listener` de ponteiro cru (não `GestureDetector`), com `pressure` só quando
   `kind == stylus` (dedo → pressão simulada pela velocidade). Pintor com `Listenable` só da camada viva.
2. **Suavização:** porte em Dart puro do **perfect-freehand 1.2.3** (MIT, atribuição no arquivo),
   `contorno(pontos, opções)` → polígono preenchido. Pontas (Anexo 03 §9.3): Esferográfica (afinamento
   0,1), Tinteiro (0,6, afunila no fim), Pincel (0,85, suavização 0,5). Espessura: 1 mm = 160/25,4 dp (D-28).
3. **Ao vivo:** recalcular o contorno **inteiro** a cada amostra (é barato — números abaixo); só
   considerar cache do trecho estável se o aparelho mostrar o contrário.
4. **Codec BNK1** exatamente como o Anexo 03 §9.6, com estas precisões: largura u16 **little-endian**;
   o 1º ponto guarda Δt desde o início do traço; arredondamento "meio para longe do zero" (igual ao
   `Math.round` do JS para positivos); erros tipados (`AssinaturaInvalida`, `VersaoDesconhecida`,
   `DadosTruncados`, `LixoNoFim`, `ValorForaDaFaixa`). Versão 1 **congelada** por vetor de bytes no teste
   (mudar o formato = versão 2 + migração).

## Evidências (simuladas — Windows, Ryzen 5 2600X)

| Prova | Resultado |
|---|---|
| Porte × perfect-freehand 1.2.3 (npm) | 30 casos (curtos, canto agudo, livre, 600 pontos; 5 conjuntos de opções): **6.784 pontos de contorno, erro máx 5,7 × 10⁻¹⁴** |
| BNK1 ida e volta | **1.000 traços aleatórios / 152.005 pontos** nas 2 unidades; erro ≤ meia unidade; recodificar dá os mesmos bytes |
| BNK1 robustez | 570/570 prefixos truncados recusados; versão 2 recusada; lixo no fim recusado; tempo voltando recusado |
| Tamanho (traços realistas: manuscrito, sublinhado, círculo) | **412 bytes/100 pontos a 120 Hz** (p95 428); 424 a 60 Hz; 406 a 240 Hz — dentro dos 350–450 previstos |
| Limite de 256 KiB | ≈ 63.600 pontos por camada ≈ **8,8 min de tinta contínua a 120 Hz** (17 min a 60 Hz) |
| Codec (Dart AOT) | 4,3 µs para codificar e 2,9 µs para decodificar 100 pontos |
| Suavização (Dart AOT) | **≈ 0,09–0,13 µs por ponto**; contorno de 2.000 pontos em 0,17–0,21 ms |
| Traço ao vivo, contorno inteiro a cada amostra (AOT) | 120 Hz: p50 14 µs · p95 24 µs · máx 147 µs (orçamento do quadro: 8.333 µs) |
| `Path` + gravação do desenho (267 vértices, JIT) | 156 µs por quadro |
| Pressão (0,9 ÷ 0,2) na largura | esferográfica 1,15× · tinteiro 2,31× · pincel 3,43× |

Mesmo com um aparelho 10× mais lento, a parte da CPU (suavização + `Path`) fica abaixo de 2 ms por quadro;
o que decide a meta é a rasterização e o pipeline do sistema — por isso a medição em aparelho é obrigatória.

## Pendência — latência em aparelho (comando exato)

```powershell
cd spikes\S4_tinta
flutter create --platforms=android,ios --project-name spike_s4_tinta .   # só na 1ª vez (gera android/ e ios/)
flutter devices                                                           # pegar o id do aparelho
flutter run --profile -d <id-do-aparelho> -t lib/latencia_app.dart
```
Desenhar ~20 traços com o dedo (e com a caneta, se houver); a tela mostra `Hz · eventos · p50 · p95 · máx`
e o console imprime `S4LAT {json}` a cada traço. **Passa** se p95 ≤ 16,7 ms (tela de 60 Hz) ou ≤ 8,3 ms
(120 Hz). Bloqueios de ambiente hoje: sem aparelho/emulador configurado e JDK do Android quebrado
(pendência da G00). Se não passar: pontos previstos (iOS *predicted touches* / Android
`MotionEventPredictor`) por canal de plataforma (Anexo 03 §9.3) e camada viva em `RepaintBoundary` própria.

## Consequências

- O traço confirmado vira imagem em cache por página (Anexo 03 §9.2, camada 5); só a camada viva repinta.
- O codec é Dart puro → roda em isolate para exportar/importar sem travar a UI.
- Servidor e exportação que lerem BNK1 precisam do mesmo arredondamento (vetor congelado no teste).

## Alternativas consideradas

- `GestureDetector`/`Pan`: atrasa o 1º ponto (desambiguação de gestos) e perde a pressão.
- Pacotes prontos de desenho: layout/estilo próprio e sem controle da âncora em em (D-29).
- Formato JSON/Protobuf: 3–5× maior que o BNK1 para o mesmo traço; o limite de 256 KiB cairia para minutos.
