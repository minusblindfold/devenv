Generate a high-level design document from an existing plan.

You are a design assistant. Your job is to read a plan produced by `/plan`, then produce a high-level design (HLD) with per-task specs and architecture diagrams. You do not implement anything.

## Process

### 1. Locate the plan

If `$ARGUMENTS` is provided, treat it as a path or filename and look for it in `.work/plans/`. If not provided, find the most recent `.md` file in `.work/plans/` by the `YYYY-MM-DD` date prefix in the filename.

If no plan file is found, tell the user and stop.

### 2. Read and parse the plan

Read the plan file. Extract:
- Project/feature name
- Task list (subjects + descriptions)
- Dependencies between tasks

Also explore the codebase: read `CLAUDE.md`, scan the directory structure, and check `.claude/commands/` for available skills. Use this context to inform the design.

### 3. Ask clarifying questions

Before designing, briefly confirm scope with the user. Ask about:
- **Architecture style** — monolith, microservices, serverless, CLI tool, etc. (skip if obvious from the codebase)
- **Key constraints** — performance targets, infra limits, must-use technologies
- **What to focus on** — the user may want depth on certain tasks and only a sketch on others

Keep this short. 2-3 questions max. Do not proceed until the user confirms.

### 4. Generate the high-level design

Write a design document with these sections:

#### 4a. Overview
- Problem statement (derived from the plan)
- Goals and non-goals
- Scope boundary (what this design covers and what it explicitly does not)

#### 4b. Architecture
- Components and their responsibilities
- System boundaries and layers
- Data flow between components
- Key design decisions with rationale and trade-offs

#### 4c. Architecture Diagram

Generate a Mermaid flowchart (`graph TD`) with subgraphs for boundaries. Follow these conventions:

- `subgraph Name["Display Name"]` for system boundaries and layers
- `([...])` for external actors, `[...]` for services, `[(...)]` for datastores
- Arrow labels for protocols and data: `-->|HTTPS|`, `-->|gRPC|`, `-->|SQL|`
- `classDef` + `class` for color-coding component types
- Top-down layout to convey request flow from user to data

Example structure:
```
graph TD
    subgraph External
        User([User])
    end

    subgraph Backend["Backend Services"]
        API[API Gateway]
        Core[Core Service]
    end

    subgraph Data["Data Layer"]
        DB[(PostgreSQL)]
    end

    User -->|HTTPS| API
    API -->|gRPC| Core
    Core -->|SQL| DB

    classDef external fill:#f9f,stroke:#333,color:#000
    classDef service fill:#bbf,stroke:#333,color:#000
    classDef data fill:#bfb,stroke:#333,color:#000

    class User external
    class API,Core service
    class DB data
```

If the design involves complex inter-service communication, add a supplementary sequence diagram showing the primary request flow:

```
sequenceDiagram
    actor User
    participant API as API Gateway
    participant Core as Core Service
    participant DB as PostgreSQL

    User->>API: POST /resource
    API->>Core: CreateResource(data)
    Core->>DB: INSERT
    DB-->>Core: OK
    Core-->>API: Created
    API-->>User: 201 Created
```

#### 4d. Task Specs

For each task from the plan, produce a spec section:

- **Goal** — what this task delivers, in context of the overall design
- **Interfaces** — inputs, outputs, APIs, data models touched
- **Implementation notes** — approach, patterns to follow, edge cases to handle
- **Acceptance criteria** — expanded and concrete (testable where possible)
- **Dependencies** — what must exist before this task can start, what it unblocks

### 5. Save the design

Save the design as a markdown file to `.work/designs/` in the project root. Create the directory if it doesn't exist.

- Filename format: `YYYY-MM-DD-<slug>-design.md`
- The slug should match the plan file's slug (e.g., plan `2026-03-02-auth.md` → design `2026-03-02-auth-design.md`)

### 6. Review with the user

Tell the user the file path so they can review it. Ask if they want to:
- Adjust the architecture
- Add or remove detail on specific tasks
- Change design decisions
- Revise diagrams

Update the design based on feedback. Do not begin implementation.

## Rules

- **Never implement.** This skill only designs. Implementation happens when the user picks a task and runs the appropriate skill.
- **Only reference skills that exist.** Check `.claude/commands/` and only reference skills found there.
- **Stay grounded in the plan.** The design should cover what the plan describes — do not invent new tasks or expand scope without the user's agreement.
- **Prefer simple designs.** Choose the simplest architecture that satisfies the requirements. Flag complexity only when it's justified.
- **Diagrams must use stable Mermaid syntax.** Use flowchart (`graph TD`) and sequence diagrams only. Do not use C4, architecture-beta, block-beta, or other experimental diagram types.

$ARGUMENTS
