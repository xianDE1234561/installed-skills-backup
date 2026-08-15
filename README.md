# Codex Installed Skills Backup

Private backup of installed Codex and agent skills.

## Repository layout

| Path | Purpose |
| --- | --- |
| [codex-skills/](./codex-skills/) | Browsable Codex skills snapshot (system skills and the user skill router). |
| [agents-skills/](./agents-skills/) | Browsable agent skills snapshot. |
| [snapshots/2026-08-15/](./snapshots/2026-08-15/) | Dated full backup archives. |
| [snapshots/2026-08-15/installed-skills-backup-20260815-v2.zip](./snapshots/2026-08-15/installed-skills-backup-20260815-v2.zip) | Complete backup captured on 2026-08-15, including the currently installed skills. |
| [manifest.json](./manifest.json) | Source-root and file metadata for the browsable snapshot. |
| [skill-index.json](./skill-index.json) | Machine-readable skill index. |

## How to use this repository

- For a quick reference, browse the two skill directories.
- For a full restore, download the dated ZIP archive and extract its \`codex-skills\` and \`agents-skills\` folders into the corresponding local skill roots.
- Keep future full archives under \`snapshots/YYYY-MM-DD/\` so snapshots remain easy to identify.

## Snapshot notes

- The browsable directories are the historical 2026-07-08 snapshot.
- The 2026-08-15 ZIP is the latest complete local backup.
- This repository is private because skill files may include local workflow details.
