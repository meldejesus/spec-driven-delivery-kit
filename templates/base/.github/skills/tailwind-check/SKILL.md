---
name: tailwind-check
description: >
  Review Tailwind CSS usage in a target file. Flags arbitrary values,
  unapproved color usage, accessibility regressions, and inconsistent local
  styling patterns.
---

# Tailwind CSS Check

Use this skill when the user asks to audit or fix Tailwind usage in a file.

## Inputs

Ask for the file path if the user has not provided one.

## Workflow

1. Run the project's normal lint command for the target file if one exists.
2. Read the target file.
3. Identify:
   - arbitrary values such as `text-[14px]`, `p-[16px]`, or `bg-[#fff]`
   - project-specific colors that should be design tokens
   - repeated class strings that should use local helpers
   - interactive controls missing accessible names or focus states
4. Prefer existing project design tokens and utility helpers.
5. Ask before changing colors when the closest token changes perceived hue,
   contrast, or semantic meaning.

## Report

Return:

- required fixes
- optional cleanups
- any items needing design/product confirmation

Only edit files when the user explicitly asks for fixes.
