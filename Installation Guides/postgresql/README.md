# PostgreSQL & pgAdmin

Compose in repo: `Docker Compose/postgresql-compose.yml`

PostgreSQL docs: https://www.postgresql.org/docs/
pgAdmin: https://www.pgadmin.org/

Notes
- This repository uses a central PostgreSQL instance for apps that support it. The compose file in `Docker Compose/postgresql-compose.yml` includes the PostgreSQL service and pgAdmin for web UI access.
- Use pgAdmin to manage databases, users, and roles. Check the compose file for the initial admin credentials and any exposed ports.
- When connecting apps to this PostgreSQL instance, verify the expected env var names used by each app (examples: `DATABASE_URL`, `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`).

Security note: avoid committing plaintext credentials to the repo. Use environment files, Docker secrets, or a secrets manager when possible.
