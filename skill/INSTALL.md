# Installing the Indicore Reader skill

The skill lives in `skills/indicore-reader/`. It is a standard Agent Skill — a `SKILL.md` plus a
`references/` and `assets/` folder — and needs no build step or dependencies.

## Option A — Claude Code (project skill)

Copy the skill into your project's `.claude/skills/` directory:

```bash
mkdir -p .claude/skills
cp -r skills/indicore-reader .claude/skills/
```

It is now available in that project. Claude will consult it automatically when you hand it Indicore
Lua and ask to port/convert/understand it. You can also invoke it explicitly with
`/indicore-reader` if your setup exposes skills as slash commands.

## Option B — Claude Code (personal skill, all projects)

```bash
mkdir -p ~/.claude/skills
cp -r skills/indicore-reader ~/.claude/skills/
```

## Option C — Claude.ai / Claude Desktop (uploaded skill)

Zip the skill folder and upload it wherever your Claude client accepts custom skills:

```bash
cd skills && zip -r indicore-reader.zip indicore-reader && cd ..
```

Then add `indicore-reader.zip` through your client's skill/upload UI.

## Verifying it works

Give Claude an Indicore `.lua` file and ask, for example:

> Port this fxcodebase indicator to a platform-neutral spec.

Claude should recognise the Indicore code, read the relevant files under
`skills/indicore-reader/references/`, and return a filled-in Port Specification. If it doesn't pick
the skill up automatically, mention "Indicore" or "fxcodebase" explicitly, or invoke it by name.

## Updating

Re-copy the folder after pulling changes. Nothing is cached or compiled; the Markdown files are read
directly.

## Notes

- The skill is fully **self-contained** — it does not require the original Indicore SDK docs at
  runtime; everything it needs is in `references/`.
- No network access, API keys, or external tools are needed.
