---
name: skill-router
description: Route a Codex task to the smallest useful set of skills and manage which local skills are implicitly invoked. Use when the user wants Codex to analyze a task and choose required skills, improve skill hit rate, reduce startup/context bloat, enable or disable skill auto-loading, audit local skills, or tune 技能调用, 命中率, 路由, 自动加载, 隐式调用, 启用/禁用 skills.
---

# Skill Router

## Purpose

Use this skill as a thin controller for other Codex skills. Keep only high-value router guidance in context, then load task-specific skills only when the task needs them.

This skill can:

- Analyze a user request and name the smallest set of relevant skills.
- Keep unrelated skills closed by setting `policy.allow_implicit_invocation: false` in their `agents/openai.yaml`.
- Re-enable selected skills by setting `policy.allow_implicit_invocation: true`.
- Leave disabled skills available for explicit `$skill-name` invocation.

Important limitation: changing skill metadata affects future discovery/startup behavior. It does not remove skill metadata already loaded into the current Codex conversation.

## Routing Workflow

1. Classify the task by outcome, not by keywords alone.
2. Select the fewest skills that materially change the work.
3. Prefer one domain skill plus one workflow skill when both are needed.
4. Avoid enabling broad skill families by default.
5. If a skill is needed once, invoke it explicitly with `$skill-name` instead of keeping it implicitly enabled.
6. Tell the user which skills were selected and why.

## Selection Rules

Use these common routes:

| Task shape | Preferred skills |
|---|---|
| Create or update a skill | `skill-creator` |
| Discover which skills apply | `skill-router`, optionally `using-agent-skills` |
| Implement code | `incremental-implementation`, plus domain-specific skill |
| Debug a failing system | `debugging-and-error-recovery` |
| Add tests or TDD | `test-driven-development` |
| Build or polish UI | `frontend-ui-engineering`, optionally `design-taste-frontend` |
| Figma to code | `figma-use`, then `figma-implement-design` |
| Browser/runtime validation | `playwright` or `browser-testing-with-devtools` |
| Review code | `code-review-and-quality` or `review` |
| Work with PDFs | `pdf` |
| Work with PowerPoint/images to slides | `image-to-editable-ppt` or `ppt-master` |
| Work with OpenAI products | `openai-docs`, optionally `chatgpt-apps` |
| Build an MCP server | `mcp-builder` |
| Embedded/STM32 work | `embedded-development` plus the specific board/project skill |
| Product strategy/planning | the specific product skill only; avoid enabling the whole product set |

When several product or strategy skills seem relevant, choose the one closest to the requested output, such as `create-prd`, `prioritize-features`, `gtm-strategy`, or `market-sizing`.

## Managing Skill State

Use `scripts/skill-router.ps1` for local audits and toggles.

List discovered skills:

```powershell
powershell -ExecutionPolicy Bypass -File .\skill-router\scripts\skill-router.ps1 -Action list
```

Recommend skills for a task:

```powershell
powershell -ExecutionPolicy Bypass -File .\skill-router\scripts\skill-router.ps1 -Action recommend -Task "Build a React dashboard and test it in a browser"
```

Disable all discovered skills except the router and a selected set:

```powershell
powershell -ExecutionPolicy Bypass -File .\skill-router\scripts\skill-router.ps1 -Action only -Skills skill-router,frontend-ui-engineering,playwright
```

Enable or disable specific skills:

```powershell
powershell -ExecutionPolicy Bypass -File .\skill-router\scripts\skill-router.ps1 -Action enable -Skills pdf,openai-docs
powershell -ExecutionPolicy Bypass -File .\skill-router\scripts\skill-router.ps1 -Action disable -Skills brandkit,gtm-strategy
```

By default, the script searches:

- `$HOME\.codex\skills`
- the current repo's `.agents\skills`
- the `skill-router` directory itself

Pass `-Roots` when managing a different skill directory.

## Safety Rules

- Do not delete skill folders as a way to improve startup.
- Do not disable `.system` skills unless the user explicitly asks.
- Keep `skill-router` implicitly enabled so Codex can keep routing.
- Prefer disabling implicit invocation over moving files.
- Before using `only`, confirm the selected keep-list includes every skill the user wants always available.
