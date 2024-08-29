# Docker Compose MySQL DB (LTS)

Docker image base `mysql` [link](https://hub.docker.com/_/mysql/)

## Make sure docker network exist:

```bash
docker network create secure
```

## Makefile commands for run the code

```bash
make help
```

First of all:

-   Init setup env: `make init`
-   Init docker compose env: `make set-env`
-
## Custom environment file

> After first command `make ini` do not change env file on `.make/.env`

> After command `make set-env` can change value of env file on `src/.env`

Running command `make`:

```bash
# Start docker compose
make up
```

```bash
# Stop docker compose
make down
```

```bash
# Check logs docker compose
make logs
```

## MySQL environment variables

You could custom environment of setup database to development or production on `.make/.env`:

```bash
# Development
DOCKER_PROJECT_DEV=true
```

Or

```bash
# Production
DOCKER_PROJECT_DEV=false
```

## Troubleshoot Persisting your data

Now chown this directory to `1001:1001` since the image is using UID `1001` as the user running the command:

```bash
sudo chown -R 1001:1001 .data
```

## Database Management

Optional for database management using Adminer [asapdotid/dcc-adminer](https://github.com/asapdotid/dcc-adminer)

```yaml
---
networks:
    proxy:
        driver: bridge
        external: true
    secure:
        driver: bridge
        external: true

services:
    adminer:
        image: adminer:latest
        restart: unless-stopped
        ports:
            - "8080:8080"
        networks:
            - proxy
            - secure
```

Note:

Connection to database:
- Host: `mysqldb_master`        # MySQL service name
- Username: `root`              # MySQL root user
- Password: `my_S3cret`         # value of `MYSQL_ROOT_PASSWORD`

## Running utility script

```bash
docker exec -i database-mysqldb_master-1 sh -c './tmp/utility-db.sh'
```

## License

MIT / BSD

## Author Information

This Code was created in 2023 by [Asapdotid](https://github.com/asapdotid).
