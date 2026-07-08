# FXCodeBase Archive

An archive of the **now-defunct** [fxcodebase.com](https://fxcodebase.com)
developer resources. The site was the community hub for custom indicators and
strategies for the **FXCM Trading Station / Marketscope** trading client — this
archive preserves the **Indicore SDK** documentation and offline copies of the
community forums (custom indicators, signals, and strategies), with every
indicator, strategy, and screenshot saved alongside the discussion.

> **License.** All archived content — the forum posts and every attached
> indicator, strategy, and script — is released under the
> [GNU General Public License (GPL)](https://www.gnu.org/licenses/gpl-3.0.html).

## Indicore SDK Documentation

📘 **[The Indicore SDK — User Guide & Reference](help/web-content.html)**

The full SDK guide and API reference for writing FXCM/Trading Station
indicators and strategies in Lua (and JavaScript).

## Indicore SDK Binaries

💾 **[Indicore SDK 3.4.0 installer (Windows)](bin/IndicoreSDK3-3.4.0.exe)**

The SDK binaries are archived under [`bin/`](bin/) alongside the documentation
above — the installer bundles the Indicore runtime and tooling for building and
testing indicators and strategies offline.

## Porting Indicators & Strategies — the Indicore Reader Skill

🛠️ **[Indicore Reader — a Claude skill for understanding fxcodebase Lua](skill/README.md)**

Because the platform is gone, the value in these thousands of indicators and
strategies is in **porting them to platforms that still exist**. This repository
bundles a [Claude Agent Skill](https://docs.claude.com/en/docs/claude-code/skills)
that teaches a coding agent to read and fully understand Indicore Lua — its
non-obvious semantics (streams that don't start at index 0, the `.DATA`
convention, live-vs-closed-bar shifts, the `Ext*` signal framework, `valuemap`
trading) — and turn it into a platform-neutral **port specification** (or an
annotated copy of the source) for reimplementation in Python, C#, Pine Script,
NinjaTrader, MQL, and the like. Hand it any `.lua` file from the backups below.

## Forum Backups

Each forum below is archived as one folder per topic (thread); every thread is a
single Markdown page with its messages, and all attached indicators, strategies,
and screenshots are downloaded next to it.

| Forum | Topics | Browse |
|-------|-------:|--------|
| **Custom Indicators (Lua)** | 3541 | [index](backup/custom-indicators/forum.md) |
| **Custom Signals (Lua)** | 105 | [index](backup/custom-signals/forum.md) |
| **Custom Strategies (Lua)** | 1203 | [index](backup/custom-strategies/forum.md) |
| **JavaScript Indicators and Strategies** | 842 | [index](backup/javascript-indicators-and-strategies/forum.md) |
| **MT4 Expert Advisors** | 3251 | [index](backup/mt4-expert-advisors/forum.md) |

Each forum's `forum.md` links to every topic in that forum.

---

*Archived from the original server-rendered fxcodebase.com forums, which are no
longer online. All content is released under the GPL license.*

*Source & tooling:
[github.com/gehtsoft-usa/fxcodebase-backup](https://github.com/gehtsoft-usa/fxcodebase-backup).*
