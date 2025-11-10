# Forgejo

Compose in repo: `Docker Compose/forgejo-compose.yml`

Upstream site/docs: https://forgejo.org/ and https://codeberg.org/forgejo/forgejo

Notes
- Forgejo typically supports PostgreSQL. The compose in this repo is configured to work with a database—inspect env vars like `DB_TYPE`, `DB_HOST`, `DB_NAME`, `DB_USER`, and `DB_PASSWORD` in the compose file.
- I generally used the default compose; when wiring Forgejo to the central PostgreSQL, ensure network and credentials are correct and migrate any existing data with care.
