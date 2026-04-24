# Goodz Site Draft — Claude Code Instructions

## Git commands

Never use compound `cd && git` commands — they trigger a hardcoded security prompt about bare repository attacks that can't be bypassed.

Instead, use one of:
- `git -C <path> <command>` (preferred for one-offs)
- A standalone `cd` first, then plain `git` commands in subsequent calls

**Bad:**
```bash
cd ~/Projects/Goodz/site-draft && git add . && git commit -m "..."
```

**Good:**
```bash
git -C ~/Projects/Goodz/site-draft add .
git -C ~/Projects/Goodz/site-draft commit -m "..."
```
