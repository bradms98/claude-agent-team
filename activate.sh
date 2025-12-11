#!/bin/bash

# Claude Agent Team - Activate Script
# Activates this agent team by copying agent files to ~/.claude/agents/
# (Symlinks don't work due to Claude Code bug - see GitHub issues #764, #4626)
# Any existing agents are moved to ~/.claude/agents.stash/

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

echo -e "${CYAN}Claude Agent Team - Activate${NC}"
echo "=============================="
echo ""
echo "Team: $TEAM_NAME"
echo "Source: $SCRIPT_DIR"
echo ""

# Check if a team is already active
if [ -f "$ACTIVE_MARKER" ]; then
    CURRENT_TEAM=$(cat "$ACTIVE_MARKER")
    if [ "$CURRENT_TEAM" = "$SCRIPT_DIR" ]; then
        echo -e "${YELLOW}This team is already active.${NC}"
        exit 0
    fi
    echo -e "${YELLOW}Another team is currently active: $(basename "$CURRENT_TEAM")${NC}"
    echo "Run 'deactivate.sh' in that team's directory first, or use --force"
    if [ "$1" != "--force" ]; then
        exit 1
    fi
    echo -e "${YELLOW}Force flag detected, deactivating current team...${NC}"
    if [ -f "$CURRENT_TEAM/deactivate.sh" ]; then
        "$CURRENT_TEAM/deactivate.sh" --quiet
    fi
fi

# Create directories if they don't exist
mkdir -p "$AGENTS_DIR"
mkdir -p "$STASH_DIR"

# Stash any existing agents that aren't from this team
echo "Checking for existing agents to stash..."
STASHED=0
shopt -s nullglob
for agent in "$AGENTS_DIR"/*.md; do
    if [ -f "$agent" ]; then
        name="$(basename "$agent")"
        # Check if this file was installed by this team (has our marker comment)
        if grep -q "^<!-- installed-from: $SCRIPT_DIR -->" "$agent" 2>/dev/null; then
            # Already our file, skip
            continue
        fi
        # Also skip symlinks pointing to this repo (legacy support)
        if [ -L "$agent" ]; then
            link_target="$(readlink "$agent")"
            if [[ "$link_target" == "$SCRIPT_DIR"* ]]; then
                continue
            fi
        fi
        # Move to stash
        mv "$agent" "$STASH_DIR/$name"
        echo -e "  ${YELLOW}→${NC} Stashed: $name"
        STASHED=$((STASHED + 1))
    fi
done

if [ $STASHED -gt 0 ]; then
    echo -e "  ${YELLOW}$STASHED agents stashed to ~/.claude/agents.stash/${NC}"
    echo ""
fi

# Function to copy agent file with source marker
install_agent() {
    local source="$1"
    local target="$2"
    local name="$(basename "$source")"

    # Remove existing file (symlink or regular file)
    if [ -e "$target" ] || [ -L "$target" ]; then
        rm "$target"
    fi

    # Check if file has YAML frontmatter (starts with ---)
    if head -1 "$source" | grep -q "^---"; then
        # Insert marker after the closing --- of frontmatter
        # Find line number of second --- (closing frontmatter)
        local close_line=$(awk '/^---/{n++; if(n==2) {print NR; exit}}' "$source")
        if [ -n "$close_line" ]; then
            # Copy frontmatter, add marker as YAML comment, then rest of file
            head -n "$close_line" "$source" > "$target"
            echo "# installed-from: $SCRIPT_DIR" >> "$target"
            tail -n +"$((close_line + 1))" "$source" >> "$target"
        else
            # Fallback: just copy the file if we can't find closing ---
            cp "$source" "$target"
        fi
    else
        # No frontmatter: prepend HTML comment marker
        {
            echo "<!-- installed-from: $SCRIPT_DIR -->"
            cat "$source"
        } > "$target"
    fi

    echo -e "  ${GREEN}✓${NC} $name"
}

# Install core agents
echo "Activating core agents..."
for agent in "$SCRIPT_DIR/agents/core"/*.md; do
    if [ -f "$agent" ]; then
        name="$(basename "$agent")"
        install_agent "$agent" "$AGENTS_DIR/$name"
    fi
done

# Install specialist agents
echo ""
echo "Activating specialist agents..."
for agent in "$SCRIPT_DIR/agents/specialists"/*.md; do
    if [ -f "$agent" ]; then
        name="$(basename "$agent")"
        install_agent "$agent" "$AGENTS_DIR/$name"
    fi
done

# Mark this team as active
echo "$SCRIPT_DIR" > "$ACTIVE_MARKER"

# Summary
echo ""
echo -e "${GREEN}Team '$TEAM_NAME' is now active!${NC}"
echo ""
echo "Active agents:"
for agent in "$AGENTS_DIR"/*.md; do
    echo "  $(basename "$agent")"
done

echo ""
echo "To deactivate:"
echo "  cd $SCRIPT_DIR && ./deactivate.sh"
echo ""
