# global agent instructions

- Never use the em dash "—". Use plain dash "-" instead
- When writing commit messages, NEVER auto-add your agent name as co-author
- Never manually modify CHANGELOG.md files or any files that are marked as auto-generated
- When making technical decisions, do not give much weight to development cost.
  Instead, prefer quality, simplicity, robustness, scalability, and long term maintainability.
- For one-off or infrequent operational work, start with the simplest direct end-to-end path. Do not build wrappers, control planes, policy layers, custom verifiers, or automation unless the direct path exposes a concrete blocker or repeated need that justifies the added machinery.
- When doing bug fixes, always start with reproducing the bug in an E2E setting as closely aligned with how an end user would experience it as possible.
  This makes sure you find the real problem so your fix will actually solve it.
- When end-to-end testing a product, be picky about the UI you see and be obsessed with pixel perfection.
  If something clearly looks off, even if it is not directly related to what you are doing, try to get it fixed along the way.
- Apply that same high standard to engineering excellence: lint, test failures, and test flakiness.
  If you see one, even if it is not caused by what you are working on right now, still get it fixed.
- Before using "dynamic workflows", "ultra code" or any harness feature that immediately spawns a large swarm of subagents, always explain the tradeoffs and ask the user for explicit approval.

## Visual deliverables (HTML, reports, timelines)

- Never publish deliverables to a hosted artifact or sharing service by default. Uploading sends the content to a third party, and published copies often cannot be deleted afterwards. Offer publishing as an explicit question, never as the default way to finish.
- Build deliverables as self-contained local HTML (or similar) files and give me the path.
- Save them in a durable location in the project, not a session-scoped scratchpad or temp directory.
- Save the generator script alongside the output so the page can be rebuilt from source data later.

## Secret management

- Secrets (API tokens, keys) live in Automic Vault (`av`), stored in the macOS Keychain via `av save KEY` - never in plaintext dotfiles, `.env` files, or tool configs.
- Hand a secret to a single command for its lifetime only with `av inject +KEY -- <command>`; never write secret values to disk, put them on a command line, or paste them into chat - ask me to enter any new secret value myself.

## Collaboration preferences

- Explain system and configuration changes in plain language before applying them.
- Prefer short, copy-safe commands and one checkpoint at a time.
- Use Micro as the default terminal editor. Do not assume Vim or Neovim knowledge.
- I run my agent terminals in Herdr (https://herdr.dev), not tmux. When telling me where to run a long-lived or foreground process, say "a herdr pane". Herdr's terms are panes (individual agent terminals, marked working/blocked/idle), workspaces (groups of panes), and sessions (state that survives a restart). First Mate still uses tmux internally to host its workers, so tmux in a config file is not a mistake to correct.

## Private companion notes

- Machine-specific notes (machine inventory, security posture, credential shape, forensics) live in `~/dotfiles-private`, a private repo. When a change touches secrets, daemons, tokens, or machine inventory, record it there - never in the public dotfiles repo. That includes describing how a credential is scoped, not just its value.
- My machine-name glossary and my GitHub credential notes are defined there and imported below. If an import did not resolve, read `~/dotfiles-private/machines.md` before acting on a machine name you don't recognize, and `~/dotfiles-private/github.md` before diagnosing a failing `gh` call.

@~/dotfiles-private/machines.md
@~/dotfiles-private/github.md
