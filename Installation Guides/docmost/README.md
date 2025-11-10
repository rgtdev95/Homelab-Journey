# DocMost

Compose in repo: `Docker Compose/docmost-compose.yml`

Upstream repo/docs: https://github.com/docmosthq/docmost

Notes
- I used the default compose in this repo. DocMost's storage/DB requirements are defined in its compose—check whether it expects PostgreSQL and set environment values accordingly.
- If you connect DocMost to the central PostgreSQL instance, confirm DB credentials and the expected schema.
