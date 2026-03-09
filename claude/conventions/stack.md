---
keywords: [stack, project, scaffold, bootstrap]
scope: bootstrap
---
# Stack

> Project skeleton: language, framework, build system, infrastructure, and startup.

## Language & Framework

Java (latest LTS) with Spring Boot (latest stable). Use Gradle as the build tool with the `java`, `org.springframework.boot`, and `io.spring.dependency-management` plugins.

## Dependencies

Organise dependencies by configuration:

- **implementation** — spring-boot-starter-web, spring-boot-starter-data-jpa, spring-boot-starter-security, spring-boot-starter-thymeleaf, spring-boot-starter-actuator, micrometer-registry-prometheus, thymeleaf-extras-springsecurity6, liquibase-core
- **compileOnly** — Lombok (with annotation processor)
- **runtimeOnly** — PostgreSQL driver
- **developmentOnly** — spring-boot-docker-compose
- **testImplementation** — spring-boot-starter-test, spring-security-test
- **testRuntimeOnly** — JUnit Platform launcher, H2 (in-memory database for tests)

Configure Lombok so `compileOnly` extends from `annotationProcessor`. Use JUnit Platform for tests.

## Project Structure

Standard Gradle layout with Spring Boot package conventions:

```
<project>/
├── build.gradle
├── settings.gradle           # rootProject.name = '<project-name>'
├── compose.yaml              # see docker-db convention
├── .env.template             # see docker-db convention
├── .gitignore
├── CLAUDE.md                 # generated per project
├── src/main/java/<group-path>/<artifact>/
│   ├── <ArtifactName>Application.java    # @SpringBootApplication entry point
│   ├── config/
│   ├── controller/
│   ├── dto/
│   ├── model/
│   ├── repository/
│   └── service/
├── src/main/resources/
│   ├── application.properties
│   ├── db/changelog/                     # see migration convention
│   ├── static/css/main.css
│   └── templates/                        # see templates convention
└── src/test/
    ├── java/<group-path>/<artifact>/
    │   └── <ArtifactName>ApplicationTests.java   # @SpringBootTest context load
    └── resources/
        └── application.properties                # test overrides
```

Derive the artifact name from the project name: lowercase, hyphens removed for the package segment. Example: `recipe-box` → package segment `recipebox`.

## Configuration

- `application.properties` — app name, database connection (with `${ENV_VAR:default}` placeholders), JPA validate mode, Liquibase changelog path, Actuator endpoints. See the docker-db convention for database-specific config.
- Test `application-test.properties` — disable Docker Compose, use H2 in-memory database with PostgreSQL compatibility mode, `ddl-auto=none`, Liquibase **enabled** (validates migrations and provides seed data). See testing convention for full config. Tests should pass without Docker or PostgreSQL.

## Build Wrapper

Run `gradle wrapper` after generating the build file to create the Gradle wrapper scripts.

## Gitignore

Ignore: Gradle build dirs (`.gradle/`, `build/`), IDE files (`.idea/`, `*.iml`, `.vscode/`, `.classpath`, `.project`, `.settings/`), `.env`, `bin/`, `out/`.

## Startup

- **Run:** `./gradlew bootRun` — starts the app; Docker containers start automatically via spring-boot-docker-compose.
- **Test:** `./gradlew test` — runs against in-memory H2, no Docker required.
- **Verify:** App should start, database migrations should run, and the home page should load.
