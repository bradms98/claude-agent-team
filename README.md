# Claude Agent Team

A modular team of specialized AI agents that work together on complex software projects. The team mirrors a real development organization with an orchestrator delegating to specialists.

## Team Structure

### Core Team (Always Active)

| Agent | Responsibility |
|-------|----------------|
| **Orchestrator** | Project management, task breakdown, delegation, conflict resolution |
| **Engineer** | Code implementation, feature development, bug fixes |
| **Reviewer** | Code quality, best practices, architecture alignment |
| **Security** | OWASP Top 10, secrets detection, vulnerability scanning |
| **QA Tester** | Testing, edge cases, regression, bug reporting |

### Specialists (Activated as Needed)

| Agent | When to Activate |
|-------|------------------|
| **Tech Writer** | Public APIs, complex systems, documentation needs |
| **Product Owner** | PRD exists, complex requirements, scope concerns |
| **DevOps** | CI/CD, Docker, deployment, infrastructure |
| **Performance** | Optimization, profiling, load concerns |
| **Accessibility** | User-facing features, WCAG compliance |

## Installation

### Activate the Team

```bash
# Clone the repository
git clone https://github.com/bradms98/claude-agent-team.git

# Activate this team
cd claude-agent-team
./activate.sh
```

This will:
- Stash any existing agents in `~/.claude/agents.stash/`
- Symlink this team's agents to `~/.claude/agents/`
- Mark this team as active

### Deactivate the Team

```bash
cd claude-agent-team
./deactivate.sh
```

This will:
- Remove this team's symlinks
- Restore any previously stashed agents

### Switching Between Teams

You can maintain multiple team configurations and switch between them:

```bash
# You have two teams:
# ~/git/claude-agent-team/        (standard team)
# ~/git/claude-agent-team-lite/   (minimal team)

# Activate standard team
cd ~/git/claude-agent-team
./activate.sh

# Later, switch to lite team
cd ~/git/claude-agent-team-lite
./activate.sh --force   # Deactivates current team first
```

### Verify Active Team

```bash
cat ~/.claude/agents/.active-team
# Shows path to currently active team

ls ~/.claude/agents/
# Lists active agents
```

## Usage

### Basic Workflow

1. **Start a task** with the Orchestrator:
   > "I need to add user authentication to my app"

2. **Orchestrator** breaks down the task and delegates to specialists

3. **Specialists** work and produce summary/detail reports

4. **Orchestrator** synthesizes results and reports back

### Invoking Agents

In Claude Code, reference agents by name:
- "Use the Engineer agent to implement this feature"
- "Have Security review this code"
- "Run QA tests on the changes"

### Reading Reports

Reports are stored in your project:
```
{project}/.claude/reports/{task-id}/
├── engineer-summary.md      # Quick overview
├── engineer-detail.md       # Full details
├── reviewer-summary.md
├── reviewer-detail.md
├── security-summary.md
├── security-detail.md
├── qa-summary.md
├── qa-detail.md
└── orchestrator-synthesis.md  # Combined summary
```

## Design Principles

1. **Opinionated but not obstinate** - Agents flag concerns but accept decisions when overruled with reasoning

2. **Modular composition** - Core team always active; specialists activated per-project

3. **Context efficiency** - Orchestrator stays high-level; specialists handle details

4. **Always delegate** - Every task goes through the team workflow for consistency

5. **Dual-file reporting** - Summary for quick scans, detail for deep-dives

6. **Framework agnostic** - Base agents work with any tech stack; project PRD/CLAUDE.md specifies frameworks

## Configuring for Your Project

### Tech Stack

Specify your tech stack in your project's `CLAUDE.md` or PRD:

```markdown
## Tech Stack
- Frontend: React 18, TypeScript, TailwindCSS
- Backend: Python 3.11, FastAPI, SQLAlchemy
- Database: PostgreSQL 15
- Testing: Pytest, React Testing Library
- Deployment: Docker, AWS ECS
```

The Orchestrator will include this context when delegating tasks.

### Activating Specialists

Add notes to your project's `CLAUDE.md` about which specialists to use:

```markdown
## Agent Configuration
- Always use: Orchestrator, Engineer, Reviewer, Security, QA
- Use when needed: Tech Writer (we have public APIs), DevOps (Docker deploys)
- Skip: Accessibility (internal tool), Performance (not performance-critical)
```

## Updating

```bash
cd ~/git/claude-agent-team
git pull
./deactivate.sh
./activate.sh
```

## A/B Testing Teams

To experiment with different team configurations:

1. Clone this repo to a new directory:
   ```bash
   cp -r claude-agent-team claude-agent-team-v2
   ```

2. Modify agent definitions in the copy

3. Switch between teams using activate/deactivate:
   ```bash
   # Test v2
   cd ~/git/claude-agent-team-v2
   ./activate.sh --force

   # Switch back to original
   cd ~/git/claude-agent-team
   ./activate.sh --force
   ```

## File Structure

```
claude-agent-team/
├── README.md              # This file
├── CLAUDE.md              # Instructions for Claude
├── activate.sh            # Activate this team
├── deactivate.sh          # Deactivate this team
├── agents/
│   ├── core/
│   │   ├── orchestrator.md
│   │   ├── engineer.md
│   │   ├── reviewer.md
│   │   ├── security.md
│   │   └── qa-tester.md
│   └── specialists/
│       ├── tech-writer.md
│       ├── product-owner.md
│       ├── devops.md
│       ├── performance.md
│       └── accessibility.md
├── templates/
│   └── report-templates.md
└── examples/              # (Future: usage examples)
```

## Contributing

1. Fork the repository
2. Make changes to agent definitions
3. Test with Claude Code
4. Submit a pull request

## License

MIT License - Use freely, modify as needed.
