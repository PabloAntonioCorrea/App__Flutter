# CRM API

Backend Node.js com Prisma e MySQL (`crm_integrador`).

## Pré-requisitos

- **Docker (recomendado):** Docker Desktop
- **Sem Docker:** Node.js 20+ e MySQL local

## Subir com Docker (recomendado)

Na pasta `CRM-Backend`:

```powershell
npm run docker:up
npm run docker:seed
```

| Serviço | URL / porta |
|---------|-------------|
| API | `http://localhost:3333` |
| MySQL (host) | `localhost:3307` |

Teste:

```powershell
irm http://localhost:3333/health
```

Login (após o seed):

```powershell
$body = @{ email = 'pablo@empresa.com'; senha = '123456' } | ConvertTo-Json
irm http://localhost:3333/auth/login -Method POST -Body $body -ContentType 'application/json'
```

Comandos Docker:

| Comando | O que faz |
|---------|-----------|
| `npm run docker:up` | Sobe MySQL + API (build + migrations automáticas) |
| `npm run docker:seed` | Popula dados de teste |
| `npm run docker:logs` | Logs da API |
| `npm run docker:down` | Para os containers |

O emulador Android continua usando `http://10.0.2.2:3333` (porta 3333 exposta no host).

## Configuração manual (sem Docker)

1. Copie o arquivo de ambiente:

```powershell
cd CRM-Backend
copy .env.example .env
```

2. Edite o `.env` e coloque seu usuário e senha do MySQL:

```env
DATABASE_URL="mysql://root:SUA_SENHA@localhost:3306/crm_integrador"
PORT=3333
```

3. Instale dependências:

```powershell
npm install
```

## Banco de dados (Prisma)

| Arquivo / pasta | Função |
|-----------------|--------|
| `prisma/schema.prisma` | Modelo atual das tabelas |
| `prisma/migrations/` | Histórico de alterações (fonte oficial do schema) |
| `prisma/seed.js` | Dados iniciais de desenvolvimento |

## Criar tabelas (migration)

No terminal do VS Code, dentro de `CRM-Backend`:

```powershell
npm run db:migrate
```

Isso aplica todas as migrations em `prisma/migrations/` no schema `crm_integrador`. Confira no MySQL Workbench em **Tables**.

## Popular dados (seed)

```powershell
npm run db:seed
```

Usuários de teste com senha: `123456`

## Subir a API

```powershell
npm run dev
```

Teste:

```powershell
irm http://localhost:3333/health
irm http://localhost:3333/leads
irm http://localhost:3333/usuarios
```

Login (seed):

```powershell
$body = @{ email = 'pablo@empresa.com'; senha = '123456' } | ConvertTo-Json
irm http://localhost:3333/auth/login -Method POST -Body $body -ContentType 'application/json'
```

## Endpoints

| Método | Rota | Descrição |
|--------|------|-----------|
| POST | `/auth/login` | Login |
| GET | `/leads` | Listar leads |
| GET | `/leads/:id` | Buscar lead |
| POST | `/leads` | Criar lead |
| PUT | `/leads/:id` | Atualizar lead |
| DELETE | `/leads/:id` | Excluir lead |
| GET | `/usuarios` | Listar usuários |

## Comandos úteis

| Comando | O que faz |
|---------|-----------|
| `npm run db:migrate` | Aplica migrations (cria/altera tabelas) |
| `npm run db:seed` | Insere dados iniciais |
| `npm run db:studio` | Interface visual do Prisma |
| `npm run dev` | API em modo desenvolvimento |
