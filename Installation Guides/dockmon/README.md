# Dockmon

Compose in repo: `Docker Compose/dockmon-compose.yml`

Upstream repo/Docker Hub: https://github.com/darthnorse/dockmon and https://hub.docker.com/r/darthnorse/dockmon

Notes
- Dockmon monitors Docker and typically doesn't require PostgreSQL. I used the default compose in the repo.
- Ensure the monitoring container has access to the Docker socket or required metrics endpoints as configured in the compose file.
