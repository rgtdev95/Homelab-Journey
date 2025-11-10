# Portainer

Compose in repo: `Docker Compose/portainer-compose.yml`

Upstream docs: https://docs.portainer.io/

Notes
- I used the default Portainer docker-compose from this repo with minimal changes.
- Portainer is a UI for managing Docker; it does not require PostgreSQL itself, but can be used to view and manage containers that do.
- Check the compose file before changing volumes or bind mounts.

If you want to manage Portainer itself (backups, restoring data), see the upstream docs linked above.
