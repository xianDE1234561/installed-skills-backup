# Installed Skills Backup

Backup of local Codex and agent skills, plus the plugin skill sources exposed in the current session. This repository is currently **public**.

## Latest snapshot: 2026-10-12

- 40 skills, 606 files, 4,793,613 bytes before compression.
- [Download the complete ZIP](./snapshots/2026-10-12/installed-skills-backup-20261012.zip).
- [ZIP SHA-256](./snapshots/2026-10-12/SHA256SUMS.txt).
- Each exported file is sanitized; the manifest records SHA-256 of the public export. ZIP CRC and every archived file's SHA-256 were also verified.
- A scan for common GitHub/OpenAI/AWS token formats, private-key headers and sensitive filenames found no matches. This is a pattern scan, not a comprehensive security audit.

## Repository layout

| Path | Contents |
| --- | --- |
| [codex-skills/](./codex-skills/) | Current local Codex skills, including `.system`. |
| [agents-skills/](./agents-skills/) | Current local agent skills. |
| [plugin-skills/](./plugin-skills/) | Current session's plugin skill resources, grouped by plugin. |
| [manifest.json](./manifest.json) | Source locations, file sizes and SHA-256 hashes. |
| [skill-index.json](./skill-index.json) | Skill names, categories and relative paths. |
| [snapshots/](./snapshots/) | Dated archives; older snapshots are retained. |

## Restore

1. Download the dated ZIP and verify it against `SHA256SUMS.txt`.
2. Extract it to a temporary directory. Back up existing installations before replacing files.
3. Restore `codex-skills` to your Codex skills directory and `agents-skills` to your agent skills directory. The source locations in `manifest.json` use portable placeholders.
4. Plugin skills here are source backups. Install the corresponding plugins through the app to restore their runtimes and connected tools. Copying these resources alone does not restore plugin services or account connections.

Generated caches (`__pycache__`, `.pyc`), dependency directories and Git metadata are excluded. Plugin runtimes, account credentials, app settings and unrelated user data are outside this backup's scope. Old public Git history was replaced to remove personal commit identities and paths. Dated archives are retained in sanitized form.

## Public-export privacy

Personal machine usernames, phone-based email addresses and document author metadata are removed. Generated caches are excluded from dated archives as well. Use an anonymous Git author identity for future backups; never publish a raw local manifest or ZIP without sanitizing it. The backup covers skill resources, not personal account credentials. Third-party license attribution and clearly fictional documentation examples are retained.
