# Liquibase Migration Conventions

> How to write database migrations: YAML format, naming, master changelog, and column conventions.

## Rules

- YAML format only — never XML or SQL files.
- File naming: `NNN-description.yaml` with zero-padded sequential numbers (e.g., `001-initial-schema.yaml`, `002-add-seed-users.yaml`).
- All migrations live in `src/main/resources/db/changelog/changes/`.
- Master changelog at `src/main/resources/db/changelog/db.changelog-master.yaml`.
- Master changelog declares a `${now}` property for PostgreSQL: `value: now()`, `dbms: postgresql`.
- Each migration is included in the master via `- include: file: db/changelog/changes/NNN-description.yaml` with `relativeToChangelogFile: false`.
- Primary keys: `BIGINT` with `autoIncrement: true`.
- String columns: `VARCHAR` with explicit length (e.g., `VARCHAR(50)`, `VARCHAR(255)`).
- Timestamps: `TIMESTAMP` type, default `${now}`.
- Always declare `nullable` and `unique` constraints explicitly on every column.
- Boolean columns: `BOOLEAN` type with `defaultValueBoolean`.
- Foreign keys: use `addForeignKeyConstraint` or inline constraints.
- Seed data uses `insert` changesets with a descriptive `id` (e.g., `002-add-initial-users`).
- Seed migrations must include a YAML comment documenting the plaintext password for any BCrypt-hashed values (e.g., `# password: password`). Without this, anyone inheriting the project has to reverse-engineer the hash.
- Hibernate is set to `ddl-auto=validate` — Liquibase is the sole source of truth for the schema.

## Example

### Master changelog

```yaml
databaseChangeLog:
  - property:
      name: now
      value: now()
      dbms: postgresql

  - include:
      file: db/changelog/changes/001-initial-schema.yaml
      relativeToChangelogFile: false
  - include:
      file: db/changelog/changes/002-add-seed-users.yaml
      relativeToChangelogFile: false
```

### Table creation migration

```yaml
databaseChangeLog:
  - changeSet:
      id: 1
      author: liquibase
      changes:
        - createTable:
            tableName: users
            columns:
              - column:
                  name: id
                  type: BIGINT
                  autoIncrement: true
                  constraints:
                    primaryKey: true
                    nullable: false
              - column:
                  name: username
                  type: VARCHAR(50)
                  constraints:
                    nullable: false
                    unique: true
              - column:
                  name: password
                  type: VARCHAR(255)
                  constraints:
                    nullable: false
              - column:
                  name: email
                  type: VARCHAR(100)
                  constraints:
                    nullable: false
                    unique: true
              - column:
                  name: role
                  type: VARCHAR(30)
                  constraints:
                    nullable: false
              - column:
                  name: enabled
                  type: BOOLEAN
                  defaultValueBoolean: true
                  constraints:
                    nullable: false
              - column:
                  name: created_at
                  type: TIMESTAMP
                  defaultValueComputed: ${now}
                  constraints:
                    nullable: false
              - column:
                  name: updated_at
                  type: TIMESTAMP
                  defaultValueComputed: ${now}
                  constraints:
                    nullable: false
```

### Seed data migration

```yaml
databaseChangeLog:
  - changeSet:
      id: 002-add-seed-users
      author: system
      changes:
        # Seed accounts for local development. All passwords: "password"
        - insert:
            tableName: users
            columns:
              - column:
                  name: username
                  value: admin
              - column:
                  name: password
                  # password: password
                  value: $2a$10$YtVD5E/I48nYpnwyyWWezuVQPOqdKmDa8lux3ZuXehwhCrxlfvo.q
              - column:
                  name: email
                  value: admin@starter.com
              - column:
                  name: role
                  value: ADMIN
              - column:
                  name: enabled
                  valueBoolean: 'true'
```
