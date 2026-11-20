#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPLACE=0
DEST=""

usage() {
  cat <<'HELP'
Install Nano Prompt Studio and its eight role skills for Codex.

Usage:
  ./install.sh [--replace] [--dest PATH]

Options:
  --replace     Back up and replace existing folders with these skill names.
  --dest PATH   Install into a specific skills directory.
  -h, --help    Show this help.
HELP
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --replace)
      REPLACE=1
      shift
      ;;
    --dest)
      [ "$#" -ge 2 ] || { usage >&2; exit 2; }
      DEST=$2
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown option: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [ -z "$DEST" ]; then
  if [ -n "${CODEX_HOME:-}" ]; then
    DEST="$CODEX_HOME/skills"
  elif [ -d "$HOME/.agents/skills" ]; then
    DEST="$HOME/.agents/skills"
  elif [ -d "$HOME/.codex/skills" ]; then
    DEST="$HOME/.codex/skills"
  else
    DEST="$HOME/.agents/skills"
  fi
fi

SKILLS='nano-prompt-studio
nano-scene-analyzer
nano-camera-analyzer
nano-lighting-analyzer
nano-pose-analyzer
nano-styling-analyzer
nano-props-analyzer
nano-finish-analyzer
nano-continuity-auditor'

mkdir -p "$DEST"

if [ "$REPLACE" -eq 0 ]; then
  for skill in $SKILLS; do
    if [ -e "$DEST/$skill" ]; then
      printf 'Already exists: %s\nRun again with --replace after reviewing the existing copy.\n' "$DEST/$skill" >&2
      exit 1
    fi
  done
fi

BACKUP=""
if [ "$REPLACE" -eq 1 ]; then
  BACKUP="$DEST/.nano-prompt-studio-backup-$(date '+%Y%m%d-%H%M%S')"
fi

for skill in $SKILLS; do
  SOURCE="$SCRIPT_DIR/.agents/skills/$skill"
  [ -f "$SOURCE/SKILL.md" ] || { printf 'Missing skill: %s\n' "$SOURCE" >&2; exit 1; }
  if [ -e "$DEST/$skill" ]; then
    mkdir -p "$BACKUP"
    mv "$DEST/$skill" "$BACKUP/$skill"
  fi
  cp -R "$SOURCE" "$DEST/$skill"
done

printf 'Installed nine skills to: %s\n' "$DEST"
if [ -n "$BACKUP" ] && [ -d "$BACKUP" ]; then
  printf 'Previous copies saved to: %s\n' "$BACKUP"
fi
printf 'Open a new Codex session to discover the skills.\n'
