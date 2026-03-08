# Building an AI Coding Harness

## The problem

AI coding agents can generate anything — and that's the problem. Without structure, they produce inconsistent output: different patterns for the same problem, mismatched conventions across files, architecture that drifts with every session. The model isn't the bottleneck. The system around it is.

## What a harness does

A harness channels AI capability through structured constraints. It doesn't limit what the agent can do — it defines how things should be done, so the agent converges faster on correct, consistent output.

Three pillars:

**Context engineering.** The agent reads a knowledge base at runtime — convention docs describing patterns (how entities look, how services are structured, how security works). This isn't documentation for humans. It's guidance the agent follows while generating code. Swap the conventions, swap the output style.

**Task decomposition.** Instead of "build me a feature," the harness breaks work into phases: research the codebase and conventions, plan the tasks, design the architecture, implement one task at a time. Each phase produces an artifact the next phase reads. No one-shot attempts. Incremental, verified progress.

**Feedback loops.** When something doesn't work — a convention is missing, a pattern conflicts, the codebase has drifted — you feed that discovery back into the system. Research triggers plan refinement. Plan refinement triggers design updates. The harness evolves from real usage, not upfront speculation.

## What devenv provides

A personal (and eventually team-shareable) harness built on Claude Code skills:

```
/research → /plan → /design → /implement
     ↑                              │
     └──── re-enter on discovery ───┘
```

- **Convention docs** — markdown files with frontmatter describing coding patterns. Layerable: personal conventions override team conventions override org defaults. Drop files in to add constraints, remove them to relax.
- **Skills** — structured prompts that enforce the workflow. Each skill reads the relevant conventions, produces a predictable artifact, and hands off to the next phase.
- **Bootstrap** — scaffold a full project from conventions in minutes. The conventions ARE the project template.
- **Research** — scan the codebase and conventions at any point. Surface what applies, what's missing, what conflicts. Feed findings into planning.

## Why this matters

The agent is a commodity — models improve every few months. The harness is the moat. Teams that encode their patterns, enforce their boundaries, and build feedback loops into their AI workflow produce better software faster. Not because they have a better model, but because their model has better guidance.

Changing just the harness improved 15 different LLMs by 5-14 percentage points in benchmarks. The weakest models gained the most — mechanical failures were masking actual reasoning ability. Better structure means better output from any model.

## Where this is going

Today: personal conventions, solo dev workflow, Spring Boot stack.

Next: layered convention sources (personal > team > org), swappable "brains" via separate repos, a research step that detects codebase drift from conventions. The conventions directory becomes a contract any team can implement — drop in your patterns, get consistent output across every developer's AI agent.

The goal isn't to replace engineering judgment. It's to encode the decisions you've already made so the agent stops re-making them differently every time.
