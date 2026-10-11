# G07 · Roteiro do teste no celular (scanner e catálogo)

Você pediu para ligar o celular depois: tudo da G07 foi provado com testes automáticos (câmera de mentira,
servidores locais). Este roteiro é o que falta provar **no aparelho**. Leva uns 20 minutos.

## Antes

1. No PC, com o Ubuntu do WSL: `supabase start` (pasta do app) e, numa janela do PowerShell na pasta
   `workers\catalog`: `npm run dev` (o Worker do catálogo em `http://127.0.0.1:8787`, com o R2 local já
   publicado por `npm run publicar-local`).
2. O celular Android na **mesma rede Wi-Fi** do PC, com a depuração USB ligada e o cabo conectado.
3. Redirecione as portas do PC para o celular (o app usa `127.0.0.1`):
   `adb reverse tcp:8787 tcp:8787` · `adb reverse tcp:54321 tcp:54321`
4. Rode: `flutter run --dart-define-from-file=env/dev.json` (o `env/dev.json` local tem `CATALOG_URL` =
   `http://127.0.0.1:8787/` e o endereço do Supabase local).
5. Tenha à mão: 3 livros físicos — um brasileiro antigo (978-85), um lançamento brasileiro (978-65) e um
   estrangeiro — e um produto qualquer com código de barras (caixa de leite, por exemplo).

## Passos

| # | Faça | Tem que acontecer |
|---|---|---|
| 1 | Toque no botão do scanner (meio da barra) | Abre a tela "Escanear livro" por cima das abas; o sistema pede a câmera. **Negue** |
| 2 | — | No cartão: "Câmera sem permissão"; abaixo: "Sem acesso à câmera. Permita a câmera nos ajustes…"; a pílula "Digitar ISBN" funciona |
| 3 | Feche, permita a câmera nos ajustes do Android e abra o scanner de novo | A câmera aparece no cartão com borda e sombra, com a moldura clara no centro |
| 4 | Aponte para o código do produto (não livro) | Aviso "Esse código não é de um livro." e a câmera continua |
| 5 | Aponte para o código do livro brasileiro antigo | Cartão com o título e "Autor · Editora · ano" em menos de 2 s (Wi-Fi) |
| 6 | Toque "Adicionar à estante" | "Adicionado à sua estante." |
| 7 | "Escanear outro" e leia o MESMO livro | "Este livro já está na sua estante." — sem esperar a rede |
| 8 | Leia o livro estrangeiro | Cartão do livro (vem do catálogo aberto) |
| 9 | Toque "Lanterna" | A lanterna acende; toque de novo e apaga (em aparelho sem lanterna a pílula não aparece) |
| 10 | Ligue o **modo avião** e leia o lançamento 978-65 | Se não estiver no catálogo do aparelho: "Sem conexão. Tente de novo…" com "Tentar de novo" e "Digitar os dados" |
| 11 | Desligue o modo avião e toque "Tentar de novo" | Acha pela consulta externa (CBL) ou mostra "Não achamos o ISBN…" |
| 12 | Se não achou: "Ler a capa" e fotografe a capa | Título e autor preenchidos ("Confira o que foi lido da capa…"); corrija se precisar |
| 13 | Sem conta: veja os botões | Só "Adicionar à estante" (o envio à comunidade exige conta) |
| 14 | Entre numa conta (Perfil) com a idade registrada, volte ao passo 12 | Aparece "Adicionar e enviar ao catálogo" com o texto sobre o que é enviado |
| 15 | Toque "Adicionar e enviar ao catálogo" | "Adicionado à sua estante." + "Enviado ao catálogo da comunidade…" |
| 16 | "Digitar ISBN" e digite `85-359-0277-5` → "Buscar" | Acha "Dom Casmurro" (ISBN-10 convertido) |
| 17 | Digite um número errado (`85-359-0277-6`) | "Esse número não é um ISBN válido. Confira os dígitos." |
| 18 | Deixe o app aberto no Wi-Fi por 1 minuto (1ª vez) | O `catalog.db` baixa em segundo plano; depois, com o modo avião, livros populares são achados **sem rede** |

## Se algo falhar

Anote o número do passo e o que apareceu (um print da tela ajuda). Os textos esperados estão em
`docs/design/estados_sem_design.md` (seção G07).
