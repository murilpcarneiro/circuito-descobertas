# Circuito de Descobertas

Painel web (React + TypeScript) para a organização e app Flutter (Android) para os visitantes, integrados pelo Firebase no plano **Spark** (sem cartão).

```
circuito_descobertas/
├─ painel/            Painel web (Vite + React + TS)
├─ app/               App Flutter do visitante
├─ firestore.rules    Regras de acesso do Firestore
├─ firebase.json      Deploy das regras e (opcional) hospedagem do painel
├─ setup_app.ps1      Gera android/ e conecta o app ao Firebase
└─ build_apk.ps1      Gera o APK de release assinado
```

## Modelo de dados (Firestore)

| Coleção | ID do documento | Campos |
|---|---|---|
| `admins` | UID do administrador | qualquer campo (ex.: `nome`) |
| `estandes` | `E01`, `E02`… | `nome`, `descricao`, `localizacao`, `ativo` |
| `checkins` | `{uidVisitante}_{estandeId}` | `visitanteId`, `estandeId`, `criadoEm` |

O QR code de cada estande contém o texto `circuito:E01`. O app recusa QR sem esse prefixo.

---

## Passo a passo

### 0. Pré-requisitos

- Node.js 20+ e Flutter (já funcionando com Android).
- Firebase CLI: `npm install -g firebase-tools` e depois `firebase login`.

### 1. Criar o projeto Firebase

1. Acesse https://console.firebase.google.com → **Criar projeto** (ex.: `circuito-descobertas`).
2. **Ative o Google Analytics** quando perguntado e crie/escolha uma conta do Analytics.
3. O projeto já nasce no plano Spark. Não informe cartão em nenhum momento.

### 2. Authentication

1. **Authentication → Começar → Método de login**: ative **E-mail/senha** e **Anônimo**.
2. Aba **Usuários → Adicionar usuário**: crie o administrador (ex.: `admin@circuito.dev` + senha). Copie o **UID** gerado.

### 3. Firestore

1. **Firestore Database → Criar banco de dados** → modo **produção** → região `southamerica-east1`.
2. Publique as regras. Escolha uma opção:
   - Console: aba **Regras**, cole o conteúdo de `firestore.rules` e clique em **Publicar**; ou
   - Terminal, na pasta `circuito_descobertas`: `firebase use --add` (escolha o projeto) e depois `firebase deploy --only firestore:rules`.
3. Crie o administrador: **Iniciar coleção** `admins` → ID do documento = **UID do passo 2** → campo `nome` = `Organização`.

### 4. Painel web

1. **Configurações do projeto → Seus apps → Web (`</>`)** → registre o app "Painel". Não marque Hosting agora.
2. Copie `painel/.env.example` para `painel/.env` e preencha com os valores do `firebaseConfig` mostrado.
3. No terminal:
   ```bash
   cd painel
   npm install
   npm run dev
   ```
4. Abra o endereço mostrado (normalmente http://localhost:5173), entre com o admin e clique em **Criar 3 estandes de exemplo** (todos fictícios).

Hospedagem grátis (opcional): `npm run build` dentro de `painel/` e, na raiz, `firebase deploy --only hosting`.

### 5. App Flutter

No PowerShell, na pasta `circuito_descobertas`:

```powershell
.\setup_app.ps1
```

O script gera a pasta `android/`, baixa as dependências e roda o `flutterfire configure` (escolha o mesmo projeto; ele cria `lib/firebase_options.dart`). Se o PowerShell bloquear scripts, rode antes: `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`.

Teste no celular com `cd app` e `flutter run`. A lista de estandes deve aparecer. No emulador, sem câmera, use o ícone de teclado na tela do leitor e digite `circuito:E01`.

### 6. Remote Config (missão surpresa)

**Remote Config → Criar configuração** e adicione:

| Parâmetro | Tipo | Valor padrão no console |
|---|---|---|
| `missao_ativa` | Booleano | `false` |
| `missao_estandes` | String | `E01,E03` |
| `missao_titulo` | String | `Missão surpresa` (opcional) |

Clique em **Publicar alterações**. Para ligar a missão, mude `missao_ativa` para `true` e publique. O app instalado atualiza em alguns segundos, sem reabrir. Para desligar, volte para `false` e publique.

O padrão **local** do app é `missao_ativa = false` (em `lib/services/missao_service.dart`).

### 7. Google Analytics

O app registra:
- `missao_aberta` (parâmetro `qtd_estandes`) ao abrir a tela da missão;
- `checkin_concluido` (parâmetros `estande_id`, `missao_ativa`, `estande_destacado`) após gravar um check-in.

Para ver: **Analytics → Painel** (ou analytics.google.com) → **Relatórios → Tempo real** → cartão **Contagem de eventos por Nome do evento** → clique em `checkin_concluido` → `estande_id`.

Os eventos podem levar alguns minutos para aparecer. Opcional: em **Administrador → Definições personalizadas**, registre `estande_id` como dimensão de escopo de evento para usá-lo também nos relatórios comuns.

### 8. App Distribution (APK assinado)

1. Gere o APK:
   ```powershell
   .\build_apk.ps1
   ```
   O APK sai em `app\build\app\outputs\flutter-apk\app-release.apk`. Ele é assinado: com a sua keystore, se você fizer o passo 9, ou com a chave de debug, caso contrário.
2. Console → **App Distribution** → escolha o app Android → **Começar**.
3. Arraste o `app-release.apk` para a área de upload.
4. Em **Testadores e grupos**, adicione o e-mail do testador (o colega da dupla, por exemplo) e clique em **Distribuir**.
5. No celular Android do testador: abra o e-mail de convite → **Começar** → aceite → baixe e instale o app (permita instalar de fontes desconhecidas se o Android pedir).

### 9. Keystore própria (opcional, recomendado)

No PowerShell (o `keytool` vem com o Android Studio, em `jbr\bin`):

```powershell
cd app\android\app
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Crie `app\android\key.properties`:

```
storePassword=SUA_SENHA
keyPassword=SUA_SENHA
keyAlias=upload
storeFile=upload-keystore.jks
```

O `build.gradle.kts` já está preparado: com esse arquivo presente, o release passa a usar a sua keystore. **Não envie** `key.properties` nem o `.jks` para o Git.

---

## Problemas comuns

| Sintoma | Causa provável |
|---|---|
| Painel mostra "Sem permissão de administrador" | Falta o documento `admins/{UID}` com o UID exato mostrado na tela. |
| App mostra `permission-denied` na lista | Regras não publicadas, ou login anônimo desativado. |
| Missão não muda no app | Esqueceu de clicar em **Publicar alterações** no Remote Config, ou o celular está sem internet. |
| Eventos não aparecem no Tempo real | Espere alguns minutos e use o app instalado pelo App Distribution, não um build de debug do IDE. |
| `flutterfire` não encontrado | Adicione `%LOCALAPPDATA%\Pub\Cache\bin` ao PATH e abra um novo terminal. |
