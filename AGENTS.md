# Ironworks — Core Principles

You are building production software. These principles are active every response.

## The Priority Stack

Every decision follows this order. Never optimize a lower priority at the expense of a higher one.

1. **Correct** — it does what the spec says, handles edge cases, fails safely
2. **Clear** — a new team member can read it without a walkthrough
3. **Performant** — no unnecessary work, no N+1 queries, no blocking calls where async fits
4. **Brief** — shortest code that satisfies 1–3

## The Discipline Ladder

Before writing new code, stop at the first rung that holds:

1. Does this need to exist at all? Speculative need → skip it, say so.
2. Already in this codebase? A helper, util, or pattern that lives here → reuse it.
3. Standard library does it? → Use it.
4. Native platform feature covers it? → Use it.
5. Already-installed dependency solves it? → Use it. Never add a dep for what a few lines handle.
6. Can it be one line? → One line.
7. Only then: the minimum code that works.

## Never Compromise

These survive every simplification. No exceptions, no "we'll add it later":

- Input validation at trust boundaries
- Error handling on every external call (API, DB, file, network)
- Parameterized queries — never string-concatenated SQL
- Auth/authz checks on protected operations
- Accessibility fundamentals (keyboard nav, labels, contrast)
- Secrets in environment variables, never in code
- Typed errors with actionable messages — never swallow exceptions silently

## Code Standards

### Architecture
- Follow existing project patterns. Read before writing.
- Flat is better than nested. Explicit is better than implicit.
- One file does one thing. Name it after what it does.
- No premature abstractions — extract at the third repetition, not the first.

### Testing
- New features need tests. Bug fixes need regression tests.
- Test behavior, not implementation. Tests should survive refactors.
- Use the project's existing test framework and patterns.

### Git Discipline
- Atomic commits — one logical change per commit.
- Commit messages: imperative mood, explain why not what.
- Never force push to shared branches.

## Working With Ironworks Specs

If an `ironworks/` directory exists in the project root:
- Read `ironworks/specs/` before making changes — these are the living requirements
- Check `ironworks/changes/` for in-flight work before starting something new
- Every feature should trace back to a spec. If it doesn't, propose one first.

## Scalability Awareness

Apply to every project by default:

- **Database**: Indexes on FKs, connection pooling, no N+1, pagination on lists, reversible migrations
- **API**: Versioned endpoints, rate limiting on public routes, consistent response envelope, CORS locked to known origins
- **Infrastructure**: Health check endpoint, structured logging with correlation IDs, graceful shutdown, env-specific configs
- **Frontend**: Code splitting, error boundaries, loading/empty states, responsive from mobile up, keyboard accessible
