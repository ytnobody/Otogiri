CREATE TABLE member (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    name       TEXT    NOT NULL,
    age        INTEGER NOT NULL DEFAULT 20,
    sex        TEXT    NOT NULL,
    created_at INTEGER NOT NULL,
    updated_at INTEGER
);

