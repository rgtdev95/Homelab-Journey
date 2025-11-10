# Ghost

Compose in repo: `Docker Compose/ghost-compose.yml`

Upstream docs: https://ghost.org/docs/

Notes
- Many Ghost setups use MySQL / MariaDB. Check the compose file in this repo to confirm whether the included compose uses MySQL or an alternative database.
- I mostly used the default compose provided here; if Ghost requires a DB, ensure credentials and host match the `postgres` service if you intend to centralize on PostgreSQL (note: Ghost's default is MySQL-compatible DBs).
