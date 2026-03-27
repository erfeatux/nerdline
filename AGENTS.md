# Agent Guidelines for nerdline

This document provides guidelines for agents working on the nerdline codebase.

## Project Overview

nerdline is a pure Bash powerline-style prompt generator with no external dependencies.
- **nerdline.sh** - Main entry point
- **lib/functions.sh** - Shared utilities (error, colors, config)
- **segments/** - Prompt segments (git, python, user, hostname, etc.)
- **modules/** - Optional extensions (ssh, sudo, win_title)

## Build, Lint, and Test Commands

```bash
# Run full configuration and integrity check
./nerdline.sh test

# Run all tests (unit, segments, modules, integration)
./nerdline.sh tests

# Test a single segment (e.g., git)
./segments/git.sh test

# Test a single module (e.g., ssh)
./modules/ssh.sh test

# Test a single module (e.g., win_title)
./modules/win_title.sh test

# Reload configuration after changes
nerdline update
nerdline update -f  # Force reload config

# Lint with shellcheck
shellcheck nerdline.sh lib/functions.sh segments/*.sh modules/*.sh
```

## Code Style Guidelines

### File Header Template

Every new file MUST include this header:

```bash
#!/bin/env bash

# Nerdline
# Copyright (C) 2026 Eduard Litovskikh (nicknames: Erfea, Yumi Cyannis; mail: erfea.tux at gmail)
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# shellcheck disable=SC1091,SC2001,SC2154
```

### General Rules
- **Shebang**: `#!/bin/env bash`
- **Shellcheck directives**: Include at file top: `# shellcheck disable=SC1091,SC2001,SC2154`
- **Indentation**: Use tabs (not spaces) - THIS IS CRITICAL
- **Line Length**: Under 120 characters when practical

### Naming Conventions
- **Global Variables**: Prefix with `__nerdline_` (e.g., `__nerdline_segments`, `__nerdline_git_color_fg`)
- **Temporary Variables**: Use `__nerdline_tmp_` prefix
- **Functions**: `__nerdline_<feature>_<action>` (e.g., `__nerdline_git_update`)
- **Segment/Module Names**: Lowercase, no special characters
- **Test Functions**: `test_<description>` prefix

### Function Definition Style

```bash
function function_name()
{
	local arg1="$1"
	local arg2="$2"

	if [[ condition ]]; then
		# code
	fi
}
```

### Variable Declarations
- ALWAYS declare local variables with `local`:
  ```bash
  local branch
  local add=0
  local result=""
  ```
- Use quotes for strings: `local name="$1"`
- Initialize empty strings: `local result=""`

### Conditionals
- Prefer `[[ ]]` over `[ ]`
- Use `==` for string comparison, `-eq`, `-lt` for arithmetic
- Always quote variables: `[[ -n "$var" ]]` not `[[ -n $var ]]`

### Error Handling
- Use `error` function from `lib/functions.sh` (codes 1-253 valid, 254 reserved):
  ```bash
  source "$__nerdline_pfx/lib/functions.sh" error
  error 1 "Error message"
  ```
- Use `error-sourcing` variant when returning instead of exiting

### Color Configuration
- **Hex**: `#ff0000`, `#f00` (short form)
- **RGB**: `255:0:0` or `255,0,0`
- **RGBA**: `255:0:0:255` (alpha ignored)

## File Structure for Segments

```bash
#!/bin/env bash

# Nerdline
# Copyright (C) 2026 Eduard Litovskikh (nicknames: Erfea, Yumi Cyannis; mail: erfea.tux at gmail)
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# shellcheck disable=SC1091,SC2154

source "$__nerdline_pfx/lib/functions.sh" colors

#Definition of undefined colors and vars
if [[ -z $__nerdline_<segment>_color_fg ]]
then
	__nerdline_<segment>_color_fg='#00ff00'
fi

##################################################################
if [[ $1 == test ]] #############################################
then #Test (use it before sourcing file) #########################
	source "$__nerdline_pfx/lib/functions.sh" error
	# Validate colors, signs, etc.

##################################################################
elif [[ ${BASH_SOURCE[0]} != "$0" ]] #############################
then #Sourcing this file #########################################
	__nerdline_tmp_parseColors "${!__nerdline_<segment>_color_@}"
	export "${!__nerdline_<segment>_@}"

	function __nerdline_<segment>_update()
	{
		# Update prompt segment logic
	}
fi
```

## File Structure for Modules

Similar to segments, may include additional actions (e.g., `connect` for SSH).

### win_title Module

The `win_title` module sets the terminal window title using OSC 2 escape sequences.

**Actions:**
- `test` - Configuration validation
- `run [cmd]` - Set window title for given command or BASH_COMMAND

**Features:**
- Uses DEBUG trap to capture commands before execution
- Sets title immediately when command is entered
- Supports customizable format with placeholders
- Shows shell name when no command has been executed yet

**Configuration:**
- `__nerdline_win_title_enabled` - Enable/disable (default: 1)
- `__nerdline_win_title_format` - Format string with placeholders

**Placeholders:**
| Placeholder | Description |
|------------|-------------|
| `%CMD` | Current command |
| `%ARGS` | Command arguments only |
| `%BASECMD` | Command basename (without path) |
| `%PWD` | Full directory path |
| `%BASEPWD` | Directory name only |
| `%HOME` | Home directory with tilde |
| `%SHORTPWD` | Path with tilde for home |
| `%USER` | Username |
| `%HOSTNAME` | Full hostname |
| `%HOSTSHORT` | Hostname without domain |
| `%SHELLNAME` | Shell name (bash/zsh/fish) |
| `%SHELLVERSION` | Shell version |
| `%TIME` | Current time (HH:MM:SS) |
| `%DATE` | Current date (YYYY-MM-DD) |
| `%JOBS` | Background jobs count |
| `%EXITCODE` | Last command exit code |

**Default format:** `%USER@%HOSTSHORT: %CMD`

**Behavior:**
- When terminal opens (no command yet): shows shell name (e.g., `bash`)
- When entering a command: title is set immediately to the command
- After command completes: title remains as the executed command

## File Structure for Tests

```bash
#!/bin/env bash

# Nerdline
# Copyright (C) 2026 Eduard Litovskikh (nicknames: Erfea, Yumi Cyannis; mail: erfea.tux at gmail)
# ... (full header)

# shellcheck disable=SC1091,SC2001,SC2154

__nerdline_pfx="/home/erfea/Projects/nerdline"

source "$__nerdline_pfx/tests/test_lib.sh"

function test_functionality_name()
{
	local input="test value"
	local expected="expected result"
	local actual

	actual="$(some_function "$input")"
	nerdline_test_assert "Description of test" "$expected" "$actual"
}

__nerdline_test_init

nerdline_test_run "Test Group Name" test_functionality_name

__nerdline_test_summary
```

## Import Pattern

```bash
source "$__nerdline_pfx/lib/functions.sh" colors
source "$__nerdline_pfx/lib/functions.sh" error
source "$__nerdline_pfx/lib/functions.sh" error-sourcing
```

## Configuration File Format

INI-like format with section headers `[section]`, key=value pairs, `#` comments.

## Common Tasks

### Adding a New Segment
1. Create `segments/<name>.sh` following the file structure
2. Add segment to default list in `nerdline.sh`
3. Test with `./segments/<name>.sh test`

### Adding a New Test
1. Create `tests/<category>/test_<name>.sh`
2. Use test_lib.sh framework
3. Test will be auto-discovered by `./nerdline.sh tests`

### Debugging
```bash
bash -x ./nerdline.sh test
echo "$PS1" | cat -v
```