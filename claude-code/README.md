# Claude Code Commands

This directory contains custom commands for Claude Code CLI.

## Available Commands

### `/commit`

Analyzes git log to understand the project's commit convention and creates an appropriate commit message in English for the current changes.

**Features:**
- Supports Conventional Commits (`feat:`, `fix:`, etc.)
- Supports Gitmoji style (🐛, ✨, 📝, etc.)
- Automatically detects and follows existing project conventions

## Installation

### Method 1: Symbolic Link (Recommended)
```bash
ln -sf $(pwd)/claude-code/commands/commit.md ~/.claude/commands/commit.md
```

### Method 2: Direct Copy
```bash
cp claude-code/commands/commit.md ~/.claude/commands/
```

## Usage

In any project, simply use:
```
/commit
```

Claude Code will analyze your changes and generate an appropriate commit message following the project's conventions.
