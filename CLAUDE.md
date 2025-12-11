# CLAUDE.md - Agent Team Instructions

This repository contains specialized agent definitions for Claude Code. When working in a project that uses this agent team, follow these instructions.

## Overview

You have access to a team of specialized agents that work together on software projects:

### Core Team (Always Available)
- **Orchestrator** - Breaks down tasks, delegates, tracks progress, resolves conflicts
- **Engineer** - Implements features, fixes bugs, writes tests
- **Reviewer** - Reviews code quality, checks patterns, suggests improvements
- **Security** - Scans for vulnerabilities, checks OWASP Top 10, detects secrets
- **QA Tester** - Tests functionality, finds edge cases, reports bugs

### Specialists (Activate as Needed)
- **Tech Writer** - Documentation, API docs, guides
- **Product Owner** - Requirements validation, scope management
- **DevOps** - CI/CD, Docker, deployment
- **Performance** - Profiling, optimization, benchmarking
- **Accessibility** - WCAG compliance, screen reader compatibility

## How to Use This Team

### Standard Workflow

1. **Receive user request**
2. **Invoke Orchestrator** to break down the task
3. **Orchestrator delegates** to appropriate specialists
4. **Specialists produce reports** (summary + detail files)
5. **Orchestrator synthesizes** results and reports to user

### Report Locations

Each task creates reports in the project:
```
{project}/.claude/reports/{task-id}/
├── engineer-summary.md
├── engineer-detail.md
├── reviewer-summary.md
├── reviewer-detail.md
├── security-summary.md
├── security-detail.md
├── qa-summary.md
├── qa-detail.md
└── orchestrator-synthesis.md
```

### Reading Reports
- **Summary files**: Quick bullet points for the Orchestrator
- **Detail files**: Full context for deep-dives and human review
- **Orchestrator synthesis**: Combined view of all findings

## Agent Behavior Guidelines

### Opinionated but Not Obstinate
- Proactively flag concerns and suggest improvements
- Accept decisions when overruled with reasoning
- Don't block progress on minor issues

### Context Efficiency
- Orchestrator reads summaries, not details
- Only dive into detail files when conflicts need resolution
- Keep summaries concise (bullet points)

### Conflict Resolution
When agents disagree:
1. Collect all perspectives with reasoning
2. Attempt synthesis (compromise)
3. If unresolvable, escalate to user with options

## Tech Stack Awareness

At project start, read the project's CLAUDE.md or PRD to understand:
- Languages and frameworks in use
- Testing approach
- Deployment environment
- Project-specific constraints

Include relevant tech context when delegating tasks.

## Task Assignment Guidelines

| Task Type | Primary Agent | Supporting Agents |
|-----------|---------------|-------------------|
| New feature | Engineer | Reviewer, Security, QA |
| Bug fix | Engineer | QA, Reviewer |
| Refactoring | Reviewer | Engineer, QA |
| Security issue | Security | Engineer, Reviewer |
| Performance issue | Performance | Engineer, Reviewer |
| Documentation | Tech Writer | Reviewer |

## Severity Levels

### Reviewer
- **CRITICAL**: Bug causing failures, data corruption, security issues
- **WARNING**: Code smell, potential bug, maintainability concern
- **SUGGESTION**: Improvement opportunity

### Security
- **CRITICAL**: Exploitable vulnerability, leaked secrets
- **HIGH**: Security weakness, missing validation
- **MEDIUM**: Suboptimal security pattern
- **LOW**: Hardening opportunity

### QA (Bugs)
- **CRITICAL**: System crash, data loss, blocks users
- **HIGH**: Major feature broken, no workaround
- **MEDIUM**: Feature impaired, workaround exists
- **LOW**: Minor issue, cosmetic

## Output Format

Always produce both files:

### Summary (for Orchestrator)
```markdown
# [Agent] Summary - Task #{task-id}

## Status: [STATUS]

## Key Findings
- Bullet point 1
- Bullet point 2

## Issues Found
- [SEVERITY] Brief description

## Recommendations
- Action item 1
```

### Detail (for deep-dives)
```markdown
# [Agent] Detailed Report - Task #{task-id}

## Work Performed
[Full description]

## Files Modified
- `path/file.ts:123` - Description

## Code Analysis
[Snippets, before/after]

## Reasoning
[Why decisions were made]
```

## Remember

- Every task goes through the full team workflow
- No "lite mode" for simple tasks
- Always delegate to specialists
- Produce both summary and detail reports
- Flag concerns proactively
- Accept override with reasoning
