-- 001_init.sql — Esquema inicial da base de dados Maluga

CREATE EXTENSION IF NOT EXISTS "citext";

CREATE TABLE IF NOT EXISTS users (
    id            BIGSERIAL PRIMARY KEY,
    name          TEXT NOT NULL,
    email         CITEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    phone         TEXT NOT NULL DEFAULT '',
    nif           TEXT NOT NULL DEFAULT '',
    location      TEXT NOT NULL DEFAULT '',
    role          TEXT NOT NULL DEFAULT 'owner' CHECK (role IN ('owner', 'renter', 'both')),
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS materials (
    id          BIGSERIAL PRIMARY KEY,
    owner_id    BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name        TEXT NOT NULL,
    description TEXT NOT NULL DEFAULT '',
    quantity    INTEGER NOT NULL DEFAULT 0 CHECK (quantity >= 0),
    status      TEXT NOT NULL DEFAULT 'novo' CHECK (status IN ('novo', 'semi-novo', 'antigo')),
    price       REAL NOT NULL DEFAULT 0 CHECK (price >= 0),
    image_url   TEXT NOT NULL DEFAULT '',
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_materials_owner    ON materials(owner_id);
CREATE INDEX IF NOT EXISTS idx_materials_name     ON materials(name);
CREATE INDEX IF NOT EXISTS idx_materials_status   ON materials(status);
CREATE INDEX IF NOT EXISTS idx_materials_price    ON materials(price);

CREATE TABLE IF NOT EXISTS rentals (
    id          BIGSERIAL PRIMARY KEY,
    owner_id    BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    renter_id   BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    material_id BIGINT NOT NULL REFERENCES materials(id) ON DELETE CASCADE,
    quantity    INTEGER NOT NULL DEFAULT 1 CHECK (quantity >= 1),
    start_date  DATE NOT NULL,
    end_date    DATE NOT NULL,
    total       REAL NOT NULL DEFAULT 0,
    status      TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'returned', 'overdue', 'cancelled')),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CHECK (end_date >= start_date)
);

CREATE INDEX IF NOT EXISTS idx_rentals_owner    ON rentals(owner_id);
CREATE INDEX IF NOT EXISTS idx_rentals_renter   ON rentals(renter_id);
CREATE INDEX IF NOT EXISTS idx_rentals_material ON rentals(material_id);
CREATE INDEX IF NOT EXISTS idx_rentals_status   ON rentals(status);

CREATE TABLE IF NOT EXISTS conversations (
    id          BIGSERIAL PRIMARY KEY,
    material_id BIGINT NOT NULL REFERENCES materials(id) ON DELETE CASCADE,
    owner_id    BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    renter_id   BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(material_id, renter_id)
);

CREATE INDEX IF NOT EXISTS idx_conversations_owner  ON conversations(owner_id);
CREATE INDEX IF NOT EXISTS idx_conversations_renter ON conversations(renter_id);

CREATE TABLE IF NOT EXISTS messages (
    id              BIGSERIAL PRIMARY KEY,
    conversation_id BIGINT NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    sender_id       BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content         TEXT NOT NULL,
    read            BOOLEAN NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_messages_conversation ON messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_messages_sender       ON messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_messages_read         ON messages(read);

CREATE TABLE IF NOT EXISTS sync_log (
    id         BIGSERIAL PRIMARY KEY,
    device_id  TEXT NOT NULL,
    table_name TEXT NOT NULL,
    record_id  BIGINT NOT NULL,
    action     TEXT NOT NULL CHECK (action IN ('insert', 'update', 'delete')),
    synced_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_sync_log_device ON sync_log(device_id);
