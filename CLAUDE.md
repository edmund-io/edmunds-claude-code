# CLAUDE.md - Repository Guide for AI Assistants

This document provides comprehensive guidance for AI assistants working with this Claude Code plugin repository. It explains the codebase structure, development workflows, and key conventions to follow.

## Table of Contents

1. [Repository Overview](#repository-overview)
2. [Directory Structure](#directory-structure)
3. [Plugin Architecture](#plugin-architecture)
4. [Development Workflows](#development-workflows)
5. [Key Conventions](#key-conventions)
6. [File Format Specifications](#file-format-specifications)
7. [Best Practices](#best-practices)
8. [Testing and Validation](#testing-and-validation)

---

## Repository Overview

**Project Name**: edmunds-claude-code
**Type**: Claude Code Plugin
**Purpose**: Personal productivity plugin with 14 slash commands and 11 specialized AI agents for modern web development
**Target Stack**: Next.js 15, React 19, TypeScript, Supabase, Tailwind CSS
**License**: MIT

### What This Plugin Provides

- **14 Slash Commands**: Productivity commands for development tasks
  - 7 General Development Commands (planning, optimization, cleanup, etc.)
  - 3 API Commands (creation, testing, protection)
  - 2 UI Commands (components, pages)
  - 2 Supabase Commands (types, edge functions)

- **11 Specialized AI Agents**: Context-aware agents that activate automatically
  - 5 Architecture & Planning Agents
  - 3 Code Quality & Performance Agents
  - 3 Documentation & Research Agents

- **3 MCP Servers**: Pre-configured Model Context Protocol servers
  - context7 (documentation access)
  - playwright (browser automation)
  - supabase (database operations)

---

## Directory Structure

```
edmunds-claude-code/
├── .claude/                          # Claude Code configuration
│   ├── agents/                       # AI agent definitions (11 files)
│   │   ├── backend-architect.md
│   │   ├── deep-research-agent.md
│   │   ├── frontend-architect.md
│   │   ├── learning-guide.md
│   │   ├── performance-engineer.md
│   │   ├── refactoring-expert.md
│   │   ├── requirements-analyst.md
│   │   ├── security-engineer.md
│   │   ├── system-architect.md
│   │   ├── technical-writer.md
│   │   └── tech-stack-researcher.md
│   ├── commands/                     # Slash command definitions
│   │   ├── api/                      # API-related commands
│   │   │   ├── api-new.md
│   │   │   ├── api-protect.md
│   │   │   └── api-test.md
│   │   ├── misc/                     # General development commands
│   │   │   ├── code-cleanup.md
│   │   │   ├── code-explain.md
│   │   │   ├── code-optimize.md
│   │   │   ├── docs-generate.md
│   │   │   ├── feature-plan.md
│   │   │   └── lint.md
│   │   ├── supabase/                 # Supabase-specific commands
│   │   │   ├── edge-function-new.md
│   │   │   └── types-gen.md
│   │   ├── ui/                       # UI component commands
│   │   │   ├── component-new.md
│   │   │   └── page-new.md
│   │   └── new-task.md               # Root-level task command
│   └── settings.template.json        # Template for user settings
├── .claude-plugin/                   # Plugin metadata
│   ├── marketplace.json              # Marketplace listing info
│   ├── MCP-SERVERS.md                # MCP server documentation
│   └── plugin.json                   # Plugin manifest (main config)
├── .gitignore                        # Git ignore rules
├── PUBLISHING.md                     # Publishing guide
├── QUICK-START.md                    # Quick start guide
└── README.md                         # User-facing documentation
```

### Key Directories Explained

**`.claude/agents/`**
Contains AI agent definitions that activate automatically based on user context and conversation patterns. Each agent is a specialized persona with specific expertise.

**`.claude/commands/`**
Contains slash command definitions organized by category. Commands are user-invoked via `/command-name` syntax.

**`.claude-plugin/`**
Contains plugin metadata and configuration. The `plugin.json` file is the central manifest that registers all commands, agents, and MCP servers.

---

## Plugin Architecture

### How Claude Code Plugins Work

1. **Plugin Discovery**: Claude Code reads `.claude-plugin/plugin.json` to discover available features
2. **Command Registration**: Commands in `plugin.json` are made available as `/command-name`
3. **Agent Activation**: Agents activate automatically based on conversation context (no explicit invocation)
4. **MCP Server Loading**: MCP servers are loaded and made available as tools

### Plugin Manifest Structure

The `.claude-plugin/plugin.json` file contains:

```json
{
  "name": "edmunds-claude-code",
  "version": "1.0.0",
  "description": "...",
  "author": { "name": "Edmund" },
  "license": "MIT",
  "commands": [
    {
      "id": "command-id",
      "name": "command-name",
      "path": ".claude/commands/path/to/command.md",
      "description": "Brief description"
    }
  ],
  "agents": [
    {
      "id": "agent-id",
      "name": "agent-name",
      "path": ".claude/agents/agent-name.md",
      "description": "When this agent activates"
    }
  ],
  "mcpServers": {
    "server-name": {
      "command": "npx",
      "args": ["-y", "package-name"],
      "description": "What this server provides"
    }
  }
}
```

### Command vs Agent

| Feature | Commands | Agents |
|---------|----------|--------|
| Invocation | User types `/command-name` | Automatic based on context |
| Purpose | Execute specific tasks | Provide specialized expertise |
| Format | Markdown with frontmatter | Markdown with agent definition |
| User Control | Explicit | Implicit |

---

## Development Workflows

### Adding a New Slash Command

1. **Create the command file**
   ```bash
   # Choose appropriate category directory
   touch .claude/commands/api/my-new-command.md
   ```

2. **Write the command content**
   ```markdown
   ---
   description: Brief description of what this command does
   model: claude-sonnet-4-5
   ---

   # Command instructions for Claude

   $ARGUMENTS will contain user input after the command

   ## Guidelines
   - Specific instructions
   - Expected behavior
   - Output format
   ```

3. **Register in plugin.json**
   ```json
   {
     "id": "my-new-command",
     "name": "my-new-command",
     "path": ".claude/commands/api/my-new-command.md",
     "description": "Brief description for plugin listing"
   }
   ```

4. **Test the command**
   ```bash
   /plugin reload
   /my-new-command [test arguments]
   ```

### Adding a New Agent

1. **Create the agent file**
   ```bash
   touch .claude/agents/my-agent.md
   ```

2. **Define the agent**
   ```markdown
   ---
   name: my-agent
   description: Trigger conditions - when should this agent activate?
   model: sonnet
   color: blue
   ---

   # Agent Persona and Instructions

   You are a [specialized role] with expertise in [domain].

   ## Core Responsibilities
   - Responsibility 1
   - Responsibility 2

   ## When to Activate
   - Trigger condition 1
   - Trigger condition 2

   ## Output Format
   - How to structure responses
   ```

3. **Register in plugin.json**
   ```json
   {
     "id": "my-agent",
     "name": "my-agent",
     "path": ".claude/agents/my-agent.md",
     "description": "Clear description of activation triggers"
   }
   ```

4. **Test activation**
   - Create scenarios that match activation triggers
   - Verify agent activates automatically
   - Check agent provides expected expertise

### Adding an MCP Server

1. **Add to plugin.json**
   ```json
   "mcpServers": {
     "new-server": {
       "command": "npx",
       "args": ["-y", "@scope/package-name"],
       "description": "What capabilities this server provides"
     }
   }
   ```

2. **Document in MCP-SERVERS.md** (if file exists)

3. **Test the server**
   ```bash
   /plugin reload
   # Use server-provided tools in conversation
   ```

### Modifying Existing Commands/Agents

1. **Edit the markdown file** directly in `.claude/commands/` or `.claude/agents/`
2. **Reload the plugin** with `/plugin reload` (if available)
3. **Test changes** by invoking the command or triggering the agent
4. **Commit changes** with clear commit messages

### Version Bumping

Follow semantic versioning in `.claude-plugin/plugin.json`:

- **Patch** (1.0.X): Bug fixes, minor wording changes
- **Minor** (1.X.0): New commands/agents, backward-compatible changes
- **Major** (X.0.0): Breaking changes, major restructuring

---

## Key Conventions

### Naming Conventions

**Commands**:
- Use kebab-case: `api-new`, `code-cleanup`, `types-gen`
- Prefix with category when helpful: `api-*`, `component-*`
- Keep names short and descriptive
- Command ID should match command name

**Agents**:
- Use kebab-case: `tech-stack-researcher`, `backend-architect`
- Suffix with role type: `-architect`, `-engineer`, `-expert`, `-analyst`, `-guide`
- Name should indicate domain/expertise
- Agent ID should match agent name

**Files**:
- Commands: `{command-name}.md`
- Agents: `{agent-name}.md`
- Organize commands in subdirectories by category

### Content Conventions

**Commands should**:
- Start with frontmatter (description, model)
- Use `$ARGUMENTS` to reference user input
- Provide clear implementation guidelines
- Include examples where helpful
- Specify expected output format
- Focus on actionable instructions

**Agents should**:
- Start with frontmatter (name, description, model, color)
- Define clear activation triggers
- Establish persona and expertise
- List core responsibilities
- Specify when to seek clarification
- Define boundaries (will/won't do)

### Technology Stack Conventions

This plugin is optimized for:

- **Next.js 15** (App Router, Server Components, Server Actions)
- **React 19** (latest patterns and hooks)
- **TypeScript** (strict mode, no `any` types)
- **Supabase** (database, auth, realtime, edge functions)
- **Tailwind CSS** (utility-first styling)
- **Zod** (runtime validation)

**Always assume**:
- Modern Next.js App Router patterns (not Pages Router)
- TypeScript strict mode is enabled
- `any` type is forbidden (use `unknown` or proper types)
- Server Components by default, Client Components when needed
- API routes use Route Handlers (`app/api/*/route.ts`)

### Code Generation Standards

When commands generate code, follow these principles:

1. **Type Safety First**
   - No `any` types ever
   - Use Zod for runtime validation
   - Export types for reuse

2. **Error Handling**
   - Try/catch in all async operations
   - Consistent error response format
   - Never expose sensitive error details

3. **Next.js Patterns**
   - Server Components by default
   - Client Components only when needed (`'use client'`)
   - Server Actions for mutations
   - Route Handlers for API endpoints

4. **Security**
   - Input validation on all user data
   - SQL injection prevention (use Supabase queries properly)
   - XSS prevention (React handles by default)
   - Authentication checks before protected operations

5. **File Organization**
   - Feature-based component organization
   - Colocate related files
   - Separate utilities from components
   - Keep components focused and small

---

## File Format Specifications

### Command File Format

```markdown
---
description: Brief command description (required)
model: claude-sonnet-4-5 (optional, defaults to user's model)
---

# Command Title (optional, for readability)

Command instructions for Claude. This content becomes the prompt
when the user invokes /command-name.

Use $ARGUMENTS to reference what the user types after the command.

## Common Sections

### Requirements
What the user needs to provide or have set up.

### Implementation Guidelines
How Claude should execute the task.

### Code Structure
Expected file structure and organization.

### Best Practices
Principles to follow during execution.

### Output Format
How to present results to the user.
```

### Agent File Format

```markdown
---
name: agent-name (required, must match filename)
description: Clear activation triggers (required)
model: sonnet (optional: sonnet|opus|haiku)
color: blue (optional: visual identifier)
category: analysis (optional: for organization)
---

# Agent Title

## Triggers (optional but recommended)
- Specific scenarios when this agent should activate
- User question patterns that match this expertise
- Task types that require this specialization

## Behavioral Mindset (optional but recommended)
How this agent approaches problems. The thinking style.

## Core Responsibilities
What this agent is responsible for doing.

## Focus Areas
Key domains of expertise and what to emphasize.

## Key Actions
Step-by-step approach to tasks.

## Outputs
What deliverables this agent produces.

## Boundaries
**Will:**
- Things this agent will do

**Will Not:**
- Things this agent won't do
- When to defer to other agents/approaches
```

### Frontmatter Reference

**Command Frontmatter**:
```yaml
description: string (required) - Brief description, max ~100 chars
model: "claude-sonnet-4-5" | "claude-opus-4" | "claude-haiku-4" (optional)
```

**Agent Frontmatter**:
```yaml
name: string (required) - Must match agent ID
description: string (required) - Activation triggers and context
model: "sonnet" | "opus" | "haiku" (optional)
color: string (optional) - Visual identifier in UI
category: string (optional) - For organization
```

---

## Best Practices

### For Command Development

1. **Be Specific**: Commands should have clear, focused purposes
2. **Use Examples**: Include code examples in command instructions
3. **Set Expectations**: Define what output users should expect
4. **Handle Edge Cases**: Consider error scenarios in instructions
5. **Stay Current**: Keep Next.js/React patterns up to date
6. **Test Thoroughly**: Try commands with various inputs before committing

### For Agent Development

1. **Clear Triggers**: Make activation conditions very specific
2. **Distinct Expertise**: Each agent should have unique domain knowledge
3. **Avoid Overlap**: Minimize redundancy between agents
4. **Proactive Activation**: Good agents activate without user knowing
5. **Know Boundaries**: Define what the agent won't do
6. **Provide Structure**: Give clear output formats

### For Plugin Maintenance

1. **Semantic Versioning**: Bump versions appropriately
2. **Update All Docs**: Keep README, PUBLISHING, and this file in sync
3. **Test After Changes**: Always test commands/agents after modifications
4. **Git Hygiene**: Meaningful commit messages, logical commits
5. **Breaking Changes**: Document in version notes
6. **User Feedback**: Listen to user issues and iterate

### For Code Generation

1. **Never Use `any`**: Use `unknown` and type guards instead
2. **Validate Input**: Use Zod schemas for all external data
3. **Type Exports**: Export types for reuse across files
4. **Modern Patterns**: Use latest Next.js 15 and React 19 features
5. **Error Messages**: Clear, actionable error messages
6. **Consistent Style**: Follow established code patterns in commands

---

## Testing and Validation

### Before Committing Changes

1. **Validate JSON**: Ensure `plugin.json` and `marketplace.json` are valid
   ```bash
   # Use a JSON validator or linter
   cat .claude-plugin/plugin.json | jq . > /dev/null
   cat .claude-plugin/marketplace.json | jq . > /dev/null
   ```

2. **Check File Paths**: Verify all paths in `plugin.json` exist
   ```bash
   # All command and agent paths should resolve
   ls .claude/commands/api/api-new.md
   ls .claude/agents/tech-stack-researcher.md
   ```

3. **Test Commands**: Invoke each modified command
   ```bash
   /plugin reload  # Reload the plugin
   /command-name test arguments
   ```

4. **Test Agents**: Create scenarios that should trigger agents

5. **Verify Frontmatter**: Check YAML frontmatter syntax
   - Description is present and clear
   - Model names are correct
   - No syntax errors

### Plugin Installation Test

```bash
# From a different project directory
/plugin install /path/to/edmunds-claude-code

# Verify commands appear
/help

# Try a command
/api-new Create user endpoint

# Uninstall when done testing
/plugin uninstall edmunds-claude-code
```

### Common Issues to Check

- **Commands not appearing**: Check `plugin.json` paths and syntax
- **Agents not activating**: Review description/triggers, make them more specific
- **JSON validation errors**: Use `jq` or online JSON validator
- **Frontmatter errors**: Check YAML syntax, especially colons and quotes
- **Model errors**: Ensure model names are correct (`claude-sonnet-4-5` not `sonnet-4.5`)

---

## Working with This Repository as an AI Assistant

### When Asked to Add Features

1. **Understand the request**: Clarify what command/agent is needed
2. **Choose the right type**: Command (user-invoked) or Agent (auto-activated)?
3. **Find the right category**: API, UI, Supabase, or Misc?
4. **Follow the format**: Use the exact frontmatter and structure patterns
5. **Update plugin.json**: Add the new entry to the appropriate array
6. **Test the change**: Explain how the user can test it
7. **Update version**: Bump version if this is a releasable change

### When Asked to Modify Existing Features

1. **Read the current file**: Always read before editing
2. **Preserve format**: Keep frontmatter and structure intact
3. **Maintain consistency**: Match the style of other files
4. **Update related docs**: If changing behavior, update README if needed
5. **Test implications**: Consider impact on users

### When Asked to Debug Issues

1. **Validate JSON first**: Most issues are JSON syntax errors
2. **Check file paths**: Ensure all referenced files exist
3. **Review frontmatter**: YAML syntax is strict
4. **Test the scenario**: Try to reproduce the issue
5. **Check recent changes**: Look at git history for breaking changes

### When Asked About Plugin Structure

- **Refer to this document**: All answers should be here
- **Show examples**: Point to existing commands/agents as references
- **Explain patterns**: Help users understand the conventions
- **Suggest improvements**: Recommend better approaches when relevant

---

## Common Development Tasks

### Renaming a Command

1. Rename the `.md` file
2. Update `id`, `name`, and `path` in `plugin.json`
3. Update any documentation that references the old name
4. Bump plugin version (minor version)
5. Add migration note in release notes

### Reorganizing Commands

1. Move files to new directory structure
2. Update all `path` references in `plugin.json`
3. Verify all paths are correct
4. Test that commands still load
5. Update this document if structure changed significantly

### Deprecating a Command

1. Add deprecation notice in the command file itself
2. Keep the command functional but warn users
3. Document replacement command if applicable
4. Plan removal for next major version
5. Update README to indicate deprecation

### Adding a New Category

1. Create new subdirectory in `.claude/commands/`
2. Add commands to the new directory
3. Update `plugin.json` with new commands
4. Update README to document new category
5. Update this document's directory structure section

---

## Additional Resources

### Claude Code Documentation

- Plugin Marketplaces: https://docs.claude.com/en/docs/claude-code/plugin-marketplaces
- Slash Commands: https://docs.claude.com/en/docs/claude-code/slash-commands
- Agent Development: https://docs.claude.com/en/docs/claude-code/agents
- MCP Servers: https://docs.claude.com/en/docs/claude-code/mcp-servers

### Related Files in This Repository

- **README.md**: User-facing documentation and feature list
- **PUBLISHING.md**: Step-by-step publishing guide
- **QUICK-START.md**: Quick reference for getting started
- **plugin.json**: Central configuration manifest
- **marketplace.json**: Marketplace listing metadata

### Repository Information

- **GitHub**: https://github.com/WAOmaster/edmunds-claude-code
- **License**: MIT
- **Author**: Edmund
- **Current Version**: 1.0.0

---

## Version History

### 1.0.0 - Initial Release
- 14 slash commands across 4 categories
- 11 specialized AI agents
- 3 pre-configured MCP servers
- Optimized for Next.js 15, React 19, TypeScript, Supabase

---

**Last Updated**: 2025-11-15
**Document Version**: 1.0.0

This document should be updated whenever significant changes are made to the plugin structure, conventions, or development workflows.
