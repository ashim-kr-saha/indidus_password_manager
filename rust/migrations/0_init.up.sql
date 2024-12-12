CREATE TABLE IF NOT EXISTS users (
    id TEXT PRIMARY KEY,
    created_at INTEGER NOT NULL,
    created_by TEXT NOT NULL,
    updated_at INTEGER,
    updated_by TEXT,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    role TEXT NOT NULL,
    two_factor_secret TEXT
);

CREATE TABLE  IF NOT EXISTS financial_cards (
    id TEXT PRIMARY KEY,
    created_at INTEGER NOT NULL,
    created_by TEXT NOT NULL,
    updated_at INTEGER,
    updated_by TEXT,
    card_holder_name TEXT NOT NULL,
    card_number TEXT NOT NULL,
    card_provider_name TEXT,
    card_type TEXT,
    cvv TEXT,
    expiry_date TEXT,
    issue_date TEXT,
    name TEXT NOT NULL,
    note TEXT,
    pin TEXT,
    is_favorite BOOLEAN NOT NULL DEFAULT FALSE,
    tags TEXT
);

CREATE TABLE  IF NOT EXISTS identity_cards (
    id TEXT PRIMARY KEY,
    created_at INTEGER NOT NULL,
    created_by TEXT NOT NULL,
    updated_at INTEGER,
    updated_by TEXT,
    name TEXT NOT NULL,
    note TEXT,
    country TEXT,
    expiry_date TEXT,
    identity_card_number TEXT NOT NULL,
    identity_card_type TEXT,
    issue_date TEXT,
    name_on_card TEXT NOT NULL,
    state TEXT,
    is_favorite BOOLEAN NOT NULL DEFAULT FALSE,
    tags TEXT
);

CREATE TABLE  IF NOT EXISTS logins (
    id TEXT PRIMARY KEY,
    created_at INTEGER NOT NULL,
    created_by TEXT NOT NULL,
    updated_at INTEGER,
    updated_by TEXT,
    name TEXT NOT NULL,
    note TEXT,
    username TEXT NOT NULL,
    url TEXT,
    password TEXT,
    password_hint TEXT,
    is_favorite BOOLEAN NOT NULL DEFAULT FALSE,
    tags TEXT,
    api_keys TEXT
);

CREATE TABLE  IF NOT EXISTS notes (
    id TEXT PRIMARY KEY,
    created_at INTEGER NOT NULL,
    created_by TEXT NOT NULL,
    updated_at INTEGER,
    updated_by TEXT,
    name TEXT NOT NULL,
    note TEXT NOT NULL,
    is_favorite BOOLEAN NOT NULL DEFAULT FALSE,
    tags TEXT
);

CREATE TABLE IF NOT EXISTS tags (
    id TEXT PRIMARY KEY,
    created_at INTEGER NOT NULL,
    created_by TEXT NOT NULL,
    updated_at INTEGER,
    updated_by TEXT,
    name TEXT NOT NULL,
    UNIQUE (created_by, name)
);
