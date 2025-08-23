---
name: create-command
description: Create a new custom command following best practices template
argument-hint: [--name <name>] [--description <description>]
---

## Triggers

- Need to create a new slash command
- Want to follow best practices for command structure
- Setting up project-specific automation
- Building reusable workflow commands

## Usage

```
/create-command [--name <name>] [--description <description>]
/create-command --name refactor-code --description "Automatically refactor code following best practices"
/create-command --name security-scan --description "Scan codebase for security vulnerabilities"
```

## Behavioral Flow

1. **Reference**: First review Claude Code slash command documentation at https://docs.anthropic.com/en/docs/claude-code/slash-commands to ensure compliance with official standards
2. **Analyze**: Parse command name and description from $ARGUMENTS
3. **Design**: Structure the command with appropriate sections and metadata following official guidelines
4. **Generate**: Create the complete command file using the Template Structure section below
5. **Deploy**: Save to .claude/commands (project-specific) by default, or ~/.claude/commands/ if explicitly requested as personal command

## Tool Coordination

- **Read**: Check for existing commands to avoid conflicts
- **Write**: Create the new command file
- **WebFetch**: Review official Claude Code slash command documentation for latest standards
- **Bash**: Create directories if needed

## Template Structure

````markdown
---
name: [command-name]
description: [one-line description]
argument-hint: [expected arguments]
---

## Triggers

- When to use scenario 1
- When to use scenario 2
- When to use scenario 3
- When to use scenario 4

## Usage

```
/[command-name] [arguments] [--options]
```

## Behavioral Flow

1. **Step Name**: What happens
2. **Step Name**: What happens
3. **Step Name**: What happens
4. **Step Name**: What happens
5. **Step Name**: What happens

## Tool Coordination

- **Tool**: Purpose
- ...

## Boundaries

This command will:
- Action 1
- Action 2
- Action 3

This command will not:
- Restriction 1
- Restriction 2
- Restriction 3
````

## Boundaries

This command will:
- Generate well-structured command files following best practices
- Create contextually appropriate commands based on description
- Provide clear usage examples and documentation

This command will not:
- Overwrite existing commands without confirmation
- Create commands without proper boundaries section
- Generate malicious or unsafe command patterns
- Skip validation of command structure
- Create commands without clear purpose or description
