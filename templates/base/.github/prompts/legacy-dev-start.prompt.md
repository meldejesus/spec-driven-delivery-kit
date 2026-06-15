---
name: legacy-dev-start
description: >
  Start a project's legacy or backend development environment using local
  project commands. Adapt this prompt after installing the kit.
tools: [terminal, read, edit, search, agent]
agent: Legacy-Dev
mode: agent
---

# Legacy Dev Environment - Start

## Inputs

- Environment: `${input:Environment name (default: development):development}`
- Include auth/login step: `${input:Include auth/login step? yes | no (default: no):no}`

## Before Running

Inspect the target project for:

- package scripts
- Docker Compose files
- required ports
- local environment files
- backend/frontend startup order

Do not assume commands from this template are correct for the project.

## Execution

1. Check prerequisites.
2. Confirm required ports are free.
3. Start local services in the project-defined order.
4. Start backend/server processes.
5. Start frontend/watch processes if applicable.
6. Report service names, ports, URLs, and any manual follow-up.

If a port is occupied or a service needs to be stopped, ask before stopping it.
