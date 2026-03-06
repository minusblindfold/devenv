---
name: bootstrap
description: Scaffold a complete Spring Boot project from scratch following personal conventions. Use when the user wants to start a new project.
argument-hint: "<project-name> [description]"
allowed-tools: Read Write Bash
---

Scaffold a full Spring Boot project from a name, description, and domain role.

## Config

Read `~/.claude/devenv.json`. Key: `work.dir` (default `.work`).

## Gather inputs

1. Parse `$ARGUMENTS` for the project name (first word) and optional description (rest). If no project name, ask.
2. Ask for any missing inputs. Wait for answers before generating.
   - **Description**: one sentence — what the app does and why. (Skip if provided in arguments.)
   - **Domain role name**: the non-admin role (default: USER). Examples: PLAYER, COOK, MEMBER.
   - **Group ID**: Maven/Gradle group (default: com.personal).
3. Derive the **artifact name** from the project name (lowercase, hyphens removed for package). Example: `recipe-box` → package segment `recipebox`.
4. Confirm inputs with the user before generating.

## Read conventions

Read all convention docs from `~/.claude/skills/conventions/`:
- `entity.md`, `repository.md`, `service.md`, `controller.md`, `migration.md`, `templates.md`, `security.md`, `docker-db.md`

These define every pattern used below. Follow them exactly.

## Generate project

Create all files in the **current working directory**. The directory should be empty or near-empty.

### Build & config

- `build.gradle` — Plugins: `java`, `org.springframework.boot` (latest stable), `io.spring.dependency-management` (latest stable). Java toolchain: latest LTS. Dependencies:
  - `compileOnly 'org.projectlombok:lombok'`
  - `annotationProcessor 'org.projectlombok:lombok'`
  - `runtimeOnly 'org.postgresql:postgresql'`
  - `implementation`: spring-boot-starter-web, spring-boot-starter-data-jpa, spring-boot-starter-security, spring-boot-starter-thymeleaf, spring-boot-starter-actuator, micrometer-registry-prometheus, thymeleaf-extras-springsecurity6, liquibase-core
  - `developmentOnly 'org.springframework.boot:spring-boot-docker-compose'`
  - `testImplementation`: spring-boot-starter-test, spring-security-test
  - `testRuntimeOnly 'org.junit.platform:junit-platform-launcher'`
  - Lombok `compileOnly { extendsFrom annotationProcessor }` config. JUnit Platform for tests.
- `settings.gradle` — `rootProject.name = '<project-name>'`
- `compose.yaml` — per `docker-db.md`. Database name: `<project-name>_db` (hyphens replaced with underscores).
- `.env.template` — per `docker-db.md`. Matching database name.
- `src/main/resources/application.properties` — per `docker-db.md`. App name set. Matching database name in defaults.
- `.gitignore` — Gradle build dirs, IDE files (.idea, *.iml, .vscode, .classpath, .project, .settings), .env, bin/, out/, build/.

### Gradle wrapper

Run `gradle wrapper` to generate the wrapper files. If `gradle` is not installed, stop and tell the user: "Install Gradle via `brew install gradle` or SDKMAN (`sdk install gradle`), then re-run `/bootstrap`." The wrapper is required — `./gradlew bootRun` won't work without it.

### Main application class

- `src/main/java/<group-path>/<artifact>/<ArtifactName>Application.java` — Standard `@SpringBootApplication` with `main` method.

### Model layer (per `entity.md`, `security.md`)

- `model/Role.java` — Enum: `ADMIN`, `<DOMAIN_ROLE>`.
- `model/User.java` — Per `entity.md` conventions. Fields: id, username, password, email, role, enabled, createdAt, updatedAt. No relationship fields at bootstrap (those come with features). Full custom equals/hashCode.

### DTO layer

- `dto/UserRegistrationDto.java` — `@Data @Builder @NoArgsConstructor @AllArgsConstructor`. Fields: username, email, password, confirmPassword.

### Repository layer

- `repository/UserRepository.java` — `JpaRepository<User, Long>` with `@Repository`. Methods: `findByUsername(String)` returning `Optional<User>`, `existsByUsernameIgnoreCase(String)`, `existsByEmailIgnoreCase(String)`.

### Service layer (per `service.md`, `security.md`)

- `service/UserService.java` — Interface with JavaDoc. Methods: createUser, findByUsername, findById, save, isUsernameTaken, isEmailRegistered.
- `service/UserServiceImpl.java` — Per `service.md`. Validation in private `validateRegistrationInput()`. BCrypt encoding. Lowercase normalization.
- `service/CustomUserDetailsService.java` — Per `security.md`. Maps Role to ROLE_ authority.

### Config layer (per `security.md`)

- `config/SecurityConfig.java` — Per `security.md`. Routes: `/admin/**` → ADMIN, `/<lowercase-domain-role>/**` → domain role. Public routes for home, register, static assets.

### Controller layer (per `controller.md`, `security.md`)

