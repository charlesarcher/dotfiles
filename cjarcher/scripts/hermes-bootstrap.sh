#!/usr/bin/env bash
# Bootstrap Hermes durable state from the wiki repo's backed-up copy.
# Run on a fresh machine AFTER cloning charlesarcher/llm-wiki to ~/wiki.
# It symlinks memory + skills from ~/wiki/aux/hermes into ~/.hermes so the agent
# shares state across machines. Secrets (auth.json/.env) are NOT here — re-auth locally.
set -euo pipefail

WIKI_AUX="${WIKI_AUX:-$HOME/wiki/aux/hermes}"
HERMES="${HERMES:-$HOME/.hermes}"
MEM="$HERMES/memories"
SKILLS="$HERMES/skills"

mkdir -p "$MEM"

# Memory (file symlink)
SRC_MEM="$WIKI_AUX/memories/MEMORY.md"
if [ -f "$SRC_MEM" ]; then
  ln -sf "$SRC_MEM" "$MEM/MEMORY.md"
  echo "linked memory -> $SRC_MEM"
else
  echo "warn: $SRC_MEM not found (clone llm-wiki first)" >&2
fi

# Skills (dir symlink — whole tree shared)
SRC_SKILLS="$WIKI_AUX/skills"
if [ -d "$SRC_SKILLS" ]; then
  # backup any existing skills dir, then symlink
  [ -e "$SKILLS" ] && [ ! -L "$SKILLS" ] && mv "$SKILLS" "$SKILLS.local.bak.$(date +%s)"
  ln -sfn "$SRC_SKILLS" "$SKILLS"
  echo "linked skills -> $SRC_SKILLS"
else
  echo "warn: $SRC_SKILLS not found" >&2
fi

# Config: copy (do not clobber machine-specific secrets); user merges manually
SRC_CFG="$WIKI_AUX/config.yaml"
if [ -f "$SRC_CFG" ] && [ ! -f "$HERMES/config.yaml" ]; then
  cp "$SRC_CFG" "$HERMES/config.yaml"
  echo "copied config.yaml (merge secrets manually if needed)"
fi

echo "Hermes bootstrap done. Re-auth Hermes locally (gh / provider token)."
