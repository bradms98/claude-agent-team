#!/bin/bash

# Claude Agent Team - Deactivate Script
# Removes this team's agent files and restores stashed agents
# (Uses marker comments to identify files installed by this team)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEAM_NAME="$(basename "$SCRIPT_DIR")"
AGENTS_DIR="$HOME/.claude/agents"
STASH_DIR="$HOME/.claude/agents.stash"
ACTIVE_MARKER="$AGENTS_DIR/.active-team"
QUIET=false

if [ "$1" = "--quiet" ]; then
    QUIET=true
fi

if [ "$QUIET" = false ]; then
    echo -e "${CYAN}Claude Agent Team - Deactivate${NC}"
    echo "================================"
    echo ""
    echo "Team: $TEAM_NAME"
    echo ""
fi

# Check if this team is actually active
if [ -f "$ACTIVE_MARKER" ]; then
    CURRENT_TEAM=$(cat "$ACTIVE_MARKER")
    if [ "$CURRENT_TEAM" != "$SCRIPT_DIR" ]; then
        if [ "$QUIET" = false ]; then
            echo -e "${YELLOW}This team is not currently active.${NC}"
            echo "Active team: $(basename "$CURRENT_TEAM")"
        fi
        exit 0
    fi
else
    if [ "$QUIET" = false ]; then
        echo -e "${YELLOW}No team is currently active.${NC}"
    fi
    exit 0
fi

# Remove files that were installed by this team (check marker comment or symlink)
REMOVED=0
shopt -s nullglob
for agent in "$AGENTS_DIR"/*.md; do
    should_remove=false

    # Check for HTML marker comment (legacy method, no frontmatter)
    if [ -f "$agent" ] && grep -q "^<!-- installed-from: $SCRIPT_DIR -->" "$agent" 2>/dev/null; then
        should_remove=true
    fi

    # Check for YAML comment marker (new method, with frontmatter)
    if [ -f "$agent" ] && grep -q "^# installed-from: $SCRIPT_DIR$" "$agent" 2>/dev/null; then
        should_remove=true
    fi

    # Also check for symlinks (legacy support)
    if [ -L "$agent" ]; then
        link_target="$(readlink "$agent")"
        if [[ "$link_target" == "$SCRIPT_DIR"* ]]; then
            should_remove=true
        fi
    fi

    if [ "$should_remove" = true ]; then
        rm "$agent"
        if [ "$QUIET" = false ]; then
            echo -e "  ${RED}✗${NC} Removed: $(basename "$agent")"
        fi
        REMOVED=$((REMOVED + 1))
    fi
done

# Remove active marker
rm -f "$ACTIVE_MARKER"

if [ "$QUIET" = false ]; then
    echo ""
    echo -e "${GREEN}Removed $REMOVED agents.${NC}"
fi

# Restore stashed agents
if [ -d "$STASH_DIR" ] && [ "$(ls -A "$STASH_DIR" 2>/dev/null)" ]; then
    if [ "$QUIET" = false ]; then
        echo ""
        echo "Restoring stashed agents..."
    fi
    RESTORED=0
    for agent in "$STASH_DIR"/*.md; do
        if [ -f "$agent" ]; then
            name="$(basename "$agent")"
            mv "$agent" "$AGENTS_DIR/$name"
            if [ "$QUIET" = false ]; then
                echo -e "  ${GREEN}←${NC} Restored: $name"
            fi
            RESTORED=$((RESTORED + 1))
        fi
    done
    if [ "$QUIET" = false ]; then
        echo -e "  ${GREEN}$RESTORED agents restored from stash.${NC}"
    fi
fi

if [ "$QUIET" = false ]; then
    echo ""
    echo -e "${GREEN}Team '$TEAM_NAME' deactivated.${NC}"
    echo ""

    # Show remaining agents if any
    remaining=("$AGENTS_DIR"/*.md)
    if [ ${#remaining[@]} -gt 0 ] && [ -e "${remaining[0]}" ]; then
        echo "Remaining agents:"
        for agent in "${remaining[@]}"; do
            echo "  $(basename "$agent")"
        done
    else
        echo "No agents currently active."
    fi
    echo ""
fi
