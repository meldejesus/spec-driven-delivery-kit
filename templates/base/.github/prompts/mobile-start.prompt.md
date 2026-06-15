---
name: mobile-start
description: >
  Start a mobile development environment using the target project's local
  Android/iOS commands. Adapt this prompt after installing the kit.
tools: [terminal, read, edit, search, agent]
agent: Mobile Dev
mode: agent
---

# Mobile Dev Environment - Start

## Inputs

- Platform: `${input:Platform - android | ios | both (default: android):android}`
- Skip native build: `${input:Skip native build? yes | no (default: no):no}`
- Reset bundler cache: `${input:Reset bundler cache? yes | no (default: no):no}`

## Before Running

Inspect the target project for:

- mobile package scripts
- emulator/simulator setup
- bundler command
- backend dependency services
- environment file requirements

Do not assume commands from this template are correct for the project.

## Execution

1. Check available memory and local prerequisites.
2. Start required backend services.
3. Verify mobile environment variables.
4. Boot emulator or simulator.
5. Start the bundler.
6. Run the native build unless skipped.
7. Report active services, platform, device target, and any issues.
