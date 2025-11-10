# Gethomepage

Compose in repo: `Docker Compose/gethomepage-compose.yml`

Upstream repo/docs: https://github.com/gethomepage/homepage

Notes
- I used the default compose in this repo. Check the service environment variables for database connection settings if applicable.
- If the app supports PostgreSQL and you want it to use the central DB, update the compose env vars to point to the main `postgres` service and credentials.
