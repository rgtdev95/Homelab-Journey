# Woodpecker CI

Compose in repo: `Docker Compose/woodpeckerci-compose.yml`

Upstream docs: https://docs.woodpecker-ci.org/

Notes
- The compose here includes both `woodpecker-server` and `woodpecker-agent` services. Woodpecker server uses a database—check the compose/service env vars for DB connection settings.
- I used the default compose. To connect the server to the central PostgreSQL instance, set the appropriate DB env vars in the compose file and confirm the network and credentials.
