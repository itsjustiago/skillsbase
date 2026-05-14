# Setup — see setup.sh

This file used to contain a long manual plugin-install walkthrough from an older,
heavier setup (40+ plugins). That approach is **obsolete** — it contradicts the
current lean-core design.

## New machine setup

```bash
git clone https://github.com/itsjustiago/skillsbase.git
cd skillsbase
bash setup.sh
```

`setup.sh` installs the 8-plugin lean core, the global skills, the slash commands,
and the global configs. It's idempotent — safe to re-run.

Full details: **[`README.md`](../README.md) → 🚀 New machine setup**.

After `setup.sh`:
- MCP servers → [`setup/mcps.md`](mcps.md)
- Optional CLIs (graphify, browser-harness) → [`setup/install-extras.md`](install-extras.md)
- Reconcile an existing machine → `bash sync.sh`
