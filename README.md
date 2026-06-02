# SmartCRM — App + API

Monorepo do projeto de dispositivos móveis.

| Pasta | Descrição |
|-------|-----------|
| `SmartCRM/` | App Flutter (Android/iOS) |
| `CRM-Backend/` | API Node.js + Prisma + MySQL |

## Backend

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
