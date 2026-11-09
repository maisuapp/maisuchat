# MaisuChat

Plataforma web de automação de mensagens inspirada no ManyChat, com base preparada para WhatsApp, Firebase e respostas assistidas por IA.

## O que foi corrigido

- Firebase Web deixou de inicializar sem configuração e agora existe um modo demonstração explícito para desenvolvimento.
- O frontend ganhou shell responsivo, navegação real, estados vazios/erro, feedback de ações e autenticação por e-mail quando o Firebase estiver configurado.
- O Firebase Hosting agora publica o artefato correto do Flutter (`frontend/build/web`) e mantém o fallback de SPA.
- API Node passou a ter configuração tolerante a ambiente local, CORS por allowlist, health check observável, tratamento de erros e inicialização testável.
- Webhook Twilio ganhou validação opcional/segura de assinatura e idempotência por `MessageSid`.
- Serviço de IA não derruba a aplicação quando a chave está ausente; responde `503` de forma explícita e usa o SDK atual `google-genai`.

Os arquivos `manychat_replica_design.md` e `ManyChat Replica – Detailed Compone.txt` são especificações de produto/arquitetura fornecidas como referência. Eles não são executados automaticamente e não substituem os contratos existentes no código.

## Estrutura

```text
MaisuChat/
├─ frontend/      # Flutter Web (UI responsiva)
├─ backend/       # API Node/Express
├─ ai_service/    # FastAPI + Gemini
├─ firebase/      # Cloud Functions e regras de integração
├─ firebase.json
└─ README.md
```

## Frontend local

O modo demonstração funciona sem credenciais e permite revisar a experiência:

```bash
cd frontend
# Execute uma vez se a pasta `web/` ainda não existir neste checkout.
flutter create . --platforms web
flutter pub get
flutter run -d chrome
```

Para conectar o Firebase Web, passe os valores da configuração como `--dart-define` (não commite chaves de ambiente):

```bash
flutter run -d chrome \
  --dart-define=FIREBASE_API_KEY="..." \
  --dart-define=FIREBASE_APP_ID="..." \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID="..." \
  --dart-define=FIREBASE_PROJECT_ID="..." \
  --dart-define=FIREBASE_AUTH_DOMAIN="..." \
  --dart-define=FIREBASE_STORAGE_BUCKET="..." \
  --dart-define=FIREBASE_MEASUREMENT_ID="..."
```

O `firebase_core` deve ser inicializado com uma configuração gerada pelo projeto Firebase/FlutterFire. A configuração via `--dart-define` mantém os ambientes de desenvolvimento e produção separados; os identificadores web não são segredos, mas continuam fora do código versionado.

## Build e publicação

```bash
cd frontend
flutter pub get
flutter build web --release --dart-define=FIREBASE_API_KEY="..." --dart-define=FIREBASE_APP_ID="..." --dart-define=FIREBASE_MESSAGING_SENDER_ID="..." --dart-define=FIREBASE_PROJECT_ID="..." --dart-define=FIREBASE_AUTH_DOMAIN="..." --dart-define=FIREBASE_STORAGE_BUCKET="..."

cd ..
firebase deploy --only hosting
```

O projeto precisa estar autenticado no Firebase CLI e associado a um projeto por `.firebaserc` ou `firebase use`.

## API Node (Node 22+)

```bash
cd backend
npm install
npm start
```

Variáveis úteis:

- `PORT` — porta HTTP, padrão `3000`.
- `CORS_ORIGINS` — origens separadas por vírgula; em produção, informe somente o domínio do frontend.
- `FIREBASE_PROJECT_ID` e credenciais do ambiente — habilitam o Admin SDK/Firestore.

Endpoints básicos: `GET /health` e `GET /api/info`.

Para publicar as Cloud Functions após configurar o Firebase:

```bash
cd firebase/functions
npm install
cd ../..
firebase deploy --only functions
```

## Serviço de IA (Python 3.10+)

```bash
cd ai_service
python -m venv .venv
python -m pip install -r requirements.txt
set GEMINI_API_KEY=...
uvicorn main:app --reload --port 8000
```

Sem `GEMINI_API_KEY`, o serviço ainda inicia para que o health check e o restante do ambiente possam ser testados; `POST /generate` retorna `503` até a chave ser configurada.

## Limites atuais

O repositório ainda não contém o editor visual de fluxos, regras Firestore, esquema multi-tenant ou integração completa com a API do WhatsApp. A interface corrigida é uma base navegável e responsiva para esses módulos, não uma implementação completa da especificação de arquitetura.
