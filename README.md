# Homelab-Journey
repo for my homelab infrastructure

# Applications included

This repository contains Docker Compose setups for the following apps. Each entry links to the compose file in this repo and the upstream documentation/download page.

- [`portainer`](Docker Compose/portainer-compose.yml) — Portainer (UI for managing Docker)
  - Docs: https://docs.portainer.io/
  - Compose: [Docker Compose/portainer-compose.yml](Docker Compose/portainer-compose.yml)

- [`nginx_proxy_manager`](Docker Compose/npm-compose.yml) — Nginx Proxy Manager
  - Docs/Repo: https://github.com/jc21/nginx-proxy-manager
  - Compose: [Docker Compose/npm-compose.yml](Docker Compose/npm-compose.yml)

- [`ghost`](Docker Compose/ghost-compose.yml) — Ghost (publishing platform)
  - Docs: https://ghost.org/docs/
  - Compose: [Docker Compose/ghost-compose.yml](Docker Compose/ghost-compose.yml)

- [`homepage`](Docker Compose/gethomepage-compose.yml) — Gethomepage
  - Repo/Docs: https://github.com/gethomepage/homepage
  - Compose: [Docker Compose/gethomepage-compose.yml](Docker Compose/gethomepage-compose.yml)

- [`server`](Docker Compose/forgejo-compose.yml) — Forgejo (Gitea fork)
  - Site/Docs: https://forgejo.org/ and https://codeberg.org/forgejo/forgejo
  - Compose: [Docker Compose/forgejo-compose.yml](Docker Compose/forgejo-compose.yml)

- [`docmost`](Docker Compose/docmost-compose.yml) — DocMost (documentation platform)
  - Repo/Docs: https://github.com/docmosthq/docmost
  - Compose: [Docker Compose/docmost-compose.yml](Docker Compose/docmost-compose.yml)

- [`dockmon`](Docker Compose/dockmon-compose.yml) — Dockmon (Docker monitor)
  - Repo/Docker Hub: https://github.com/darthnorse/dockmon and https://hub.docker.com/r/darthnorse/dockmon
  - Compose: [Docker Compose/dockmon-compose.yml](Docker Compose/dockmon-compose.yml)

- [`coder`](Docker Compose/coder-compose.yml) — Coder (developer environments)
  - Docs/Repo: https://coder.com/docs and https://github.com/coder/coder
  - Compose: [Docker Compose/coder-compose.yml](Docker Compose/coder-compose.yml)

- [`postgres`](Docker Compose/postgresql-compose.yml) & [`pgadmin`](Docker Compose/postgresql-compose.yml) — PostgreSQL and pgAdmin
  - PostgreSQL Docs: https://www.postgresql.org/docs/
  - pgAdmin: https://www.pgadmin.org/
  - Compose: [Docker Compose/postgresql-compose.yml](Docker Compose/postgresql-compose.yml)

- [`vaultwarden`](Docker Compose/vaultwarden-compose.yml) — Vaultwarden (Bitwarden-compatible server)
  - Repo/Docs: https://github.com/dani-garcia/vaultwarden
  - Compose: [Docker Compose/vaultwarden-compose.yml](Docker Compose/vaultwarden-compose.yml)

- [`woodpecker-server`](Docker Compose/woodpeckerci-compose.yml) & [`woodpecker-agent`](Docker Compose/woodpeckerci-compose.yml) — Woodpecker CI
  - Docs: https://docs.woodpecker-ci.org/
  - Compose: [Docker Compose/woodpeckerci-compose.yml](Docker Compose/woodpeckerci-compose.yml)

# Guides
- Installation notes (in-progress): [Installation Guides/readme.md](Installation Guides/readme.md)
