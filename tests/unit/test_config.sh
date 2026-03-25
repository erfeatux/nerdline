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

__nerdline_pfx="/home/erfea/Projects/nerdline"

source "$__nerdline_pfx/tests/test_lib.sh"

function test_config_with_subshell()
{
	local config_content="$1"
	local expected="$2"
	local test_code="$3"

	local test_config_file="/tmp/nerdline_test_config_$$.cfg"
	cat > "$test_config_file" <<< "$config_content"

	local result
	result="$(bash -c "
		source '$__nerdline_pfx/lib/functions.sh' error-sourcing
		source '$__nerdline_pfx/lib/functions.sh' config
		__nerdline_tmp_load_config '$test_config_file'
		$test_code
	" 2>/dev/null)"

	rm -f "$test_config_file"
	nerdline_test_assert "Config test" "$expected" "$result"
}

function test_config_simple_key_value()
{
	test_config_with_subshell "[section]
key=value" "value" 'echo "$__nerdline_section_key"'
}

function test_config_quoted_value_double()
{
	test_config_with_subshell '[section]
key="quoted value"' "quoted value" 'echo "$__nerdline_section_key"'
}

function test_config_quoted_value_single()
{
	test_config_with_subshell "[section]
key='single quoted'" "single quoted" 'echo "$__nerdline_section_key"'
}

function test_config_comment_line()
{
	test_config_with_subshell "[section]
# this is a comment
key=value" "value" 'echo "$__nerdline_section_key"'
}

function test_config_empty_line()
{
	test_config_with_subshell "[section]

key=value" "value" 'echo "$__nerdline_section_key"'
}

function test_config_multiple_sections()
{
	local test_config_file="/tmp/nerdline_test_config_$$.cfg"
	cat > "$test_config_file" <<< "[section1]
key1=value1
[section2]
key2=value2"

	local result1 result2
	result1="$(bash -c "source '$__nerdline_pfx/lib/functions.sh' error-sourcing; source '$__nerdline_pfx/lib/functions.sh' config; __nerdline_tmp_load_config '$test_config_file'; echo \$__nerdline_section1_key1" 2>/dev/null)"
	result2="$(bash -c "source '$__nerdline_pfx/lib/functions.sh' error-sourcing; source '$__nerdline_pfx/lib/functions.sh' config; __nerdline_tmp_load_config '$test_config_file'; echo \$__nerdline_section2_key2" 2>/dev/null)"

	rm -f "$test_config_file"
	nerdline_test_assert "Multiple sections - section1" "value1" "$result1"
	nerdline_test_assert "Multiple sections - section2" "value2" "$result2"
}

function test_config_nerdline_section()
{
	test_config_with_subshell "[nerdline]
segments=user hostname" "user hostname" 'echo "$__nerdline_segments"'
}

function test_config_whitespace_trim()
{
	test_config_with_subshell "[section]
key =   value with spaces  " "value with spaces" 'echo "$__nerdline_section_key"'
}

function test_config_key_dot_to_underscore()
{
	test_config_with_subshell "[section]
color.fg=#ffffff" "#ffffff" 'echo "$__nerdline_section_color_fg"'
}

function test_config_case_insensitive_section()
{
	test_config_with_subshell "[SECTION]
key=value" "value" 'echo "$__nerdline_section_key"'
}

function test_config_file_not_found()
{
	local output
	output="$(bash -c "source '$__nerdline_pfx/lib/functions.sh' error-sourcing; source '$__nerdline_pfx/lib/functions.sh' config; __nerdline_tmp_load_config '/nonexistent.cfg' 2>&1; echo \"exit:\$?\"" 2>&1)"

	local exit_code
	exit_code="$(echo "$output" | tail -1 | cut -d: -f2)"
	nerdline_test_assert "Non-existent config file returns error" "10" "$exit_code"
}

__nerdline_test_init

nerdline_test_run "Simple Key-Value" test_config_simple_key_value
nerdline_test_run "Double Quoted Value" test_config_quoted_value_double
nerdline_test_run "Single Quoted Value" test_config_quoted_value_single
nerdline_test_run "Comment Line" test_config_comment_line
nerdline_test_run "Empty Line" test_config_empty_line
nerdline_test_run "Multiple Sections" test_config_multiple_sections
nerdline_test_run "Nerdline Section" test_config_nerdline_section
nerdline_test_run "Whitespace Trim" test_config_whitespace_trim
nerdline_test_run "Dot to Underscore" test_config_key_dot_to_underscore
nerdline_test_run "Case Insensitive Section" test_config_case_insensitive_section
nerdline_test_run "File Not Found" test_config_file_not_found

__nerdline_test_summary