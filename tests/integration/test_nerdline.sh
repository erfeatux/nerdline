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

function test_nerdline_test_command()
{
	if [[ -n $STY ]] || [[ -n $TMUX ]]; then
		nerdline_test_assert "Skip test in screen/tmux" "skip" "skip"
		return
	fi

	local output
	output="$(TERM=dumb __nerdline_pfx="$__nerdline_pfx" bash "$__nerdline_pfx/nerdline.sh" test 2>&1; echo "exit:$?")"

	local exit_code
	exit_code="$(echo "$output" | tail -1 | cut -d: -f2)"

	nerdline_test_assert "nerdline test command runs" "0" "$exit_code"
}

function test_segment_files_exist()
{
	local segment
	for segment in user hostname python hist git pwd jobs retcode; do
		if [[ -f "$__nerdline_pfx/segments/${segment}.sh" ]]; then
			nerdline_test_assert "Segment $segment exists" 0 0
		else
			nerdline_test_assert "Segment $segment exists" 0 1
		fi
	done
}

function test_module_files_exist()
{
	local module
	for module in ssh sudo; do
		if [[ -f "$__nerdline_pfx/modules/${module}.sh" ]]; then
			nerdline_test_assert "Module $module exists" 0 0
		else
			nerdline_test_assert "Module $module exists" 0 1
		fi
	done
}

function test_lib_functions_exist()
{
	source "$__nerdline_pfx/lib/functions.sh" colors

	local color_func_exists
	color_func_exists="$(type -t __nerdline_tmp_isColor)"
	nerdline_test_assert "Color isColor function exists" "function" "$color_func_exists"

	source "$__nerdline_pfx/lib/functions.sh" config

	local config_func_exists
	config_func_exists="$(type -t __nerdline_tmp_load_config)"
	nerdline_test_assert "Config load_config function exists" "function" "$config_func_exists"
}

function test_nerdline_structure()
{
	local nerdline_content
	nerdline_content="$(cat "$__nerdline_pfx/nerdline.sh")"

	local has_test_section=0
	local has_sourcing_section=0
	local has_cli_section=0

	if [[ "$nerdline_content" == *'if [[ $1 == test ]]'* ]]; then
		has_test_section=1
	fi

	if [[ "$nerdline_content" == *'elif [[ ${BASH_SOURCE[0]} != "$0" ]]'* ]]; then
		has_sourcing_section=1
	fi

	if [[ "$nerdline_content" == *'else'* ]]; then
		has_cli_section=1
	fi

	nerdline_test_assert "nerdline.sh has test section" 1 "$has_test_section"
	nerdline_test_assert "nerdline.sh has sourcing section" 1 "$has_sourcing_section"
	nerdline_test_assert "nerdline.sh has CLI section" 1 "$has_cli_section"
}

__nerdline_test_init

nerdline_test_run "Segment Files Exist" test_segment_files_exist
nerdline_test_run "Module Files Exist" test_module_files_exist
nerdline_test_run "Lib Functions Exist" test_lib_functions_exist
nerdline_test_run "Nerdline Structure" test_nerdline_structure
nerdline_test_run "Nerdline Test Command" test_nerdline_test_command

__nerdline_test_summary