# Installed skills backup

This repository is a backup snapshot of the currently installed local skills.

## Skill index

| Category | Skill name | Files | Path | Description |
| --- | --- | ---: | --- | --- |
| Agents skills | `planning-with-files-zh` | 9 | `agents-skills/planning-with-files-zh` | 基于 Manus 风格的文件规划系统，用于组织和跟踪复杂任务的进度。创建 task_plan.md、findings.md 和 progress.md 三个文件。当用户要求规划、拆解或组织多步骤项目、研究任务或需要超过5次工具调用的工作时使用。支持 /clear 后的自动会话恢复。触发词：任务规划、项目计划、制定计划、分解任务、多步骤规划、进度跟踪、文件规划、帮我规划、拆解项目 |
| Codex system skills | `imagegen` | 12 | `codex-skills/.system/imagegen` | Generate or edit raster images when the task benefits from AI-created bitmap visuals such as photos, illustrations, textures, sprites, mockups, or transparent-background cutouts. Use when Codex should create a brand-new image, transform an existing image, or derive visual variants from references, and the output should be a bitmap asset rather than repo-native code or vector. Do not use when the task is better handled by editing existing SVG/vector/code-native assets, extending an established icon or logo system, or building the visual directly in HTML/CSS/canvas. |
| Codex system skills | `openai-docs` | 10 | `codex-skills/.system/openai-docs` | Use when the user asks how to build with OpenAI products or APIs, asks about Codex itself or choosing Codex surfaces, needs up-to-date official documentation with citations, help choosing the latest model for a use case, or model upgrade and prompt-upgrade guidance; use OpenAI docs MCP tools for non-Codex docs questions, use the Codex manual helper first for broad Codex self-knowledge, and restrict fallback browsing to official OpenAI domains. |
| Codex system skills | `plugin-creator` | 10 | `codex-skills/.system/plugin-creator` | Create and scaffold plugin directories for Codex with a required `.codex-plugin/plugin.json`, optional plugin folders/files, valid manifest defaults, and personal-marketplace entries by default. Use when Codex needs to create a new personal plugin, add optional plugin structure, generate or update marketplace entries for plugin ordering and availability metadata, or update an existing local plugin during development with the CLI-driven cachebuster and reinstall flow. |
| Codex system skills | `skill-creator` | 9 | `codex-skills/.system/skill-creator` | Guide for creating effective skills. This skill should be used when users want to create a new skill (or update an existing skill) that extends Codex's capabilities with specialized knowledge, workflows, or tool integrations. |
| Codex system skills | `skill-installer` | 8 | `codex-skills/.system/skill-installer` | Install Codex skills into $CODEX_HOME/skills from a curated list or a GitHub repo path. Use when a user asks to list installable skills, install a curated skill, or install a skill from another repo (including private repos). |
| Codex user skills | `skill-router` | 3 | `codex-skills/skill-router` | Route a Codex task to the smallest useful set of skills and manage which local skills are implicitly invoked. Use when the user wants Codex to analyze a task and choose required skills, improve skill hit rate, reduce startup/context bloat, enable or disable skill auto-loading, audit local skills, or tune 技能调用, 命中率, 路由, 自动加载, 隐式调用, 启用/禁用 skills. |

## Source roots

- `C:\Users\19733\.codex\skills`
- `C:\Users\19733\.agents\skills`

## Local snapshot

- Local folder: `C:\Users\19733\Desktop\skills\installed-skills-backup-20260708-010557`
- Local archive: `C:\Users\19733\Desktop\skills\installed-skills-backup-20260708-010557.zip`
