# Docker & Database Conventions

> How to set up local development with Docker Compose, PostgreSQL, and Spring Boot configuration.

## Rules

- `compose.yaml` (not `docker-compose.yml`) with PostgreSQL using the `latest` image.
- Environment variables for `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`.
- Named volume for data persistence (named after the project database).
- Port 5432 exposed to host.
- `.env.template` provides default values for both Docker and Spring Boot — copy to `.env` for local use.
- `application.properties` uses `${ENV_VAR:default}` placeholders for all database connection values.
- Spring Boot `spring-boot-docker-compose` as a `developmentOnly` dependency — this enables zero-friction dev startup: `./gradlew bootRun` automatically detects `compose.yaml`, starts the Docker containers (PostgreSQL), waits for readiness, and stops them when the app shuts down. No separate `docker compose up` step needed for development.
- JPA/Hibernate set to `ddl-auto=validate` — Liquibase owns the schema.
- SQL logging enabled for development: `show-sql=true`, `format_sql=true`.
- Liquibase changelog path: `classpath:db/changelog/db.changelog-master.yaml`.
- Actuator + Prometheus: `spring-boot-starter-actuator` and `micrometer-registry-prometheus` are included from the start. Expose the Prometheus endpoint in `application.properties`:
  - `management.endpoints.web.exposure.include=health,info,prometheus`
  - `management.endpoint.prometheus.enabled=true`
  - `management.metrics.export.prometheus.enabled=true`
- Error pages: whitelabel disabled, stacktrace hidden, message included.
- File upload defaults: 10MB max file size, 10MB max request size.
- `.gitignore` must include `.env` to prevent credentials from being committed.

## Example

### compose.yaml

```yaml
services:
  postgres:
    image: 'postgres:latest'
    environment:
      - 'POSTGRES_DB=myapp_db'
      - 'POSTGRES_PASSWORD=secret'
      - 'POSTGRES_USER=myuser'
    ports:
      - '5432:5432'
    volumes:
      - myapp_db:/var/lib/postgresql/data

volumes:
  myapp_db:
```

### .env.template

```bash
# Database Configuration for local development
# Copy this file to .env and customize as needed

# PostgreSQL Docker container settings
POSTGRES_DB=myapp_db
POSTGRES_USER=myuser
POSTGRES_PASSWORD=secret

# Spring Boot database connection settings
SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/myapp_db
SPRING_DATASOURCE_USERNAME=myuser
SPRING_DATASOURCE_PASSWORD=secret
```

### application.properties

```properties
spring.application.name=myapp

# Database Configuration
spring.datasource.url=${SPRING_DATASOURCE_URL:jdbc:postgresql://localhost:5432/myapp_db}
spring.datasource.username=${SPRING_DATASOURCE_USERNAME:myuser}
spring.datasource.password=${SPRING_DATASOURCE_PASSWORD:secret}
spring.datasource.driver-class-name=org.postgresql.Driver

# JPA/Hibernate Configuration
spring.jpa.hibernate.ddl-auto=validate
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.PostgreSQLDialect

# Liquibase Configuration
spring.liquibase.change-log=classpath:db/changelog/db.changelog-master.yaml

# Error Page Configuration
server.error.whitelabel.enabled=false
server.error.include-stacktrace=never
server.error.include-message=always

# Actuator & Prometheus
management.endpoints.web.exposure.include=health,info,prometheus
management.endpoint.prometheus.enabled=true
management.metrics.export.prometheus.enabled=true

# File Upload Configuration
spring.servlet.multipart.max-file-size=10MB
spring.servlet.multipart.max-request-size=10MB
spring.servlet.multipart.enabled=true
```