- `controller/common/DashboardController.java` — Per `security.md`. Role-based redirect. Use `@Controller("commonDashboardController")`.
- `controller/common/auth/AuthController.java` — Home, login, register (GET + POST). Per `security.md` registration pattern.
- `controller/common/error/CustomErrorController.java` — HTML + JSON error handling. Status-specific templates (403, 404, 500).
- `controller/common/GlobalControllerAdvice.java` — `@ControllerAdvice` stub with `@RequiredArgsConstructor`. Add a placeholder `@ModelAttribute` method (can be expanded later).
- `controller/admin/DashboardController.java` — Stub: `@Controller("adminDashboardController")`, `@RequestMapping("/admin/dashboard")`, single `@GetMapping` returning `"admin/dashboard"`.
- `controller/<lowercase-domain-role>/DashboardController.java` — Stub: same pattern for the domain role.

### Database migrations (per `migration.md`)

- `src/main/resources/db/changelog/db.changelog-master.yaml` — Master changelog with `${now}` property, includes 001 and 002.
- `src/main/resources/db/changelog/changes/001-initial-schema.yaml` — Users table matching the User entity.
- `src/main/resources/db/changelog/changes/002-add-seed-users.yaml` — Admin user + domain role user. Both with BCrypt hash of "password": `$2a$10$YtVD5E/I48nYpnwyyWWezuVQPOqdKmDa8lux3ZuXehwhCrxlfvo.q`. Include a YAML comment documenting the plaintext password per `migration.md` convention.

### Templates (per `templates.md`)

- `src/main/resources/templates/home.html` — Landing page with login form and hero section. Links to register. Shows dashboard link if authenticated.
- `src/main/resources/templates/common/auth/login.html` — Login form page.
- `src/main/resources/templates/common/auth/register.html` — Registration form with username, email, password, confirm password.
- `src/main/resources/templates/admin/dashboard.html` — Simple admin dashboard stub.
- `src/main/resources/templates/<role>/dashboard.html` — Simple domain role dashboard stub.
- `src/main/resources/templates/error/403.html` — Forbidden error page.
- `src/main/resources/templates/error/404.html` — Not found error page.
- `src/main/resources/templates/error/500.html` — Server error page.
- `src/main/resources/templates/error/error.html` — Generic error page.
- `src/main/resources/templates/fragments/common/head.html` — Common head fragment with Bootstrap CSS/JS CDN, FontAwesome CDN, custom CSS link.
- `src/main/resources/templates/fragments/navbar/navbar.html` — Main navbar dispatcher per `templates.md`.
- `src/main/resources/templates/fragments/navbar/base.html` — Dashboard link for authenticated users.
- `src/main/resources/templates/fragments/navbar/admin.html` — Admin nav items (Users, etc.).
- `src/main/resources/templates/fragments/navbar/<role>.html` — Domain role nav items (placeholder).
- `src/main/resources/templates/fragments/footer/footer.html` — Simple footer.

### Static assets

- `src/main/resources/static/css/main.css` — Minimal custom styles: body background, dashboard-header styling, hero section. Keep it simple — enough to look presentable.

### Project documentation

- `CLAUDE.md` — Tailored to the generated project. Include:
  - Project overview (name, description, tech stack).
  - Common commands (build, run, test, docker).
  - Architecture overview (layer structure, security config, database schema, frontend tech).
  - Key implementation notes (entity best practices, testing).

### Test placeholder

- `src/test/java/<group-path>/<artifact>/<ArtifactName>ApplicationTests.java` — Standard `@SpringBootTest` context load test.

## Write bootstrap context marker

Create `<work.dir>/bootstrap.md` in the project directory:

```markdown
# Bootstrap Context

## Tech Stack
- Spring Boot (Gradle)
- PostgreSQL + Docker Compose
- Spring Security (form login)
- Thymeleaf + Bootstrap 5
- Liquibase migrations

## Roles
- ADMIN
- <DOMAIN_ROLE>

## Scaffolded Entities
- User (username, password, email, role, enabled, audit timestamps)

## What's Ready
- Full auth flow (login, register, logout)
- Role-based route protection and dashboard redirect
- Error pages (403, 404, 500)
- Thymeleaf fragment structure (head, navbar per role, footer)
- Liquibase master changelog with initial schema + seed users
- Docker Compose local dev environment

## Convention Docs Applied
All conventions from ~/.claude/skills/conventions/ were used to generate this project.
```

## Wrap up

1. Print a summary of what was generated (file count by category).
2. Suggest next steps:
   - `./gradlew bootRun` to verify the app starts (Docker containers start automatically via `spring-boot-docker-compose`).
   - Login with `admin` / `password` or `<lowercase-domain-role>` / `password`.
   - Commit the initial scaffold.
   - Run `/plan` to start building features.

## Rules

- Never generate features beyond the auth scaffold — that's what `/plan` → `/design` → `/implement` is for.
- Follow convention docs exactly. If a pattern isn't covered by a convention doc, keep it simple and consistent with the existing patterns.
- No hardcoded version numbers in generated code. Use latest stable versions at generation time.
- The bootstrap context marker goes in the project's `<work.dir>/`, not in devenv.
- If the current directory is not empty, warn the user and ask to confirm before generating.
