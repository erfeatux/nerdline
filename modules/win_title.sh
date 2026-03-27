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

# shellcheck disable=SC1091,SC2154,SC2295

##################################################################
if [[ ${1:-} == test ]] ##########################################
then #Test (use it before sourcing file) #########################
	function __nerdline_wt_test()
	{
		source "$__nerdline_pfx/lib/functions.sh" error
		source "$__nerdline_pfx/lib/functions.sh" colors

		# Validate config variables
		if [[ -z $__nerdline_pfx ]] || [[ ! -e "${__nerdline_pfx}/nerdline.sh" ]]
		then
			error 11 'Nerdline script is not found'
		fi

		# Validate format if defined
		if [[ -n ${__nerdline_win_title_format:-} ]]
		then
			if [[ ${#__nerdline_win_title_format} -gt 128 ]]
			then
				error 13 "Title format too long"
			fi
		fi

		# Validate short_pwd setting if defined
		if [[ -n ${__nerdline_win_title_short_pwd:-} ]]
		then
			local __nerdline_wt_test_short_pwd="${__nerdline_win_title_short_pwd}"
			case "$__nerdline_wt_test_short_pwd" in
				true|yes|on)
					__nerdline_wt_test_short_pwd=1
					;;
				false|no|off)
					__nerdline_wt_test_short_pwd=0
					;;
			esac
			if [[ "$__nerdline_wt_test_short_pwd" != "0" ]] && [[ "$__nerdline_wt_test_short_pwd" != "1" ]]
			then
				error 14 "short_pwd must be 0, 1, true, false, yes, no, on or off"
			fi
		fi

		return 0
	}
	__nerdline_wt_test
	exit $?


##################################################################
elif [[ ${1:-} == run ]] #########################################
then #Run: set window title based on executed command ############
	source "$__nerdline_pfx/lib/functions.sh" error

	__nerdline_wt_run()
	{
		# Get command from BASH_COMMAND or from arguments
		local __nerdline_wt_line="${1:-}"
		if [[ -z "$__nerdline_wt_line" ]]
		then
			__nerdline_wt_line="$BASH_COMMAND"
		fi

		# Parse command: skip prefix assignments and extract actual command
		# Format: [VAR=val VAR=val ...] command [args...]
		local __nerdline_wt_cmd=""

		if [[ "$__nerdline_wt_line" =~ ^([A-Za-z_][A-Za-z0-9_]*=[^[:space:]]+[[:space:]]+)+([^[:space:]]+) ]]
		then
			__nerdline_wt_cmd="${BASH_REMATCH[2]}"
		elif [[ "$__nerdline_wt_line" =~ ^([^[:space:]]+) ]]
		then
			__nerdline_wt_cmd="${BASH_REMATCH[1]}"
		fi

		# If it's sudo — get actual command after its options
		if [[ "$__nerdline_wt_cmd" == sudo ]]
		then
			# Remove "sudo" and leading options from the line
			local __nerdline_wt_rest="${__nerdline_wt_line#sudo[[:space:]]*}"

			if [[ "$__nerdline_wt_rest" =~ ^[A-Za-z_-]+[[:space:]]+([^[:space:]]+) ]]
			then
				__nerdline_wt_cmd="${BASH_REMATCH[1]}"
			elif [[ "$__nerdline_wt_rest" =~ ^([^[:space:]]+) ]]
			then
				__nerdline_wt_cmd="${BASH_REMATCH[1]}"
			else
				__nerdline_wt_cmd=""
			fi
		fi

		# Sanitize command for title (keep only printable chars)
		__nerdline_wt_cmd="${__nerdline_wt_cmd//[^[:print:]]/}"

	# If command is empty, use shell name as default
		if [[ -z "$__nerdline_wt_cmd" ]]
		then
			__nerdline_wt_title="${USER}@${HOSTNAME}"
		fi

		# EXITCODE: Use $! (exit of previous command) since current exit isn't available in DEBUG trap
		local __nerdline_wt_exitcode="${__nerdline_tmp_retcode:-0}"

		# Build title using format or default
		local __nerdline_wt_title_format="${__nerdline_win_title_format:-%USER@%HOSTSHORT: %CMD}"
		local __nerdline_wt_title="$__nerdline_wt_title_format"
		__nerdline_wt_title="${__nerdline_wt_title//%USER/$USER}"
		__nerdline_wt_title="${__nerdline_wt_title//%HOSTNAME/$HOSTNAME}"
		__nerdline_wt_title="${__nerdline_wt_title//%CMD/$__nerdline_wt_cmd}"

		# If CMD was empty, use default format
		if [[ -z "$__nerdline_wt_cmd" ]]
		then
			__nerdline_wt_title="${USER}@${HOSTNAME}"
		fi

		# Set window title using OSC 2
		printf '\033]2;%s\007' "$__nerdline_wt_title"
	}

	__nerdline_wt_run "${2:-}"
	exit 0


##################################################################
elif [[ ${BASH_SOURCE[0]} != "$0" ]] #############################
then #Sourcing this file #########################################
	source "$__nerdline_pfx/lib/functions.sh" colors
	source "$__nerdline_pfx/lib/functions.sh" error-sourcing

	# Save original __nerdline_update before overriding
	if [[ $(type -t __nerdline_update) == function ]]
	then
		eval "$(declare -f __nerdline_update | sed 's/__nerdline_update/__nerdline_update_original/')"
	fi

	# Define default configuration
	if [[ -z ${__nerdline_win_title_format:-} ]]
	then
		__nerdline_win_title_format='%USER@%HOSTSHORT: %CMD'
	fi
	if [[ -z ${__nerdline_win_title_enabled:-} ]]
	then
		__nerdline_win_title_enabled=1
	fi
	if [[ -z ${__nerdline_win_title_short_pwd:-} ]]
	then
		__nerdline_win_title_short_pwd=true
	fi

	# Convert true/false to 1/0
	case "${__nerdline_win_title_short_pwd}" in
		true|yes|on)
			__nerdline_win_title_short_pwd=1
			;;
		false|no|off)
			__nerdline_win_title_short_pwd=0
			;;
	esac

	# Export config
	export __nerdline_win_title_format __nerdline_win_title_enabled __nerdline_win_title_short_pwd

	# Helper function to set window title
	# Takes command as argument and sets window title
	function __nerdline_win_title_update()
	{
		local __nerdline_wt_line="${1:-}"
		local __nerdline_wt_is_default="${2:-0}"
		
		# Parse command: skip prefix assignments and extract actual command
		local __nerdline_wt_cmd=""
		local __nerdline_wt_args=""
		
		if [[ -n "$__nerdline_wt_line" ]] && [[ "$__nerdline_wt_is_default" -eq 0 ]]
		then
			# Extract first word (command) - handle special chars like [[, [, {, etc.
			local __nerdline_wt_first="${__nerdline_wt_line%%[[:space:]]*}"
			
			# Check for assignment prefix
			if [[ "$__nerdline_wt_line" =~ ^[A-Za-z_][A-Za-z0-9_]*=.*[[:space:]] ]]
			then
				# Has assignment prefix, get command after it
				local __nerdline_wt_rest="${__nerdline_wt_line#*= }"
				__nerdline_wt_cmd="${__nerdline_wt_rest%%[[:space:]]*}"
			else
				__nerdline_wt_cmd="$__nerdline_wt_first"
			fi
			
			# Handle sudo - get actual command after sudo
			if [[ "$__nerdline_wt_cmd" == sudo ]]
			then
				local __nerdline_wt_rest="${__nerdline_wt_line#sudo[[:space:]]*}"
				if [[ "$__nerdline_wt_rest" =~ ^[A-Za-z_-]+[[:space:]]+([^[:space:]]+) ]]
				then
					__nerdline_wt_cmd="${BASH_REMATCH[1]}"
				elif [[ "$__nerdline_wt_rest" =~ ^([^[:space:]]+) ]]
				then
					__nerdline_wt_cmd="${BASH_REMATCH[1]}"
				else
					__nerdline_wt_cmd=""
				fi
			fi
			
			# Extract args (everything after command)
			if [[ "$__nerdline_wt_line" =~ ^[^[:space:]]+[[:space:]]+(.+) ]]
			then
				__nerdline_wt_args="${BASH_REMATCH[1]}"
			fi
		else
			# Default: show shell name
			__nerdline_wt_cmd="$__nerdline_wt_shellname"
		fi
		
		# Sanitize
		__nerdline_wt_cmd="${__nerdline_wt_cmd//[^[:print:]]/}"
		__nerdline_wt_args="${__nerdline_wt_args//[^[:print:]]/}"
		
		# Replace [[ or [ with shell name (these are bash test commands, not actual commands)
		if [[ "$__nerdline_wt_cmd" == '[[' ]] || [[ "$__nerdline_wt_cmd" == '[' ]]; then
			__nerdline_wt_cmd="bash"
		fi
		
		# If command is empty, use shell name
		if [[ -z "$__nerdline_wt_cmd" ]]; then
			__nerdline_wt_cmd="bash"
		fi
		
		# Get basename of PWD
		local __nerdline_wt_basepwd="${PWD##*/}"
		[[ -z "$__nerdline_wt_basepwd" ]] && __nerdline_wt_basepwd="/"
		
		# If short_pwd enabled and PWD is home, use ~ as basepwd
		if [[ "${__nerdline_win_title_short_pwd:-1}" -eq 1 ]] && [[ "$PWD" == "$HOME" ]]
		then
			__nerdline_wt_basepwd="~"
		fi
		
		# PWD placeholder: use short PWD if setting enabled, otherwise full path
		local __nerdline_wt_pwd="$PWD"
		if [[ "${__nerdline_win_title_short_pwd:-1}" -eq 1 ]] && [[ "$PWD" == "$HOME"* ]]
		then
			__nerdline_wt_pwd="~${PWD#$HOME}"
		fi
		
		# Get shell name and version
		local __nerdline_wt_shellname="${0##*/}"
		local __nerdline_wt_shellversion="$BASH_VERSION"
		__nerdline_wt_shellversion="${__nerdline_wt_shellversion%%[^0-9.]*}"
		
		# Get short hostname (before first dot)
		local __nerdline_wt_hostshort="${HOSTNAME%%.*}"
		
		# Get time and date
		local __nerdline_wt_time
		__nerdline_wt_time="$(date '+%H:%M:%S')"
		local __nerdline_wt_date
		__nerdline_wt_date="$(date '+%Y-%m-%d')"
		
		# Get jobs count
		local __nerdline_wt_jobs
		__nerdline_wt_jobs=$(jobs -p 2>/dev/null | wc -l)
		[[ "$__nerdline_wt_jobs" -eq 0 ]] && __nerdline_wt_jobs=""
		
		# Build title using format
		local __nerdline_wt_title_format="${__nerdline_win_title_format:-%USER@%HOSTSHORT: %CMD}"
		local __nerdline_wt_title="$__nerdline_wt_title_format"
		
		# Replace all placeholders
		__nerdline_wt_title="${__nerdline_wt_title//%CMD/$__nerdline_wt_cmd}"
		__nerdline_wt_title="${__nerdline_wt_title//%ARGS/$__nerdline_wt_args}"
		__nerdline_wt_title="${__nerdline_wt_title//%BASECMD/${__nerdline_wt_cmd##*/}}"
		__nerdline_wt_title="${__nerdline_wt_title//%PWD/$__nerdline_wt_pwd}"
		__nerdline_wt_title="${__nerdline_wt_title//%BASEPWD/$__nerdline_wt_basepwd}"
		__nerdline_wt_title="${__nerdline_wt_title//%HOME/$HOME}"
		__nerdline_wt_title="${__nerdline_wt_title//%USER/$USER}"
		__nerdline_wt_title="${__nerdline_wt_title//%HOSTNAME/$HOSTNAME}"
		__nerdline_wt_title="${__nerdline_wt_title//%HOSTSHORT/$__nerdline_wt_hostshort}"
		__nerdline_wt_title="${__nerdline_wt_title//%SHELLNAME/$__nerdline_wt_shellname}"
		__nerdline_wt_title="${__nerdline_wt_title//%SHELLVERSION/$__nerdline_wt_shellversion}"
		__nerdline_wt_title="${__nerdline_wt_title//%TIME/$__nerdline_wt_time}"
		__nerdline_wt_title="${__nerdline_wt_title//%DATE/$__nerdline_wt_date}"
		__nerdline_wt_title="${__nerdline_wt_title//%JOBS/$__nerdline_wt_jobs}"
		__nerdline_wt_title="${__nerdline_wt_title//%EXITCODE/${__nerdline_tmp_retcode:-0}}"
		

		printf '\033]2;%s\007' "$__nerdline_wt_title"
	}

	# Capture command BEFORE execution using DEBUG trap
	# Set window title to the PREVIOUSLY executed command
	function __nerdline_win_title_debug()
	{
		local cmd="$BASH_COMMAND"
		
		# Skip internal nerdline/prolog commands
		# Check if command starts with keywords or builtins we want to skip
		local __nerdline_wt_first="${cmd%%[[:space:]]*}"
		case "$__nerdline_wt_first" in
			__nerdline_wt_*|__nerdline_update*|for|source|type|unset|SSH_ASKPASS|\(|\{\}|then|else|do|done|shopt|complete|alias|bind|enable|readonly|declare|typeset|printf|return|exit)
				return
				;;
			export)
				if [[ "$cmd" == export\ __nerdline* ]]; then
					return
				fi
				;;
			PROMPT_COMMAND)
				return
				;;
		esac
		
		# Skip pure assignments like VAR=value or VAR=$!
		# Only skip if it's just VAR=value without any command after
		if [[ "$cmd" =~ ^[A-Za-z_][A-Za-z0-9_]*= ]] && \
		   [[ ! "$cmd" =~ ^[A-Za-z_][A-Za-z0-9_]*=.*[[:space:]] ]]
		then
			return
		fi
		
		# Skip job control commands: kill %job, wait %job, fg %job, bg %job
		if [[ "$cmd" =~ ^(kill|wait|fg|bg)[[:space:]]+% ]] || \
		   [[ "$cmd" =~ ^(kill|wait|fg|bg)[[:space:]]+\%+ ]]
		then
			return
		fi
		
		# Skip if the command contains pipes or semicolons (multiple commands)
		if [[ "$cmd" == *'|'* ]] || [[ "$cmd" == *';'* ]]
		then
			return
		fi
		
		# Set title to the CURRENT command (will show while command executes)
		__nerdline_win_title_update "$cmd"
		
		# Store current command as last command (for reference)
		__nerdline_wt_last_cmd="$cmd"
	}
	trap '__nerdline_win_title_debug' DEBUG

	# Reset window title to shell name AFTER command execution (when prompt is shown)
	# This fixes issue where title doesn't reset after vi exits or new terminal opens
	function __nerdline_win_title_prompt()
	{
		__nerdline_win_title_update "" 1
		__nerdline_wt_last_cmd=""
	}
	PROMPT_COMMAND="__nerdline_win_title_prompt${PROMPT_COMMAND:+; $PROMPT_COMMAND}"

	# Override __nerdline_update - call original and add window title
	function __nerdline_update()
	{
		# Call original update to build PS1
		if [[ $(type -t __nerdline_update_original) == function ]]
		then
			__nerdline_update_original
		fi

		# Only set window title if no command was executed yet (terminal just opened)
		# When a command is executed, DEBUG trap already sets the title
		if [[ -z "${__nerdline_wt_last_cmd:-}" ]]
		then
			__nerdline_win_title_update "" 1
		fi
	}

	export __nerdline_mds_win_title_help="Window title module: setup window title by OSC 2"


##################################################################
else #############################################################
	echo -e '\e[33;40musage: nerdline win_title <action>\n\e[0m'
	echo -e '\e[37;40mactions:\e[0m'
	echo -e '\e[36;40m\trun\t\tSet window title (with optional command)\e[0m'
	echo -e '\e[36;40m\ttest\t\tConfiguration and integrity check\e[0m'
fi
