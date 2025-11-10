# Vaultwarden

Compose in repo: `Docker Compose/vaultwarden-compose.yml`

Upstream repo/docs: https://github.com/dani-garcia/vaultwarden

Notes
- Vaultwarden stores data and can be configured to use various storage backends. I used the default compose in this repo.
- If you plan to use PostgreSQL as a backend for Vaultwarden, check upstream docs and confirm the compose is configured accordingly. Otherwise, Vaultwarden often uses SQLite by default for small setups.
