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

function test_module()
{
	local module_name="$1"
	local module_file="$__nerdline_pfx/modules/${module_name}.sh"

	if [[ ! -f "$module_file" ]]; then
		nerdline_test_assert "Module $module_name exists" 1 0
		return
	fi

	echo "Testing module: $module_name"

	local output
	output="$(TERMSHELL=bash __nerdline_pfx="$__nerdline_pfx" bash -c "source $module_file test" 2>&1; echo "exit:$?")"

	local exit_code
	exit_code="$(echo "$output" | tail -1 | cut -d: -f2)"

	if [[ "$exit_code" == "0" ]]; then
		nerdline_test_assert "Module $module_name test passed" 0 0
	else
		nerdline_test_assert "Module $module_name test passed" 0 1
		echo "  Output: $output"
	fi
}

__nerdline_test_init

for module in ssh sudo win_title; do
	test_module "$module"
done

__nerdline_test_summary