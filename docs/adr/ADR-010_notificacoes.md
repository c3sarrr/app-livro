# ADR-010 — Notificações: FCM/APNs via `firebase_messaging` (push) + `flutter_local_notifications` (meta diária)

- **Status:** aceita com pendência (G02) · **pendente:** teste em aparelho (sem aparelho/emulador e sem projeto Firebase/conta Apple hoje)
- **Data:** 03/10/2026

## Decisão

1. **Push (servidor → aparelho):** FCM no Android e APNs no iOS pelo `firebase_messaging`; tokens em
   `public.device_tokens` (o token está na lista branca do Grátis); envio pela Edge Function `push-sender`
   disparada por gatilho + `pg_net` (Anexo 02 §5.3 pendências). Payload **sem conteúdo pessoal** (ex.: "Nova
   resposta no clube" + id; o texto é buscado pelo app autenticado).
2. **Lembrete da meta diária:** notificação **local** agendada no aparelho (`flutter_local_notifications`), sem
   rede — vale para o Grátis sem mandar nada ao servidor.
3. Permissões: Android 13+ `POST_NOTIFICATIONS` pedida no momento de valor (não na abertura); Android 12+
   agendamento sem alarme exato (`inexact`) para não exigir `SCHEDULE_EXACT_ALARM`; iOS pedido provisório.
4. Público 13+ (Q13): padrão desligado para contas de adolescentes até a G25 decidir os padrões protetivos.

## Evidências

Nenhuma medição possível nesta fase: não há aparelho/emulador configurado (pendência de ambiente da G00: JDK do
Android), nem projeto Firebase/APNs (contas a criar). A decisão segue a recomendação do Anexo 05 §2 e não
depende de prova para as fases G03–G19 (o push entra na G21).

## Pendência — teste em aparelho (passos exatos)

1. Criar o projeto Firebase (`booknest-dev`) e registrar o app Android com o identificador definitivo (Q5);
   baixar `google-services.json` (configuração, não é segredo — mesmo assim fora do git por ambiente).
2. iOS: chave APNs (.p8) da conta Apple Developer enviada ao Firebase (exige Mac para o build).
3. `flutter run --release -d <aparelho>` com a tela de teste da G21 → anotar o token → enviar pela
   Edge Function `push-sender` → conferir recebimento com o app em primeiro plano, em segundo plano e fechado.
4. Lembrete local: agendar para +2 min, bloquear a tela, conferir; repetir com o modo economia de bateria.

## Alternativas consideradas

- **OneSignal/Expo:** coletam mais dados e mais um suboperador; sem ganho para o volume previsto.
- **Só notificações locais:** não atende clubes/social (respostas, encontros).
