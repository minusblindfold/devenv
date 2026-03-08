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

Read `conventions.layers` from `~/.claude/devenv.json`. Follow [convention-resolution.md](../convention-resolution.md) (mode: **all**) to resolve every available convention doc across layers. Read all resolved docs.

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
  - `testRuntimeOnly 'com.h2database:h2'`
  - Lombok `compileOnly { extendsFrom annotationProcessor }` config. JUnit Platform for tests.
- `settings.gradle` — `rootProject.name = '<project-name>'`
- `compose.yaml` — per the Docker & Database conventions. Database name: `<project-name>_db` (hyphens replaced with underscores).
- `.env.template` — per the Docker & Database conventions. Matching database name.
- `src/main/resources/application.properties` — per the Docker & Database conventions. App name set. Matching database name in defaults.
- `.gitignore` — Gradle build dirs, IDE files (.idea, *.iml, .vscode, .classpath, .project, .settings), .env, bin/, out/, build/.

### Gradle wrapper

Run `gradle wrapper` to generate the wrapper files.

### Main application class

- `src/main/java/<group-path>/<artifact>/<ArtifactName>Application.java` — Standard `@SpringBootApplication` with `main` method.

### Model layer (per the JPA Entity and Spring Security conventions)

- `model/Role.java` — Enum: `ADMIN`, `<DOMAIN_ROLE>`.
- `model/User.java` — Per the JPA Entity conventions. Fields: id, username, password, email, role, enabled, createdAt, updatedAt. No relationship fields at bootstrap (those come with features). Full custom equals/hashCode.

### DTO layer

- `dto/UserRegistrationDto.java` — `@Data @Builder @NoArgsConstructor @AllArgsConstructor`. Fields: username, email, password, confirmPassword.

### Repository layer

- `repository/UserRepository.java` — `JpaRepository<User, Long>` with `@Repository`. Methods: `findByUsername(String)` returning `Optional<User>`, `existsByUsernameIgnoreCase(String)`, `existsByEmailIgnoreCase(String)`.

### Service layer (per the Service Layer and Spring Security conventions)

- `service/UserService.java` — Interface per the Service Layer conventions. Methods: createUser, findByUsername (returns `Optional<User>`), findById (returns `Optional<User>`), save, isUsernameTaken, isEmailRegistered, findAll, toggleEnabled, updateRole.
- `service/UserServiceImpl.java` — Per the Service Layer conventions. Validation in private `validateRegistrationInput()`. BCrypt encoding. Lowercase normalization. `findAll()` returns all users. `toggleEnabled(Long id)` flips enabled flag. `updateRole(Long id, Role role)` changes a user's role.
- `service/CustomUserDetailsService.java` — Per the Spring Security conventions. Maps Role to ROLE_ authority.

### Config layer (per the Spring Security conventions)

- `config/SecurityConfig.java` — Per the Spring Security conventions. Routes: `/admin/**` → ADMIN, `/<lowercase-domain-role>/**` → domain role. Public routes for home, register, static assets. Must include `BCryptPasswordEncoder` bean and `DaoAuthenticationProvider` bean wiring the custom user details service + encoder.

### Controller layer (per the Controller and Spring Security conventions)

- `controller/common/DashboardController.java` — Per the Spring Security conventions. Role-based redirect. Use `@Controller("commonDashboardController")`.
- `controller/common/auth/AuthController.java` — Home, login, register (GET + POST). Per the Spring Security conventions registration pattern.
- `controller/common/error/CustomErrorController.java` — HTML + JSON error handling. Status-specific templates (403, 404, 500).
- `controller/common/GlobalControllerAdvice.java` — `@ControllerAdvice @RequiredArgsConstructor`. Handles `EntityNotFoundException` (redirect to 404) and `IllegalArgumentException` (flash error message, redirect back). Add a placeholder `@ModelAttribute` method for shared model attributes (can be expanded later).
- `controller/admin/DashboardController.java` — Stub: `@Controller("adminDashboardController")`, `@RequestMapping("/admin/dashboard")`, single `@GetMapping` returning `"admin/dashboard"`.
- `controller/admin/UserController.java` — `@RequestMapping("/admin/users")`. GET `/` lists all users with role dropdown. POST `/{id}/toggle-enabled` toggles user enabled status. POST `/{id}/update-role` changes a user's role. Uses flash messages for feedback.
- `controller/<lowercase-domain-role>/DashboardController.java` — Stub: same pattern for the domain role.

### Database migrations (per the Liquibase Migration conventions)

- `src/main/resources/db/changelog/db.changelog-master.yaml` — Master changelog with `${now}` property, includes 001 and 002.
- `src/main/resources/db/changelog/changes/001-initial-schema.yaml` — Users table matching the User entity.
- `src/main/resources/db/changelog/changes/002-add-seed-users.yaml` — Admin user + domain role user. Use the same BCrypt hash and seed data format shown in the Liquibase Migration conventions seed data example. Include a YAML comment documenting the plaintext password per that convention.

### Templates (per the Thymeleaf Template conventions)

- `src/main/resources/templates/home.html` — Landing page with login form and hero section. Links to register. Shows dashboard link if authenticated.
- `src/main/resources/templates/common/auth/login.html` — Login form page.
- `src/main/resources/templates/common/auth/register.html` — Registration form with username, email, password, confirm password.
- `src/main/resources/templates/admin/dashboard.html` — Simple admin dashboard stub.
- `src/main/resources/templates/admin/users/list.html` — User management table with columns: ID, username, email, role (dropdown to change), status (enabled/disabled badge), created date, actions (toggle enable/disable button). Uses inline forms for role change and toggle.
- `src/main/resources/templates/<role>/dashboard.html` — Simple domain role dashboard stub.
- `src/main/resources/templates/error/403.html` — Forbidden error page.
- `src/main/resources/templates/error/404.html` — Not found error page.
- `src/main/resources/templates/error/500.html` — Server error page.
- `src/main/resources/templates/error/error.html` — Generic error page.
- `src/main/resources/templates/fragments/common/head.html` — Common head fragment with Bootstrap CSS/JS CDN, FontAwesome CDN, custom CSS link.
- `src/main/resources/templates/fragments/navbar/navbar.html` — Main navbar dispatcher per the Thymeleaf Template conventions.
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

### Test config

- `src/test/resources/application.properties` — Overrides for test environment. Uses an in-memory H2 database so tests pass without Docker/PostgreSQL:
  ```properties
  spring.docker.compose.enabled=false
  spring.datasource.url=jdbc:h2:mem:testdb
  spring.datasource.driver-class-name=org.h2.Driver
  spring.datasource.username=sa
  spring.datasource.password=
  spring.jpa.hibernate.ddl-auto=create-drop
  spring.liquibase.enabled=false
  ```

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
All conventions from the configured convention layers were used to generate this project.
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
