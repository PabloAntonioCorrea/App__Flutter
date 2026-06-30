# SmartCRM — App + API

Monorepo do projeto de dispositivos móveis.

| Pasta | Descrição |
|-------|-----------|
| `SmartCRM/` | App Flutter (Android/iOS) |
| `CRM-Backend/` | API Node.js + Prisma + MySQL |

## Backend

### Com Docker (recomendado)

```powershell
cd CRM-Backend
npm run docker:up
npm run docker:seed
```

API em `http://localhost:3333`.

### Sem Docker

```powershell
cd CRM-Backend
copy .env.example .env
npm install
npm run db:migrate
npm run db:seed
npm run dev
```

API em `http://localhost:3333`.

## App Flutter

```powershell
cd SmartCRM
flutter pub get
flutter run
```

Dispositivo físico (mesma rede que o PC com a API):

```powershell
flutter run --dart-define=API_URL=http://SEU_IP:3333
```

Detalhes em `SmartCRM/README.md` e `CRM-Backend/README.md`.
