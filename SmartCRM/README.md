# SmartCRM (Flutter)

App mobile do CRM consumindo o `CRM-Backend` (Node.js).

## Pré-requisitos

1. Flutter SDK instalado
2. `CRM-Backend` rodando (`npm run dev` na porta 3333)
3. Banco migrado e com seed (`npm run db:seed`)

## Configurar o projeto Flutter

Na pasta `SmartCRM`:

```powershell
flutter create . --project-name smart_crm
flutter pub get
```

## URL da API

Por padrão: `http://10.0.2.2:3333` (emulador Android).

Dispositivo físico ou iOS:

```powershell
flutter run --dart-define=API_URL=http://SEU_IP:3333
```

## Login de teste (seed)

- Email: `pablo@empresa.com`
- Senha: `123456`

## Telas

1. Login
2. Home (indicadores + navegação)
3. Leads (lista, busca, FAB)
4. Detalhe do lead
5. Cadastro/edição do lead
6. Oportunidades
7. Detalhe da oportunidade (Ganha / Perdida)
8. Cadastro/edição da oportunidade
9. Funil (6 etapas do back, exceto Perdida) — toque abre lista da etapa
10. Relatórios por mês
