# Installation Guides

This folder contains per-application installation notes for the apps in this repository. For each app you'll find:

- the path to the Docker Compose file used in this repo
- a link to upstream documentation / downloads
- short notes about how I deployed it (mostly default compose)

Common notes

- I create a separate folder for each application and keep a small README with the link to the compose file and upstream docs.
- Most apps were deployed using the default Docker Compose setups from the upstream projects or minimal adjustments.
- A single, central PostgreSQL instance (see the PostgreSQL guide) is used by multiple apps where applicable. pgAdmin is available as the web UI for managing the database.
- Always inspect the compose file in the repo for environment variables (DB host, user, password, connection URLs) before changing credentials or connecting services.

Per-app guides

- [Portainer](./portainer/README.md)
- [Nginx Proxy Manager](./nginx-proxy-manager/README.md)
- [Ghost](./ghost/README.md)
- [Gethomepage](./gethomepage/README.md)
- [Forgejo](./forgejo/README.md)
- [DocMost](./docmost/README.md)
- [Dockmon](./dockmon/README.md)
- [Coder](./coder/README.md)
- [PostgreSQL & pgAdmin](./postgresql/README.md)
- [Vaultwarden](./vaultwarden/README.md)
- [Woodpecker CI](./woodpeckerci/README.md)

If you need a walkthrough for wiring secrets, network settings, or example env files for a specific app, open an issue or request a guide for that app and I'll add it here.