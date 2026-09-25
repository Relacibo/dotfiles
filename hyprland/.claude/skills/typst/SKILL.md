---
name: typst
description: Create, structure, and compile Typst (.typ) documents — reports, letters, invoices, papers. Use whenever the user asks for a Typst document, mentions .typ files, or wants a print-ready/PDF deliverable that would benefit from real typesetting instead of HTML/Markdown.
---

# Typst documents

Typst is installed at `~/.cargo/bin/typst`. Compile with `typst compile <entry>.typ <out>.pdf`.

## 1. Decide where the document lives (default global, don't ask)

Default to **global** without asking: `$(xdg-user-dir DOCUMENTS)/typst/sources/<doc-slug>/`. This is the sane default for the vast majority of documents (letters, invoices, reports, personal PDFs) — don't interrupt with an `AskUserQuestion` for the common case.

Only use **project-local** (`<project-root>/typst/sources/<doc-slug>/`) when the user's request makes it explicit or unambiguous, e.g.:
- They say so directly ("im Projekt", "projektlokal", "hier im Repo", "ins Repo").
- The document is clearly meant to be committed/shipped with the project (e.g. a report generated *from* project data and referenced by project docs/CI, a template other contributors need).

Being inside a git repo's working directory is *not* by itself a signal for project-local — most Typst documents (a letter, an invoice) have nothing to do with whatever repo you happen to be sitting in. If genuinely unsure after reading the request, default to global rather than asking; it's a one-line `mv` to relocate later.

Resolve the global base with `xdg-user-dir DOCUMENTS` (an `xdg-user-dirs` shell command, not `XDG_DOCUMENTS_DIR` — that env var is usually unset even though the value lives in `~/.config/user-dirs.dirs`). Don't hardcode `~/Dokumente` — it's whatever the user's locale/config set the Documents dir to. Fall back to `~/Documents` only if the command is unavailable.

## 2. Folder structure

Create any of `fonts/`, `templates/`, `sources/`, `rendered/` under the typst root that don't exist yet (`mkdir -p`) — don't ask, don't treat a missing folder as an error. The whole tree is meant to bootstrap itself on first use, both global and project-local.

Every individual document gets its own folder under `sources/`, keyed by a `<doc-slug>`. Rendered output goes in a parallel `rendered/` tree under the same slug — never inside the source folder — so the source tree stays free of build artifacts and finished files sit in one place instead of scattered under each document:

```
<doc-root>/                # = <typst-root>/sources/<doc-slug>/
  src/
    main.typ        # entry point
  assets/           # images, logos, figures
  fonts/            # ONLY if the doc needs a custom/branded font not installed system-wide
```

Global root is `$(xdg-user-dir DOCUMENTS)/typst/`:

```
<Documents>/typst/
  fonts/            # personal fonts reused across many documents
  templates/        # reusable .typ templates/snippets (letter, invoice, report skeletons)
  sources/
    <doc-slug>/     # one folder per document, structure as above
  rendered/
    <doc-slug>/     # compiled output, e.g. main.pdf — mirrors the sources/ slug
```

