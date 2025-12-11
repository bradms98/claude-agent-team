# Report Templates

Standard templates for agent output files. Each agent produces two files per task: a summary and a detail file.

---

## Directory Structure

Reports are stored per-project, per-task:

```
{project}/.claude/reports/
├── {task-id}/
│   ├── engineer-summary.md
│   ├── engineer-detail.md
│   ├── reviewer-summary.md
│   ├── reviewer-detail.md
│   ├── security-summary.md
│   ├── security-detail.md
│   ├── qa-summary.md
│   ├── qa-detail.md
│   └── orchestrator-synthesis.md
└── ...
```

---

## Summary File Template

Summary files are for the Orchestrator. They should be concise bullet points that can be quickly scanned.

```markdown
# [Agent Name] Summary - Task #{task-id}

## Status: COMPLETE | IN_PROGRESS | BLOCKED

## Key Findings
- Finding 1
- Finding 2

## Issues Found
- [SEVERITY] Brief description
- [SEVERITY] Brief description

## Recommendations
- Action item 1
- Action item 2

## Blockers (if any)
- What's blocking progress
```

### Status Values

| Agent | Possible Status Values |
|-------|----------------------|
| Engineer | COMPLETE, IN_PROGRESS, BLOCKED |
| Reviewer | APPROVED, APPROVED_WITH_NOTES, CHANGES_REQUESTED, BLOCKED |
| Security | PASS, ISSUES_FOUND, CRITICAL_BLOCK |
| QA | PASS, FAIL, BLOCKED |
| Orchestrator | COMPLETE, IN_PROGRESS, BLOCKED |

---

## Detail File Template

Detail files are for deep-dives and human review. They contain full context, code snippets, and reasoning.

```markdown
# [Agent Name] Detailed Report - Task #{task-id}

## Task Description
[Full description of what was requested]

## Work Performed
[Detailed description of what was done]

## Files Modified
- `path/to/file.ts:123` - Description of change

## Code Analysis
[Full code snippets, before/after comparisons]

## Reasoning
[Why decisions were made, alternatives considered]

## Evidence
[Screenshots, logs, test output, profiling data]
```

---

## Orchestrator Synthesis Template

The Orchestrator creates a synthesis file that combines all agent summaries.

```markdown
# Orchestrator Synthesis - Task #{task-id}

## Status: COMPLETE | IN_PROGRESS | BLOCKED

## Summary
[2-3 sentence overview of what was accomplished]

## Tasks Completed
- [x] Task 1 - Completed by Engineer
- [x] Task 2 - Completed by QA
- [ ] Task 3 - Blocked (see below)

## Agent Reports

### Engineer
[Key points from engineer-summary.md]

### Reviewer
[Key points from reviewer-summary.md]

### Security
[Key points from security-summary.md]

### QA
[Key points from qa-summary.md]

## Conflicts Resolved
- Issue: [description]
- Resolution: [how it was resolved]

## Open Items
- Item requiring user decision
- Blocked task with reason

## Recommendations
1. Immediate action items
2. Future considerations
```

---

## Severity Levels

### Reviewer Severity

| Level | Meaning |
|-------|---------|
| CRITICAL | Bug that will cause failures, data corruption, security issues |
| WARNING | Code smell, potential bug, maintainability concern |
| SUGGESTION | Improvement opportunity, style preference |

### Security Severity

| Level | Meaning |
|-------|---------|
| CRITICAL | Exploitable vulnerability, leaked secrets |
| HIGH | Security weakness, missing validation |
| MEDIUM | Suboptimal security pattern |
| LOW | Hardening opportunity |

### QA Severity (Bugs)

| Level | Meaning |
|-------|---------|
| CRITICAL | System crash, data loss, blocks all users |
| HIGH | Major feature broken, no workaround |
| MEDIUM | Feature impaired, workaround exists |
| LOW | Minor issue, cosmetic, edge case |

---

## Task ID Convention

Task IDs should be descriptive and unique:

```
{type}-{short-description}-{date}
```

Examples:
- `feat-user-auth-20240115`
- `fix-login-bug-20240116`
- `refactor-api-routes-20240117`

---

## File Naming Convention

```
{agent}-{type}.md
```

Where:
- `agent`: orchestrator, engineer, reviewer, security, qa, tech-writer, product-owner, devops, performance, accessibility
- `type`: summary or detail

Examples:
- `engineer-summary.md`
- `security-detail.md`
- `orchestrator-synthesis.md` (special case for orchestrator)
