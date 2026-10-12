---
name: harmonyos-arkts-development
description: Build, review, debug, test, and modernize HarmonyOS/OpenHarmony applications using ArkTS, ArkUI, DevEco Studio, Hvigor, HAP/HSP/HAR modules, system APIs, permissions, resources, and Navigation. Use for .ets files, module.json5, oh-package.json5, build-profile.json5, ArkUI components, ArkTS compiler errors, HarmonyOS architecture, and migrations to state management V2.
---

# HarmonyOS ArkTS development

## Workflow

1. Inspect `AGENTS.md` and project conventions, then locate `module.json5`, `oh-package.json5`, `build-profile.json5`, and relevant `.ets` files.
2. Determine the project's API level, device targets, module types, state-management version, routing approach, permissions, and localization structure before editing.
3. Preserve established project conventions unless the task explicitly requests modernization. For new code, prefer ArkUI state management V2 and `Navigation`/`NavPathStack`.
4. Verify uncertain API signatures, API-level availability, permissions, and device support against current official Huawei or OpenHarmony documentation; never invent an API.
5. Implement the smallest coherent change, including resources, localization, permissions, and tests affected by it.
6. Run the repository's Hvigor wrapper and tests. Use the project's documented product/module parameters rather than assuming `default`.
7. Report modified files, validation performed, and any API/device limitations.

## Required references

Read the relevant bundled references before changing code:

- `references/patterns.md`: architecture, ArkUI, state, navigation, concurrency, performance, and API patterns.
- `references/coding-style.md`: ArkTS syntax and style constraints.
- `references/testing.md`: unit, UI, and integration testing practices.
- `references/security.md`: permissions, storage, networking, WebView, and secret-handling checks.
- `references/hooks.md`: build and validation command guidance.
- `references/upstream-agent.md`: focused HarmonyOS review checklist and V2 migration guidance.

## Guardrails

- Treat ArkTS as stricter than TypeScript; do not introduce unsupported TypeScript constructs.
- Do not silently migrate an established V1 codebase wholesale. Flag the mismatch, keep the requested change scoped, and migrate only when requested or required for correctness.
- Keep imports at the file header and use explicit types where ArkTS requires them.
- Use `$r()` resources for user-visible strings, colors, and dimensions where the project resource model applies; update all maintained locales.
- Declare and justify required permissions in `module.json5`; avoid unnecessary permissions.
- Keep expensive work off the UI thread using platform-supported concurrency patterns appropriate to the API level.
- Never claim a build succeeded unless the actual project command completed successfully.

## Review output

For reviews, prioritize compilation blockers, runtime correctness, API compatibility, security/privacy, lifecycle leaks, state observation, navigation, performance, accessibility, and localization. Cite exact files and lines, and separate confirmed defects from suggestions.
