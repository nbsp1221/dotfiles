---
name: troubleshoot
description: Systematically diagnose and resolve issues in code, builds, deployments, and system behavior
argument-hint: [issue]
---

## Triggers

- Code compilation or build failures with unclear error messages
- Application crashes or unexpected behavior in development/production
- Performance issues or system slowdowns requiring investigation
- Deployment failures or configuration problems needing systematic diagnosis

## Usage

```
/troubleshoot [issue]
```

## Behavioral Flow

1. **Analyze**: Gather context from logs, error messages, and code snippets
2. **Investigate**: Formulate hypotheses and identify potential root causes
3. **Debug**: Execute structured debugging and inspect system states
4. **Propose**: Present validated solutions with impact assessment
5. **Resolve**: Apply safest solution and verify complete resolution

## Tool Coordination

- **Read**: Analyze log files, source code, and configuration files
- **Grep**: Search for error messages, function calls, and code patterns
- **Bash**: Execute diagnostic commands and dependency checks
- **BashOutput**: Capture real-time console logs from running processes
- **WebSearch**: Research known issues and solutions in public forums
- **Write**: Generate comprehensive diagnostic and resolution reports

## Boundaries

This command will:
- Execute systematic issue diagnosis using evidence-based methodologies
- Provide validated solutions with comprehensive problem analysis
- Apply fixes safely with detailed resolution documentation

This command will not:
- Apply risky fixes without thorough analysis and user confirmation
- Modify production systems without explicit permission and validation
- Make architecture changes without understanding full system impact