Project-local mirrors the same shape for consistency, under `typst/` at the repo root (visible, not dotfile — it's content, not tooling config; only use `.typst/` if the user explicitly asks to keep it out of the visible directory listing):

```
<project-root>/typst/
  fonts/            # optional, shared across this project's documents
  sources/
    <doc-slug>/     # one folder per document, structure as above
  rendered/
    <doc-slug>/     # compiled output — add `typst/rendered/` to .gitignore
```

When setting up project-local, always check whether the project is a git repo (`git rev-parse --is-inside-work-tree`). If it is, ensure `typst/rendered/` is covered by `.gitignore`:
- If a line already covers it (`typst/rendered/`, `typst/rendered`, or a broader pattern like `typst/`), do nothing.
- Otherwise append `typst/rendered/` to the existing `.gitignore` (create the file if it doesn't exist yet).

Never gitignore `typst/sources/`, `typst/fonts/`, or `typst/templates/` — those are real content, not build output.

## 3. Starting from a Typst Universe template

Before writing `main.typ` from scratch, consider whether a published template already fits (letter, resume/CV, IEEE-style paper, invoice, poster, etc.) — Typst Universe (typst.app/universe) hosts community templates under the same `@preview/` namespace as packages. Use `WebSearch`/`WebFetch` against typst.app/universe if you need to find the right package name; don't guess one.

Scaffold with `typst init`, which fetches the template package straight into place:

```
mkdir -p <doc-root>
typst init @preview/<template>[:version] <doc-root>/src
```

`typst init` does not create parent directories itself (only the final target dir) — always `mkdir -p <doc-root>` first, then point it at `<doc-root>/src`. This lands `main.typ` and any accompanying files (e.g. a `.bib`) directly at `<doc-root>/src/...`, matching the folder structure from step 2 with no extra reshuffling.

Only do this when a template is a genuine fit for what the user asked for — don't force one on a document that doesn't match its structure just to avoid writing from scratch.

## 4. Git & versioning (opt-in — ask, don't assume)

Git tracking is opt-in, not automatic. This is the one deliberate exception to the "default without asking" pattern used elsewhere in this skill: git init + commit + push-to-remote is a standing background action that keeps running on every future edit, not a one-off, so it deserves a checkpoint before it starts.

Once the first version of a global-scope document has compiled successfully (or, for `templates/`, once a template is in a working state), ask once, e.g.: *"Soll ich die Sources mit Git versionieren und aufs Backup pushen?"* A quick yes/no `AskUserQuestion` works well here (options like "Ja, tracken" / "Nein, nur lokal lassen"). Don't ask before that point — there's nothing worth versioning yet.

- **If yes:** `git init` in that scope right away, commit everything so far as the initial commit, then immediately push via `git-backup.sh` (see below) — the commit and the push are one action, not two. From then on, for the lifetime of that repo, keep committing after each meaningful change (edits, new assets/fonts, recompiles worth keeping a record of) and pushing after each commit, automatically, without asking again — the opt-in covers the whole document, not just the first commit.
- **If no:** skip git entirely for this document — no `.git`, no backup. Don't re-ask on every subsequent edit; if a lot changes later or the user comes back to the same document in a future conversation, it's fine to offer again once, but don't nag.
- If the user's request already makes the intent explicit either way (e.g. "und sichere das gleich ab" vs. "nur schnell testen"), skip the question and act on that instead — the question is for the ambiguous default case.

**Global scope only** — each of these is its own independent git repo, once opted in:
- `$(xdg-user-dir DOCUMENTS)/typst/sources/<doc-slug>/`
- `$(xdg-user-dir DOCUMENTS)/typst/templates/` — one repo for the whole templates folder (not one per template).

Never `git init` inside `fonts/` (binary assets, not iterated on) or `rendered/` (build output, and it's already structurally outside `sources/`, so there's nothing to gitignore there).

**Project-local: do NOT `git init` inside `<project-root>/typst/sources/<doc-slug>/`, and don't ask the opt-in question there either.** The project already has its own repo (or the user asked for project-local specifically because it should be versioned with the project) — nesting a repo inside a repo creates a broken "embedded repository" state where `git add` from the project root silently fails to track the files. Project-local documents are versioned automatically for free, as part of the project's existing repo; only the `.gitignore` handling from step 2 applies there.

### Remote backup (global scope only, same opt-in)

Local-only git has no off-machine copy. Once the user has opted in (above), every commit gets pushed immediately, unconditionally — not batched up, not asked again per-commit. Back up every opted-in global-scope repo (`sources/<doc-slug>/` and `templates/`) to a bare repo on the `ovilava.rcbnetwork.de` SSH host (also reachable via the shorter `ovilava` alias in `~/.ssh/config`, but remotes are named with the full hostname; key-based auth already works, confirmed reachable):

```
~/.gemini/config/skills/typst/scripts/git-backup.sh <local-repo-dir> <remote-relative-path>
# e.g. (or use ~/.config/opencode/skills/typst/scripts/... if using OpenCode / DeepSeek)
~/.gemini/config/skills/typst/scripts/git-backup.sh "$(xdg-user-dir DOCUMENTS)/typst/sources/<slug>" "sources/<slug>"
~/.gemini/config/skills/typst/scripts/git-backup.sh "$(xdg-user-dir DOCUMENTS)/typst/templates" "templates"
```

It creates `/mnt/data/git/typst/<remote-relative-path>.git` as a bare repo on `ovilava.rcbnetwork.de` if missing, wires it up as `origin` if not already set, and pushes all branches — idempotent, safe to call after every commit. A repo with zero commits yet (e.g. a freshly-`git init`'d empty `templates/`) has nothing to push and the script will error on that push step — that's expected, not a bug; just skip backing it up until it has at least one commit.

This is unrelated to the earlier finding that **SFTPGo cannot host git repos** — `ovilava.rcbnetwork.de` is a different, regular SSH host with a normal shell/git installed, so plain git-over-ssh works there without issue.

## 5. Fonts

Two font locations, both additive (not override tiers):

1. `$(xdg-user-dir DOCUMENTS)/typst/fonts/` — personal fonts reused across many documents.
2. `<doc-root>/fonts/` — only when this specific document needs a font not covered above (e.g. a client's brand font), for reproducibility on other machines/CI.

Typst's docs don't specify precedence when the same font family exists in two `--font-path` dirs — don't rely on one shadowing the other. Keep the two sets disjoint by name in practice; if a real per-document override is ever needed, treat it as a one-off (compile that one document without the global path) rather than building general shadowing logic for a case that shouldn't normally happen.

Prefer setting `TYPST_FONT_PATHS` once (Typst reads this env var itself, see `typst compile --help`) so the global fonts dir is always picked up with zero flags:

```
export TYPST_FONT_PATHS="$(xdg-user-dir DOCUMENTS)/typst/fonts"
```

Suggest adding this line to the user's shell rc (`~/.zshrc`/`~/.bashrc`) — ask before editing it yourself, it's their dotfile. Don't create a `fonts/` folder speculatively — only when a document actually needs a non-system font.

### Pulling in a Google Font

If the document asks for a font by name that's a Google Font and isn't already system-installed or present in either fonts location, fetch the real font files — don't use the `fonts.googleapis.com/css2` endpoint, it only serves `.woff2`, which Typst's font loader does not read (it needs raw `.ttf`/`.otf`). Instead pull directly from the `google/fonts` GitHub repo, which needs no API key:

1. Derive the repo slug: lowercase the family name, strip spaces/punctuation (e.g. "IBM Plex Sans" → `ibmplexsans`).
2. Find its license folder by trying each until one exists: `curl -s https://api.github.com/repos/google/fonts/contents/ofl/<slug>`, then `apache/<slug>`, then `ufl/<slug>`.
3. From that JSON, download the `.ttf`/`.otf` entries' `download_url`s, plus the license file (`OFL.txt`/`LICENSE.txt`/`UFL.txt`) for attribution — keep the license file alongside the font.
4. Save into `<doc-root>/fonts/` by default; only save to the global `$(xdg-user-dir DOCUMENTS)/typst/fonts/` if the user says they want to reuse this font across documents.
5. Recompile.

The GitHub API is unauthenticated here (60 requests/hour limit) — fine for occasional font fetches, don't build a caching layer for it.

## 6. Compiling

Don't generate a per-document compile script — it's the same few lines copied N times with nothing to keep them in sync. Use the single shared script at `~/.gemini/config/skills/typst/scripts/compile.sh` (or `~/.claude/skills/typst/scripts/compile.sh` / `~/.config/opencode/skills/typst/scripts/compile.sh` if using OpenCode/DeepSeek) instead, for any doc root (global or project-local):

```
~/.gemini/config/skills/typst/scripts/compile.sh <doc-root> [output-name.pdf] [extra typst args...]
```

It derives `<typst-root>/rendered/<doc-slug>/` from `<doc-root>` (which must be `.../typst/sources/<doc-slug>`), compiling from `<doc-root>/src/main.typ`, adds `<doc-root>/fonts` if present, and falls back to adding the global fonts dir explicitly only if `TYPST_FONT_PATHS` isn't set in the environment.

The optional second positional argument (not starting with `-`) overrides the output **filename** (default: `main.pdf`). For anything that will be emailed, shared or printed, use a descriptive, self-explanatory German filename instead of `main.pdf` — recipients should know what the attachment is without opening it:

```
~/.claude/skills/typst/scripts/compile.sh <doc-root> Anleitung-Samsung-SSD-Update.pdf
```

Remaining args are passed through to `typst compile` unchanged.

After every compile, state the absolute path to the rendered file(s) back to the user — don't make them re-derive it from the folder convention or ask where it went.

## 7. Packages

`@preview` packages (e.g. `#import "@preview/cetz:0.3.1"`) are fetched and cached automatically by the Typst CLI itself into `~/.cache/typst/packages/preview/`. Never vendor or manually download these — just import by name/version and let `typst compile` handle it (needs network access on first use per version).

## 8. Artifacts vs. Typst

The `Artifact` tool only renders HTML or Markdown live in-browser. Typst is not a fit for it — Typst produces PDF/PNG/SVG via a compile step, not a live-rendered page. When the user wants a Typst deliverable, compile it with Bash and hand over the resulting file path (or open it) instead of trying to route it through Artifact.

## 9. Sharing a rendered document (delegate to `share` skill)

After compiling, state the absolute path to the rendered PDF — that's it. Do NOT upload or notify by default.

Only share when the user explicitly asks:
- "schick mir den Link" / "per ntfy" → upload + notify via ntfy
- "per Email" / "schick es an X" → open Thunderbird compose with PDF attached
- "lade es hoch" → upload to SFTPGo, print the link

All sharing is delegated to the **share** skill (`~/.claude/skills/share/`). Do NOT duplicate upload/notify logic here.

### ntfy (opt-in)

When the user asks for the link on their phone:
```bash
LINK=$(~/.claude/skills/share/scripts/share-upload.sh "$rendered_dir/main.pdf")
~/.claude/skills/share/scripts/share-notify.sh "<title>" "<summary>" "$LINK"
```

### Thunderbird (opt-in)

When the user asks for email:
```bash
~/.claude/skills/share/scripts/share-email.sh "$rendered_dir/main.pdf" "recipient@example.com" "Subject" "Body text"
```

### SFTPGo only (opt-in)

When the user just wants a link (no notification):
```bash
~/.claude/skills/share/scripts/share-upload.sh "$rendered_dir/main.pdf"
```
