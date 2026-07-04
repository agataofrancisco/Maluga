# MalugaAPP

Um aplicativo criado com o objectivo de gerir Materiais em Aluguer, seus alugadores, produtos pagos em prestações e os seus devedores.

## Estrutura do Projecto (Monorepo)

```
MalugaAPP/
├── mobile/          ← App Flutter (offline-first + sync com API)
│   ├── lib/
│   │   ├── Components/      ← Widgets reutilizáveis
│   │   ├── db/              ← SQLite local (offline-first)
│   │   ├── pages/           ← Ecrãs da aplicação
│   │   └── services/        ← Validação de NIF, sync, notificações
│   ├── pubspec.yaml
│   └── ...
├── back/            ← Backend Go (API REST + WebSocket)
│   ├── cmd/server/main.go   ← Ponto de entrada
│   ├── internal/
│   │   ├── config/          ← Configuração (env vars)
│   │   ├── handlers/        ← HTTP handlers (Gin)
│   │   ├── middleware/      ← JWT auth, CORS
│   │   ├── models/          ← Structs de dados
│   │   ├── repositories/    ← Acesso a PostgreSQL (sqlx)
│   │   ├── services/        ← Lógica de negócio
│   │   └── ws/              ← WebSocket para chat em tempo real
│   ├── migrations/          ← SQL migrations
│   ├── go.mod
│   └── .env.example
└── README.md
```

## Stack

| Componente | Tecnologia |
|---|---|
| Mobile | Flutter (Dart) |
| Backend | Go + Gin |
| Base de dados | PostgreSQL |
| Autenticação | JWT + bcrypt |
| Chat | WebSocket (gorilla/websocket) |
| ORM | sqlx (queries SQL manuais) |

## Funcionalidades

- **Gestão de materiais** — CRUD com stock, pesquisa, estados (novo/semi-novo/antigo)
- **Alugueres** — registo com validação de NIF, foto do contrato, prazos
- **Marketplace** — anunciar e procurar materiais para aluguer
- **Chat em tempo real** — conversas entre proprietários e interessados
- **Notificações de prazos** — alertas locais quando a devolução se aproxima ou passa
- **Offline-first** — a app funciona offline e sincroniza quando online

## Como executar

### Backend (back/)

```bash
cd back
cp .env.example .env
# Configurar DATABASE_URL e JWT_SECRET no .env
go run ./cmd/server/
```

### Mobile (mobile/)

```bash
cd mobile
flutter pub get
flutter run
```

## API Endpoints

```
POST   /api/auth/register            ← Registo de utilizador
POST   /api/auth/login               ← Login (devolve JWT)
GET    /api/materials                ← Listar marketplace
GET    /api/materials/:id            ← Detalhe de material
GET    /api/materials/search         ← Procurar materiais
POST   /api/materials                ← Anunciar material (auth)
PUT    /api/materials/:id            ← Editar material (auth)
DELETE /api/materials/:id            ← Remover material (auth)
GET    /api/rentals                  ← Meus alugueres (auth)
POST   /api/rentals                  ← Pedir aluguer (auth)
PATCH  /api/rentals/:id/return       ← Marcar como devolvido (auth)
GET    /api/conversations            ← Minhas conversas (auth)
POST   /api/conversations            ← Iniciar conversa (auth)
GET    /api/conversations/:id/messages ← Mensagens de uma conversa (auth)
GET    /api/ws                       ← WebSocket chat (auth)
```
