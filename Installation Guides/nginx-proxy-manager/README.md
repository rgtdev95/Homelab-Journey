# Nginx Proxy Manager

Compose in repo: `Docker Compose/npm-compose.yml`

Upstream docs/repo: https://github.com/jc21/nginx-proxy-manager

Notes
- I used the repo's default compose and basic configuration.
- Nginx Proxy Manager handles reverse-proxying and TLS. It typically does not require PostgreSQL, but review the compose file for any persistence volumes and environment values.
- For integration with other apps, ensure the proxy host and network settings in the compose file match your stack.
