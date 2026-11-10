# Roteiro do vídeo (dupla)

Cada integrante precisa **aparecer ou narrar** uma parte identificável. Os dois enviam o mesmo vídeo.
Sugestão: **Pessoa A** cuida do Firebase/painel (notebook) e **Pessoa B** do celular. Troquem a narração no meio para as duas vozes aparecerem.

Antes de gravar:
- Missão **desligada** no Remote Config (`missao_ativa = false`, publicado).
- Painel aberto e logado. Pelo menos 3 estandes cadastrados.
- APK já enviado para o App Distribution e convite enviado ao celular da Pessoa B (ou deixe para gravar o upload ao vivo).
- Uma aba do GA4 aberta em **Relatórios → Tempo real**.

---

## 1. Apresentação e App Distribution (≈ 2 min) — narra Pessoa A, depois Pessoa B

1. **A:** "Somos [nomes]. Este é o Circuito de Descobertas: painel web para a organização e app Flutter para os visitantes, integrados pelo Firebase."
2. **A:** mostra o APK assinado (`app-release.apk`) e o upload no console do **App Distribution**.
3. **A:** adiciona o e-mail da Pessoa B como testador e clica em **Distribuir**.
4. **B:** no celular Android, abre o e-mail do convite, aceita, baixa e instala.
5. **B:** abre o app e mostra a tela inicial com a lista normal, sem missão.

## 2. Cadastro de estande e QR (≈ 1,5 min) — narra Pessoa A

1. No painel, clica em **+ Novo estande** e cadastra um estande fictício (ex.: `E04 – Mapa Verde`, "Corredor D · Estande 2").
2. **B** mostra o celular: o estande novo aparece na lista sozinho.
3. **A** clica em **QR / imprimir** e mostra o QR gerado em outra aba.

## 3. Remote Config e check-in (≈ 3 min) — narra Pessoa B, Pessoa A no console

1. **A:** no Remote Config, muda `missao_ativa` para `true`, confere `missao_estandes` (ex.: `E01,E04`) e clica em **Publicar alterações**.
2. **B:** mostra o mesmo app, sem reinstalar: aparece a chamada da missão e os estandes destacados.
3. **B:** toca na chamada e abre a tela da missão (gera `missao_aberta`).
4. **B:** toca em **Fazer check-in** e lê o QR do `E04` na tela do notebook. Mostra "Check-in concluído!".
5. **A:** mostra o painel: o total do `E04` subiu de 0 para 1 e o cartão pisca.
6. **Extras (rápido):** **B** lê o mesmo QR de novo → "Visita já registrada". **A** desativa um estande e **B** lê o QR dele → "Estande inativo".
7. **A:** muda `missao_ativa` para `false` e publica. **B** mostra o app voltando à lista normal, ainda com o check-in disponível.

## 4. Analytics (≈ 1,5 min) — narra Pessoa A

1. Abre **GA4 → Relatórios → Tempo real**.
2. No cartão **Contagem de eventos por Nome do evento**, mostra `missao_aberta` e `checkin_concluido`.
3. Clica em `checkin_concluido` → `estande_id` e mostra o valor `E04`.
4. Se os eventos ainda não chegaram, pause a gravação e retome quando aparecerem.

## Fechamento (≈ 20 s) — os dois

"O estande cadastrado no painel apareceu no app, o check-in atualizou o total no painel e o evento chegou ao Analytics. Obrigado!"
