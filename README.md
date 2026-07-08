# fxbackup

Back up an [fxcodebase.com](https://fxcodebase.com) phpBB forum (indicators &
strategies) to Markdown + downloaded attachments.

The backed-up archive is published and browsable online at
**<https://docs.gehtsoftusa.com/fxcodebase-backup/>**.

> **Note.** fxcodebase.com was the community site for custom indicators and
> strategies for the **FXCM Trading Station / Marketscope** trading client. It
> is **now defunct** — this tool was used to preserve its content before it
> went offline. All archived content (forum posts and
> every attached indicator, strategy, and script) is released under the
> [GNU General Public License (GPL)](https://www.gnu.org/licenses/gpl-3.0.html).

## Porting the archived Lua — Indicore Reader skill

Since the platform is gone, the point of the archive is to **port these
indicators and strategies to platforms that still exist**. This repo also ships
[**Indicore Reader**](skill/README.md), a [Claude Agent Skill](https://docs.claude.com/en/docs/claude-code/skills)
that teaches a coding agent to read and fully understand Indicore Lua — its
non-obvious semantics (streams that don't start at index 0, the `.DATA`
convention, live-vs-closed-bar shifts, the `Ext*` signal framework, `valuemap`
trading) — and produce a platform-neutral **port specification** (or an
annotated source copy) for reimplementation in Python, C#, Pine Script,
NinjaTrader, MQL, etc. Point it at any `.lua` file this tool downloads. See
[`skill/README.md`](skill/README.md).

## Usage

```
python3 fxbackup.py <forum-url> <output-folder> [options]
```

Example:

```
python3 fxbackup.py "https://fxcodebase.com/code/viewforum.php?f=17" ./backup
```

Run it once per forum into the **same** output folder — each forum gets its own
subfolder:

```
python3 fxbackup.py "https://fxcodebase.com/code/viewforum.php?f=17" ./backup
python3 fxbackup.py "https://fxcodebase.com/code/viewforum.php?f=29" ./backup
python3 fxbackup.py "https://fxcodebase.com/code/viewforum.php?f=31" ./backup
python3 fxbackup.py "https://fxcodebase.com/code/viewforum.php?f=38" ./backup
python3 fxbackup.py "https://fxcodebase.com/code/viewforum.php?f=48" ./backup
```

### Options

| Option        | Meaning                                                        |
|---------------|----------------------------------------------------------------|
| `--workers N` | Process N topics in parallel (default `1`). Big speed-up on large forums; the site is your own allow-listed server, so 5–10 is fine. |
| `--delay S`   | Minimum seconds between HTTP request *starts*, applied globally across workers (default `0.4`). Bounds total request rate to ~1/S per second. |
| `--limit N`   | Process at most N topics (for testing).                        |
| `--force`     | Re-download topics/attachments even if already present.        |
| `--verbose`   | Extra logging.                                                 |

For a large forum a good combination is e.g. `--workers 8 --delay 0.15`.

## Output layout

```
<output>/
  custom-indicators/                 forum folder = clean forum title
    .forum-id                        marker (which forum id lives here)
    forum.md                         index of every topic (links to folders)
    g/                               first-letter bucket (keeps folders small)
      gann-hilo-activator/           topic folder = clean topic title
        index.md                     the whole thread as Markdown
        files/<post-id>/GHLA.lua     indicators/attachments, grouped per post
        images/<post-id>/ghla.png    screenshots, grouped per post
    h/
      how-to-download-and-install-custom-indicator/
        ...
```

Topic folders are grouped into a single-character bucket taken from the first
letter of the folder name (`a`–`z`; digits go into `0-9`). This keeps any one
directory well under GitHub's ~1000-entries-per-folder limit — some of these
forums have 3000+ topics.

- **Folders are named after the (slugified) title**, kept clean. An id is
  appended at the *end* only to break a collision: if two topics share a title,
  the one with the lowest topic-id keeps the clean name and the others get a
  `-t<id>` suffix. Likewise a forum folder gets a `-f<id>` suffix only if a
  different forum already occupies the clean name.
- **One folder per topic (thread).** All messages of the thread are combined
  into a single `index.md`, in order, with author and date on each.
- **Attachments are grouped by the id of the post they were attached to**
  (`files/<post-id>/…`, `images/<post-id>/…`) with their original, clean
  filenames. Because different **versions** of a same-named file are almost
  always posted in different replies, they land in different post folders and
  never overwrite each other. If two different attachments in the *same* post
  share a name, the second gets a ` (2)` suffix.
- Inline screenshots become `![alt](images/…)`, file attachments become
  `[name](files/…)` links. Spaces in link targets are percent-encoded so the
  links work in any Markdown renderer.

## Resuming

Re-running skips any topic whose `index.md` already exists (and any attachment
already on disk), so a large forum can be backed up over multiple runs, or
resumed after an interruption. Use `--force` to re-fetch.

## Requirements & notes

- Python 3 standard library only — no external packages.
- The site is behind Cloudflare; this tool talks to it over plain HTTP and
  assumes the running host's public IP is allow-listed at Cloudflare. If you
  start getting HTML "Just a moment…" challenge pages instead of content, the
  allow-list is no longer in effect.
